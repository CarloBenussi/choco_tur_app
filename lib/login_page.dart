import 'package:choco_tur/widgets/user_text_input.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

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
      // TODO: Login
      print("Successfully logged in");
    } else {
      print("Error");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                UserTextInput(
                  controller: _userNameController,
                  hintText: "Enter your username",
                  validator: validateUsername,
                ),
                UserTextInput(
                  controller: _passwordController,
                  hintText: "Enter your password",
                  obscured: true,
                  validator: validatePassword,
                ),
              ],
            ),
          ),
          ElevatedButton(
              onPressed: loginUser,
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
              )),
        ],
      ),
    ));
  }
}
