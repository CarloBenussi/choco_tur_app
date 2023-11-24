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

  ChocoTurUser({this.userName, this.language});

  // SharedPreferences info.
  static late final SharedPreferences _prefs;
  static const String _userNameKey = "userName";
  static const String _languageKey = "lang";
  static const String _tokenKey = "token";

  // User data.
  String? userName;
  String? language;
  Locale _locale = const Locale(LanguageCodes.EN);

  Locale get locale {
    if (language != null) {
      _locale = Locale(language!);
    }

    return _locale;
  }

  void setLanguage(BuildContext context, String lang) {
    if (language != null && language == lang) {
      LoggerInstance.logger.d(
          'Language set is equivalent to language saved in preferences ($lang).');
      return;
    }

    language = lang;
    _locale = Locale(lang);
    _prefs.setString(_languageKey, lang);
    notifyListeners();
  }

  void setUserName(BuildContext context, String userName) {
    userName = userName;
    _prefs.setString(_userNameKey, userName);
    notifyListeners();
  }
}
