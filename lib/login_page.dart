import 'dart:ui';

import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/facebook_login_service.dart';
import 'package:choco_tur/services/google_login_service.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/validation.dart';
import 'package:choco_tur/widgets/generic_alert_dialog.dart';
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
        Navigator.pushReplacementNamed(context, RouteNames.home);
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

      // ignore: use_build_context_synchronously
      Provider.of<ChocoTurUser>(context, listen: false).saveLoginInfo(
        account.email,
        authentication.accessToken,
        null,
        LoginType.withGoogle,
        true,
      );

      // TODO: send token to spring app for validation and user registration, and save
      // JWT token into Bearer header.

      LoggerInstance.logger.i("Successfully logged in with Google.");

      if (mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    } catch (e) {
      LoggerInstance.logger.e(e.toString());
      // ignore: use_build_context_synchronously
      return showDialog(
        context: context,
        builder: (_) => GenericAlertDialog(
          title: AppLocalizations.of(context)!.loginFailedTitle,
          content: '${AppLocalizations.of(context)!.loginWithGoogleFailed}\n\n${e.toString()}',
        ),
        barrierDismissible: true,
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

      // ignore: use_build_context_synchronously
      Provider.of<ChocoTurUser>(context, listen: false).saveLoginInfo(
        email,
        accessToken?.token,
        null,
        LoginType.withFacebook,
        true,
      );

      // TODO: send token to spring app for validation and user registration, and save
      // JWT token into Bearer header.

      LoggerInstance.logger.i("Successfully logged in with Facebook.");

      if (mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    } catch (e) {
      LoggerInstance.logger.e(e.toString());
      // ignore: use_build_context_synchronously
      return showDialog(
        context: context,
        builder: (_) => GenericAlertDialog(
          title: AppLocalizations.of(context)!.loginFailedTitle,
          content: '${AppLocalizations.of(context)!.loginWithFacebookFailed}\n\n${e.toString()}',
        ),
        barrierDismissible: true,
      );
    }
  }

  void forgotPassword() {} // TODO: Implement.

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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Stack(
            children: [
              ListView(
                children: [
                  const Center(
                    child: Text("ChocoTur",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset("assets/chocolateGobino.jpg", fit: BoxFit.cover)),
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
                          checkColor: Colors.black,
                          activeColor: Colors.white,
                          value: _isRememberMeChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isRememberMeChecked = value!;
                            });
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: forgotPassword,
                            child: Text(
                              AppLocalizations.of(context)!.forgotPassword,
                              style: const TextStyle(fontSize: 15, color: Colors.blue),
                            )),
                      )
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
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                              child: Text(
                                AppLocalizations.of(context)!.signInButtonLabel,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Colors.white),
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
                        color: Colors.white,
                      ),
                      buttonColor: Colors.red,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LoginWithButton(
                      onPressedFunction: loginWithApple,
                      labelText: AppLocalizations.of(context)!.signInWithApple,
                      icon: const FaIcon(
                        FontAwesomeIcons.apple,
                        color: Colors.white,
                      ),
                      buttonColor: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LoginWithButton(
                      onPressedFunction: loginWithFacebook,
                      labelText: AppLocalizations.of(context)!.signInWithFacebook,
                      icon: const FaIcon(
                        FontAwesomeIcons.facebook,
                        color: Colors.white,
                      ),
                      buttonColor: Colors.blue,
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
                          onPressed: () => {Navigator.pushNamed(context, RouteNames.registrationProcess)},
                          child: Text(
                            AppLocalizations.of(context)!.createAnAccount,
                            style: const TextStyle(fontSize: 15, color: Colors.blue),
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
    );
  }
}
