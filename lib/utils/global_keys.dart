// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

// NOTE: These keys are kind of an anti-pattern, use them only for the tutorial.
class GlobalKeys {
  static const String HOME_TOURS_TITLE_KEY = "homeToursTitleKey";
  static const String NAVIGATOR_HOME_BUTTON_KEY = "navigatorHomeButtonKey";
  static const String NAVIGATOR_MAP_BUTTON_KEY = "navigatorMapButtonKey";
  static const String NAVIGATOR_MYCHOCOTUR_BUTTON_KEY = "navigatorMyChocoTurButtonKey";
  static const String APP_BAR_DRAWER_KEY = "appBarDrawerKey";
  static const String APP_BAR_TOKENS_KEY = "appBarTokensKey";

  static Map<String, GlobalKey> globalKeysMap = <String, GlobalKey>{};
}
