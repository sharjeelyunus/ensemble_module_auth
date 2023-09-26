import 'package:ensemble/framework/action.dart';
import 'package:ensemble/framework/stub/oauth_controller.dart';
import 'package:ensemble/framework/stub/token_manager.dart';
import 'package:ensemble/framework/view/data_scope_widget.dart';
import 'package:ensemble/framework/view/page.dart';
import 'package:ensemble/framework/widget/widget.dart';
import 'package:ensemble/screen_controller.dart';
import 'package:ensemble/widget/stub_widgets.dart';
import 'package:ensemble_auth/connect/OAuthController.dart';
import 'package:ensemble_auth/connect/widget/connect.dart';
import 'package:ensemble_auth/signin/widget/sign_in_button.dart';
import 'package:ensemble_ts_interpreter/invokables/invokable.dart';
import 'package:flutter/material.dart';

class ConnectWithMicrosoftImpl extends StatefulWidget
    with
        Invokable,
        HasController<ConnectWithMicrosoftController, ConnectWithMicrosoftState>
    implements ConnectWithMicrosoft {
  static const defaultLabel = 'Continue with Microsoft';
  ConnectWithMicrosoftImpl({super.key});

  final ConnectWithMicrosoftController _controller = ConnectWithMicrosoftController();
  @override
  ConnectWithMicrosoftController get controller => _controller;

  @override
  State<StatefulWidget> createState() => ConnectWithMicrosoftState();


  @override
  Map<String, Function> getters() {
    return {};
  }

  @override
  Map<String, Function> methods() {
    return {};
  }

  @override
  Map<String, Function> setters() {
    return {
      'tokenExchangeAPI': (apiAction) => _controller.tokenExchangeAPI =
          apiAction == null ? null : InvokeAPIAction.fromYaml(
              initiator: this, payload: apiAction),
      'onAuthorized': (action) => _controller.onAuthorized =
          EnsembleAction.fromYaml(action, initiator: this),
      'onError': (action) => _controller.onError =
          EnsembleAction.fromYaml(action, initiator: this),
    };
  }
}

class ConnectWithMicrosoftController extends ConnectController{

}

class ConnectWithMicrosoftState extends WidgetState<ConnectWithMicrosoftImpl> {
  Widget? _displayWidget;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget._controller.widgetDef != null) {
      _displayWidget = DataScopeWidget.getScope(context)
          ?.buildWidgetFromDefinition(widget._controller.widgetDef);
    }
  }


  @override
  Widget buildWidget(BuildContext context) {
    return _displayWidget != null
        ? ConnectWidgetContainer(widget: _displayWidget!, onTap: startAuthFlow)
        : SignInButton(
          defaultLabel: ConnectWithMicrosoftImpl.defaultLabel,
          iconName: 'microsoft_logo.svg',
          buttonController: widget._controller,
          onTap: startAuthFlow);
  }

  Future<void> startAuthFlow() async {
    // a scope is required for Microsoft
    List<String> scopes = ['openid'];
    if (widget._controller.initialScopes != null) {
      scopes.addAll(widget._controller.initialScopes!);
    }

    OAuthServiceToken? token = await OAuthControllerImpl().authorize(
        context,
        OAuthService.microsoft,
        scope: ConnectUtils.getScopesAsString(scopes),
        forceNewTokens: true,   // this always force the flow again
        tokenExchangeAPI: widget._controller.tokenExchangeAPI);

    // dispatch success
    if (widget._controller.onAuthorized != null && token != null) {
      ScreenController()
          .executeAction(context, widget._controller.onAuthorized!);
    }

    // dispatch error
    if (widget._controller.onError != null && token == null) {
      ScreenController()
          .executeAction(context, widget._controller.onError!);
    }
  }

}
