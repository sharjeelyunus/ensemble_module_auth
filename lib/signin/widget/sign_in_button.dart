import 'package:ensemble/framework/extensions.dart';
import 'package:ensemble/framework/model.dart';
import 'package:ensemble/util/utils.dart';
import 'package:ensemble/widget/helpers/controllers.dart';
import 'package:ensemble_auth/signin/widget/sign_in_with_apple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Button that mimic Apple button's styles for consistency
class SignInButton extends StatelessWidget {
  const SignInButton({super.key, required this.defaultLabel, required this.buttonController, required this.onTap});

  final String defaultLabel;
  final SignInButtonController buttonController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // content height per Apple's guideline (at least for font size)
    var contentHeight = buttonController.height * 0.43;
    const iconPaddingRight = 6.0;
    const iconPaddingLeft = 4.0;

    List<Widget> children;
    var icon = Padding(
        padding: const EdgeInsets.only(
            left: iconPaddingLeft,
            right: iconPaddingRight),
        child: SvgPicture.asset('assets/google_logo.svg',
            package: 'ensemble_auth',
            height: contentHeight,
            width: contentHeight));
    var text = Text(buttonController.overrideLabel ?? defaultLabel,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: contentHeight,
            fontFamily: '.SF Pro Text',
            color: Colors.black,
            letterSpacing: -0.41));
    if (buttonController.iconAlignment == IconAlignment.left) {
      children = [
        icon,
        Expanded(child: text),
        SizedBox(width: contentHeight + iconPaddingLeft + iconPaddingRight)
      ];
    } else {
      children = [icon, Flexible(child: text)];
    }

    return SizedBox(
      height: buttonController.height.toDouble(),
      child: CupertinoButton(
          padding: EdgeInsets.zero,
          borderRadius: buttonController.borderRadius.getValue(),
          onPressed: onTap,
          child: Container(
            decoration: _decoration,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            height: buttonController.height.toDouble(),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children),
          )),
    );
  }

  Decoration? get _decoration {
    return BoxDecoration(
      border: Border.all(width: 1, color: Colors.black),
      borderRadius: buttonController.borderRadius.getValue(),
    );
  }


}

/// default button for Apple Sign In for now. Custom button later
class AppleSignInButton extends SignInButton {
  const AppleSignInButton(
      {Key? key,
      required SignInWithAppleController buttonController,
      required VoidCallback onTap}) :
        appleButtonController = buttonController,
        super(
          key: key,
          defaultLabel: SignInWithAppleImpl.defaultLabel,
          buttonController: buttonController,
          onTap: onTap);

  final SignInWithAppleController appleButtonController;


  @override
  Widget build(BuildContext context) => SignInWithAppleButton(
      onPressed: onTap,
      style: appleButtonController.buttonStyle ??
          SignInWithAppleButtonStyle.whiteOutlined,
      iconAlignment: appleButtonController.iconAlignment ?? IconAlignment.center,
      borderRadius: appleButtonController.borderRadius.getValue(),
      text: appleButtonController.overrideLabel ?? defaultLabel);
}

class SignInButtonController extends WidgetController {
  String? overrideLabel;

  EBorderRadius borderRadius = EBorderRadius.all(4);
  int height = 44;
  IconAlignment iconAlignment = IconAlignment.center;


  @override
  Map<String, Function> getBaseSetters() {
    Map<String, Function> setters = super.getBaseSetters();
    setters.addAll({
      'overrideLabel': (value) => overrideLabel = Utils.optionalString(value),
      'borderRadius': (value) => borderRadius = Utils.getBorderRadius(value) ?? borderRadius,
      'height': (value) => height = Utils.getInt(value, fallback: height),
      'iconAlignment': (value) => iconAlignment = IconAlignment.values.from(value) ?? iconAlignment,

    });
    return setters;
  }
}