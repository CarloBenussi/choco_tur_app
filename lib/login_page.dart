import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/widgets/login_with_button.dart';
import 'package:choco_tur/widgets/user_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _userNameController = TextEditingController();

  final _passwordController = TextEditingController();

  bool isRememberMeChecked = false;

  String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return "Please insert your username";
    } else if (username.length < 5) {
      return "Your username should be at least 5 characters.";
    }

    return null;
  }

  String? validatePassword(String? username) {
    // TODO: Implement.
    return null;
  }

  void loginUser() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      // TODO: Login and set token on ChocoTurModel.
      LoggerInstance.logger.i("Successfully logged in.");
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      LoggerInstance.logger.i("Error in loggin in.");
    }
  }

  void loginWithGoogle() {} // TODO: Implement.

  void loginWithApple() {} // TODO: Implement.

  void loginWithFacebook() {} // TODO: Implement.

  void createAccount() {} // TODO: Implement.

  void forgotPassword() {} // TODO: Implement.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: ListView(
          children: [
            const Center(
              child: Text("ChocoTur",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child:
                      Image.asset("assets/gianduiotto.jpg", fit: BoxFit.cover)),
            ),
            const Center(
              child: Text("Login with your credentials",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  UserTextInput(
                    controller: _userNameController,
                    hintText: "Email",
                    validator: validateUsername,
                  ),
                  UserTextInput(
                    controller: _passwordController,
                    hintText: "Password",
                    obscured: true,
                    validator: validatePassword,
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
                        style: const TextStyle(fontSize: 12)),
                    controlAffinity: ListTileControlAffinity.leading,
                    checkColor: Colors.white,
                    activeColor: Colors.blue,
                    value: isRememberMeChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isRememberMeChecked = value!;
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: forgotPassword,
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(fontSize: 15, color: Colors.blue),
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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue),
                        child: const Text(
                          "SIGN IN",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: Colors.white),
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
                    child: const Text("OR",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w300)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LoginWithButton(
                    onPressedFunction: loginWithGoogle,
                    labelText: "SIGN IN WITH GOOGLE",
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                    ),
                    buttonColor: Colors.red,
                  ),
                  LoginWithButton(
                    onPressedFunction: loginWithApple,
                    labelText: "SIGN IN WITH APPLE",
                    icon: const FaIcon(
                      FontAwesomeIcons.apple,
                      color: Colors.white,
                    ),
                    buttonColor: Colors.black,
                  ),
                  LoginWithButton(
                    onPressedFunction: loginWithFacebook,
                    labelText: "SIGN IN WITH FACEBOOK",
                    icon: const FaIcon(
                      FontAwesomeIcons.facebook,
                      color: Colors.white,
                    ),
                    buttonColor: Colors.blue,
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(fontSize: 15),
                ),
                TextButton(
                    onPressed: createAccount,
                    child: const Text(
                      "Create an account",
                      style: TextStyle(fontSize: 15, color: Colors.blue),
                    ))
              ],
            )
          ],
        ),
      ),
    ));
  }
}
