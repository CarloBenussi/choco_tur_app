import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChocoTurModel extends ChangeNotifier {
  static init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static late final SharedPreferences _preferences;
}
