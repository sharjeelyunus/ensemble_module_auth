import 'dart:developer';
import 'dart:io';

import 'package:ensemble/ensemble.dart';
import 'package:ensemble/framework/action.dart';
import 'package:ensemble/framework/error_handling.dart';
import 'package:ensemble/framework/event.dart';
import 'package:ensemble/framework/storage_manager.dart';
import 'package:ensemble/framework/view/page.dart';
import 'package:ensemble/framework/widget/widget.dart';
import 'package:ensemble/screen_controller.dart';
import 'package:ensemble/util/utils.dart';
import 'package:ensemble/widget/helpers/controllers.dart';
import 'package:ensemble/widget/stub_widgets.dart';
import 'package:ensemble_auth/auth_manager.dart';
import 'package:ensemble_auth/google/google_sign_in_button.dart';
import 'package:ensemble_ts_interpreter/invokables/invokable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class SignInWithGoogle extends StatefulWidget
    with
        Invokable,
        HasController<SignInWithGoogleController, SignInWithGoogleState>
    implements SignInWithGoogleBase {


  SignInWithGoogle({super.key});

  final SignInWithGoogleController _controller = SignInWithGoogleController();

  @override
  get controller => _controller;

  @override
  State<StatefulWidget> createState() => SignInWithGoogleState();

  @override
  Map<String, Function> getters() => {};

  @override
  Map<String, Function> methods() => {};

  @override
  Map<String, Function> setters() => {
        'widget': (widgetDef) => _controller.widgetDef = widgetDef,
        'authenticateOnly': (value) => _controller.authenticateOnly = Utils.getBool(value, fallback: _controller.authenticateOnly),
        'onAuthenticated': (action) => _controller.onAuthenticated =
            EnsembleAction.fromYaml(action, initiator: this),
        'onSignedIn': (action) => _controller.onSignedIn =
            EnsembleAction.fromYaml(action, initiator: this),
        'onError': (action) => _controller.onError =
            EnsembleAction.fromYaml(action, initiator: this),
        'scopes': (value) => _controller.scopes =
            Utils.getListOfStrings(value) ?? _controller.scopes,
      };
}

class SignInWithGoogleController extends WidgetController {
  dynamic widgetDef;
  List<String> scopes = [];

  bool authenticateOnly = false;
  EnsembleAction? onAuthenticated;
  EnsembleAction? onSignedIn;
  EnsembleAction? onError;
}

class SignInWithGoogleState extends WidgetState<SignInWithGoogle> {
  late GoogleSignIn _googleSignIn;
  Widget? displayWidget;

  @override
  void initState() {
    super.initState();

    _googleSignIn = GoogleSignIn(
      clientId: '1045872208865-suc24i3cqf71ltulsjfr6734sh9t9fkm.apps.googleusercontent.com',
        // clientId: getClientId(),
        // serverClientId: getServerClientId(),
        scopes: widget._controller.scopes);
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      if (account != null) {
        var googleAuthentication = await account.authentication;

        // at this point the user is authenticated.
        // On non-Web, Authorization is automatic with authentication.
        // On Web, Authorization has to be done separately, and has
        //  to be triggered manually by the user (e.g. button click)
        // TODO: authorize for Web
        bool isAuthorized = true;
        if (kIsWeb) {
          isAuthorized =
              await _googleSignIn.canAccessScopes(widget._controller.scopes);
        }
        // await _onAuthenticated(account, googleAuthentication);
        await _onAuthenticated2(account, googleAuthentication);
      } else {
        //log("TO BE IMPLEMENTED: log out");
      }
    });
  }

  Future<void> _onAuthenticated2(GoogleSignInAccount account,
      GoogleSignInAuthentication googleAuthentication) async {

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuthentication.accessToken,
      idToken: googleAuthentication.idToken,
    );
    final UserCredential authResult = await FirebaseAuth.instanceFor(app: Firebase.app('customFirebase')).signInWithCredential(credential);
    // final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = authResult.user;

    log(user.toString());
  }

  Future<void> _onAuthenticated(GoogleSignInAccount account,
      GoogleSignInAuthentication googleAuthentication) async {



    AuthenticatedUser user = AuthenticatedUser(
        provider: AuthProvider.google,
        id: account.id,
        name: account.displayName,
        email: account.email,
        photo: account.photoUrl);

    // trigger the callback. This can be used to sign in on the server
    if (widget._controller.onAuthenticated != null) {
      ScreenController()
          .executeAction(context, widget._controller.onAuthenticated!,
          event: EnsembleEvent(widget, data: {
            'user': user,

            // server can verify and decode to get user info, useful for Sign In
            'idToken': googleAuthentication.idToken,

            // server can exchange this for accessToken/refreshToken
            'serverAuthCode': account.serverAuthCode
          }));
    }

    // we implicitly sign in unless user said to only authenticate
    if (!widget._controller.authenticateOnly) {
      AuthToken? token;
      if (googleAuthentication.accessToken != null) {
        token = AuthToken(
            tokenType: TokenType.bearerToken,
            token: googleAuthentication.accessToken!);
      }
      //await AuthManager().signInWithCredential(context, SignInProvider.. user: user, token: token);

      // trigger onSignIn callback
      if (widget._controller.onSignedIn != null) {
        ScreenController()
            .executeAction(context, widget._controller.onSignedIn!,
            event: EnsembleEvent(widget, data: {
              'user': user
            }));
      }

    }

  }

  Future<void> _handleSignIn() async {
    try {
      // sign out so user can switch to another account
      // when clicking on the button multiple times
      await _googleSignIn.signOut();

      await _googleSignIn.signIn();
    } catch (error) {
      log(error.toString());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // build the display widget
    displayWidget = DataScopeWidget.getScope(context)
        ?.buildWidgetFromDefinition(widget._controller.widgetDef);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return buildGoogleSignInButton(
        mobileWidget: displayWidget, onPressed: _handleSignIn);
  }

  String getClientId() {
    SignInCredential? credential =
        Ensemble().getSignInServices()?.signInCredentials?[ServiceName.google];
    String? clientId;
    if (kIsWeb) {
      clientId = credential?.webClientId;
    } else if (Platform.isAndroid) {
      clientId = credential?.androidClientId;
    } else if (Platform.isIOS) {
      clientId = credential?.iOSClientId;
    }
    if (clientId != null) {
      return clientId;
    }
    throw LanguageError("Google SignIn provider is required.",
        recovery: "Please check your configuration.");
  }

  // serverClientId is not supported on Web
  String? getServerClientId() => kIsWeb
      ? null
      : Ensemble()
          .getSignInServices()
          ?.signInCredentials?[ServiceName.google]
          ?.serverClientId;
}
