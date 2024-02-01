import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Validation {
  static RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static String? validateEmail(BuildContext context, String? email) {
    if (email == null || email.isEmpty) {
      return AppLocalizations.of(context)!.pleaseInsertEmail;
    }

    if (!emailRegex.hasMatch(email)) {
      return AppLocalizations.of(context)!.invalidEmail;
    }

    return null;
  }

  static String? validatePassword(BuildContext context, String? password) {
    if (password == null || password.isEmpty) {
      return AppLocalizations.of(context)!.pleaseInsertPassword;
    } else if (password.length < 8) {
      return AppLocalizations.of(context)!.invalidPassword;
    }

    return null;
  }
}
