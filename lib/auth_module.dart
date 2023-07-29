import 'dart:io';

import 'package:ensemble/framework/stub/auth_context_manager.dart';
import 'package:ensemble/framework/stub/oauth_controller.dart';
import 'package:ensemble/framework/stub/token_manager.dart';
import 'package:ensemble/module/auth_module.dart';
import 'package:ensemble/widget/stub_widgets.dart';
import 'package:ensemble_auth/connect/OAuthController.dart';
import 'package:ensemble_auth/connect/widget/connect_with_google.dart';
import 'package:ensemble_auth/signin/auth_manager.dart';
import 'package:ensemble_auth/signin/widget/sign_in_with_apple.dart';
import 'package:ensemble_auth/signin/widget/sign_in_with_auth0.dart';
import 'package:ensemble_auth/signin/widget/sign_in_with_google.dart';
import 'package:ensemble_auth/token_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

class AuthModuleImpl implements AuthModule {
  static final AuthModuleImpl _instance = AuthModuleImpl._internal();
  AuthModuleImpl._internal();
  factory AuthModuleImpl() {
    return _instance;
  }


  @override
  void init() {
    GetIt.I.registerFactory<AuthContextManager>(() => AuthContextManagerImpl());
    GetIt.I.registerFactory<SignInWithGoogle>(() => SignInWithGoogleImpl());
    GetIt.I.registerFactory<SignInWithApple>(() => SignInWithAppleImpl());
    GetIt.I.registerFactory<ConnectWithGoogle>(() => ConnectWithGoogleImpl());
    GetIt.I.registerFactory<SignInWithAuth0>(() => SignInWithAuth0Impl());
    GetIt.I.registerSingleton<TokenManager>(TokenManagerImpl());
    GetIt.I.registerFactory<OAuthController>(() => OAuthControllerImpl());
  }



}
