import 'package:choco_tur/utils/lang_codes.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChocoTurModel extends ChangeNotifier {
  static init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static const String userName = "userName";
  static const String languageKey = "lang";

  static late final SharedPreferences _preferences;
  Locale? _locale;

  Locale get locale {
    if (_locale == null) {
      String? setLanguage = _preferences.getString(languageKey);
      if (setLanguage != null) {
        _locale = Locale(setLanguage);
      } else {
        _locale = const Locale(LanguageCodes.EN);
      }
    }

    return _locale!;
  }

  void setLanguage(BuildContext context, String lang) {
    String? setLanguage = _preferences.getString(languageKey);
    if (setLanguage != null && setLanguage == lang) {
      LoggerInstance.logger.d(
          'Language set is equivalent to language saved in preferences ($lang).');
      return;
    }

    _locale = Locale(lang);
    _preferences.setString(languageKey, lang);
    notifyListeners();
  }
}
