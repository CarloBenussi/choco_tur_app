import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginWithButton extends StatelessWidget {
  const LoginWithButton(
      {super.key,
      required this.onPressedFunction,
      required this.labelText,
      required this.icon,
      required this.buttonColor});

  final void Function() onPressedFunction;
  final String labelText;
  final FaIcon icon;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressedFunction,
      icon: icon,
      label: Text(
        labelText,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
    );
  }
}
