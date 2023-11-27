import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';

class UserTextInput extends StatelessWidget {
  const UserTextInput(
      {super.key,
      required this.controller,
      required this.hintText,
      this.validator,
      this.obscured = false});

  final TextEditingController controller;
  final String hintText;
  final bool obscured;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
      child: TextFormField(
        validator: validator,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              const TextStyle(color: ChocoTurStyles.textOnBackgroundColor),
          border: const UnderlineInputBorder(),
        ),
        maxLines: 1,
        obscureText: obscured,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w300,
          color: ChocoTurStyles.textOnBackgroundColor,
        ),
      ),
    );
  }
}
