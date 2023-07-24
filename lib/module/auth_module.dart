import 'package:ensemble/framework/stub/auth_context_manager.dart';
import 'package:ensemble/framework/stub/oauth_controller.dart';
import 'package:ensemble/framework/stub/token_manager.dart';
import 'package:ensemble/module/auth_module.dart';
import 'package:ensemble/widget/stub_widgets.dart';
import 'package:ensemble_auth/OAuthController.dart';
import 'package:ensemble_auth/auth_manager.dart';
import 'package:ensemble_auth/sign_in_with_apple.dart';
import 'package:ensemble_auth/sign_in_with_google.dart';
import 'package:ensemble_auth/token_manager.dart';
import 'package:get_it/get_it.dart';

class AuthModuleImpl implements AuthModule {
  @override
  void init() {
    GetIt.I.registerFactory<AuthContextManager>(() => AuthContextManagerImpl());
    GetIt.I.registerFactory<SignInWithGoogle>(() => SignInWithGoogleImpl());
    GetIt.I.registerFactory<SignInWithApple>(() => SignInWithAppleImpl());
    GetIt.I.registerSingleton<TokenManager>(TokenManagerImpl());
    GetIt.I.registerFactory<OAuthController>(() => OAuthControllerImpl());
  }

}