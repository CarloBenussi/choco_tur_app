import 'package:choco_tur/utils/lang_codes.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ChocoTurUser extends ChangeNotifier {
  static Future<ChocoTurUser> init() async {
    _database = await openDatabase(
      // Set the path to the database.
      join(await getDatabasesPath(), 'example.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
            'CREATE TABLE $_userTable (id INTEGER PRIMARY KEY, $_userNameEntry TEXT, $_languageEntry TEXT)');
      },
    );

    final List<Map<String, dynamic>> users = await _database.query(_userTable);
    if (users.length > 1) {
      throw Exception('Multiple users present on database (num=$users.length)');
    }
    if (users.isEmpty) {
      LoggerInstance.logger
          .i("No users found on database, returning default ChocoTurUser.");
      return ChocoTurUser();
    }

    Map<String, dynamic> user = users[0];
    return ChocoTurUser(
        userName: user[_userNameEntry], language: user[_languageEntry]);
  }

  ChocoTurUser({String? userName, String? language})
      : _userName = userName,
        _language = language;

  // Database info.
  static late final Database _database;
  static const String _userTable = "user";
  static const String _userNameEntry = "userName";
  static const String _languageEntry = "lang";

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
    notifyListeners();
  }
}
