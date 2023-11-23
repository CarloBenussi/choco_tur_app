import 'package:choco_tur/utils/lang_codes.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Class to store on mobile storage user non-sensitive data and preferences
/// such as user name, language preferences and user tokens.
class ChocoTurUser extends ChangeNotifier {
  static Future<ChocoTurUser> init() async {
    _prefs = await SharedPreferences.getInstance();

    return ChocoTurUser(
        userName: _prefs.getString(_userNameKey),
        language: _prefs.getString(_languageKey));
  }

  ChocoTurUser({String? userName, String? language})
      : _userName = userName,
        _language = language;

  // SharedPreferences info.
  static late final SharedPreferences _prefs;
  static const String _userNameKey = "userName";
  static const String _languageKey = "lang";
  static const String _tokenKey = "token";

  // User data.
  String? _userName;
  String? _language;
  Locale _locale = const Locale(LanguageCodes.EN);

  Locale get locale {
    if (_language != null) {
      _locale = Locale(_language!);
    }

    return _locale;
  }

  void setLanguage(BuildContext context, String lang) {
    if (_language != null && _language == lang) {
      LoggerInstance.logger.d(
          'Language set is equivalent to language saved in preferences ($lang).');
      return;
    }

    _language = lang;
    _locale = Locale(lang);
    _prefs.setString(_languageKey, lang);
    notifyListeners();
  }
}
