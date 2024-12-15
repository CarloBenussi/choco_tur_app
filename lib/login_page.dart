import 'dart:ui';

import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/facebook_login_service.dart';
import 'package:choco_tur/services/google_login_service.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/utils/validation.dart';
import 'package:choco_tur/widgets/dialog.dart';
import 'package:choco_tur/widgets/home_page_background_painter.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/login_with_button.dart';
import 'package:choco_tur/widgets/user_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _isRememberMeChecked = false;
  bool _loggingIn = false;

  void loginUser() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _loggingIn = true;
      });
      bool loginSuccess = await WebappService.loginUser(
        context,
        _emailController.text,
        _passwordController.text,
        _isRememberMeChecked,
      );
      setState(() {
        _loggingIn = false;
      });

      if (loginSuccess && mounted) {
        LoggerInstance.logger.i('Successfully logged in');
        Navigator.pop(context);
      }
    }
  }

  void loginWithGoogle(BuildContext context) async {
    try {
      GoogleSignInAccount? account = await GoogleLoginService.signInWithGoogle();
      if (account == null) {
        throw Exception("Failed to log in with Google.");
      }

      GoogleSignInAuthentication authentication = await account.authentication;

      // TODO: send token to spring app for validation and user registration, and save
      // JWT token into Bearer header.

      // ignore: use_build_context_synchronously
      Provider.of<ChocoTurUser>(context, listen: false).saveLoginInfo(
        account.email,
        authentication.accessToken,
        null,
        LoginType.withGoogle,
        true,
      );

      LoggerInstance.logger.i("Successfully logged in with Google.");

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      LoggerInstance.logger.e(e.toString());
      // ignore: use_build_context_synchronously
      return showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.loginFailedTitle,
        description: '${AppLocalizations.of(context)!.loginWithGoogleFailed}\n\n${e.toString()}',
        dismissable: true,
      );
    }
  }

  void loginWithApple() {} // TODO: Implement.

  void loginWithFacebook() async {
    try {
      FacebookLoginResult? res = await FacebookLoginService.signInWithFacebook();
      if (res == null) {
        throw Exception("Failed to log in with Facebook.");
      }

      String? email = await FacebookLoginService.facebookLogin.getUserEmail();
      if (email == null) {
        throw Exception("Email permission not granted.");
      }

      FacebookAccessToken? accessToken = res.accessToken;

      // TODO: send token to spring app for validation and user registration, and save
      // JWT token into Bearer header.

      // ignore: use_build_context_synchronously
      Provider.of<ChocoTurUser>(context, listen: false).saveLoginInfo(
        email,
        accessToken?.token,
        null,
        LoginType.withFacebook,
        true,
      );

      LoggerInstance.logger.i("Successfully logged in with Facebook.");

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      LoggerInstance.logger.e(e.toString());
      // ignore: use_build_context_synchronously
      return showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.loginFailedTitle,
        description: '${AppLocalizations.of(context)!.loginWithFacebookFailed}\n\n${e.toString()}',
        dismissable: true,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    GoogleLoginService.googleSignIn.onCurrentUserChanged.listen((event) {
      // TODO: Implement current user changed?
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomPaint(
        painter: HomePageBackgroundPainter(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Stack(
              children: [
                ListView(
                  children: [
                    Center(
                      child: Text("CHOCO TUR",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Styles.redShade,
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset("assets/login.png", fit: BoxFit.cover)),
                    ),
                    Center(
                      child: Text(AppLocalizations.of(context)!.loginWithCredentialsTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          )),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          UserTextInput(
                            controller: _emailController,
                            hintText: AppLocalizations.of(context)!.email,
                            validator: (email) => Validation.validateEmail(context, email),
                          ),
                          UserTextInput(
                            controller: _passwordController,
                            hintText: AppLocalizations.of(context)!.password,
                            obscured: true,
                            validator: (password) => Validation.validatePassword(context, password),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: CheckboxListTile(
                            title: Text(AppLocalizations.of(context)!.rememberMe,
                                style: const TextStyle(
                                  fontSize: 12,
                                )),
                            controlAffinity: ListTileControlAffinity.leading,
                            checkColor: Styles.redShade,
                            activeColor: Styles.onRedShade,
                            visualDensity: const VisualDensity(horizontal: -4),
                            value: _isRememberMeChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isRememberMeChecked = value!;
                              });
                            },
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, RouteNames.passwordRecoveryProcess);
                            },
                            child: Text(
                              AppLocalizations.of(context)!.forgotPassword,
                              style: TextStyle(fontSize: 15, color: Styles.redShade),
                            ))
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                                onPressed: loginUser,
                                style: ElevatedButton.styleFrom(backgroundColor: Styles.redShade),
                                child: Text(
                                  AppLocalizations.of(context)!.signInButtonLabel,
                                  style: const TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.w300, color: Styles.onRedShade),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        children: [
                          const Expanded(child: Divider()),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(AppLocalizations.of(context)!.or,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                )),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LoginWithButton(
                        onPressedFunction: () => loginWithGoogle(context),
                        labelText: AppLocalizations.of(context)!.signInWithGoogle,
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                          color: Styles.onRedShade,
                        ),
                        buttonColor: Styles.redShade,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LoginWithButton(
                        onPressedFunction: loginWithApple,
                        labelText: AppLocalizations.of(context)!.signInWithApple,
                        icon: const FaIcon(
                          FontAwesomeIcons.apple,
                          color: Styles.onRedShade,
                        ),
                        buttonColor: Styles.redShade,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LoginWithButton(
                        onPressedFunction: loginWithFacebook,
                        labelText: AppLocalizations.of(context)!.signInWithFacebook,
                        icon: const FaIcon(
                          FontAwesomeIcons.facebook,
                          color: Styles.onRedShade,
                        ),
                        buttonColor: Styles.redShade,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dontHaveAnAccountQ,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(left: 5),
                            ),
                            onPressed: () => {Navigator.pushNamed(context, RouteNames.registrationProcess)},
                            child: Text(
                              AppLocalizations.of(context)!.createAnAccount,
                              style: TextStyle(fontSize: 15, color: Styles.redShade),
                            ))
                      ],
                    ),
                  ],
                ),
                if (_loggingIn)
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 5,
                      sigmaY: 5,
                    ),
                    child: const Center(
                      child: LoadingAnimation(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
