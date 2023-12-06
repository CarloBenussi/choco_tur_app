import 'package:choco_tur/services/SqliteCache.dart';
import 'package:choco_tur/utils/lang_codes.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChocoTurUser extends ChangeNotifier {
  static Future<ChocoTurUser> init() async {
    _prefs = await SharedPreferences.getInstance();

    CameraPosition? cameraPosition;
    if (_prefs.containsKey(_cameraLatituteKey) &&
        _prefs.containsKey(_cameraLongitudeKey) &&
        _prefs.containsKey(_cameraZoomKey)) {
      cameraPosition = CameraPosition(
        target: LatLng(
          _prefs.getDouble(_cameraLatituteKey)!,
          _prefs.getDouble(_cameraLongitudeKey)!,
        ),
        zoom: _prefs.getDouble(_cameraZoomKey)!,
      );
    }

    return ChocoTurUser(
      userName: _prefs.getString(_userNameKey),
      language: _prefs.getString(_languageKey),
      cameraPosition: cameraPosition,
      activeTours: _prefs.getStringList(_activeToursKey) ?? [],
      toursNextStopId: _prefs.getStringList(_toursNextStopIdKey) ?? [],
    );
  }

  ChocoTurUser({
    this.userName,
    this.language,
    this.cameraPosition,
    required this.activeTours,
    required this.toursNextStopId,
  });

  // SharedPreferences keys.
  static const String _userNameKey = "userName";
  static const String _languageKey = "lang";
  static const String _cameraLatituteKey = "cameraLatitute";
  static const String _cameraLongitudeKey = "cameraLongitude";
  static const String _cameraZoomKey = "cameraZoom";
  static const String _activeToursKey = "activeTours";
  static const String _toursNextStopIdKey = "toursNextStopId";
  static const String _tokenKey = "token";

  // User preferences to store.
  String? userName;
  String? language;
  CameraPosition? cameraPosition;
  List<String> activeTours;
  List<String> toursNextStopId;

  static late final SharedPreferences _prefs;
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

  void setCameraPosition(CameraPosition position) {
    cameraPosition = position;
    _prefs.setDouble(_cameraLatituteKey, position.target.latitude);
    _prefs.setDouble(_cameraLongitudeKey, position.target.longitude);
    _prefs.setDouble(_cameraZoomKey, position.zoom);
    notifyListeners();
  }

  void activateTour(int tourId) async {
    if (activeTours.contains(tourId.toString())) {
      LoggerInstance.logger.w('Tour $tourId is already active.');
      return;
    }

    SqliteCache cache = await SqliteCache.getInstance();
    List<String> tourStopIds = await cache.getTourStopIds(tourId);
    if (tourStopIds.isEmpty) {
      throw Exception('No stops found for tour $tourId!');
    }

    activeTours.add(tourId.toString());
    toursNextStopId.add(tourStopIds[0]);
    notifyListeners();
  }

  void deactivateTour(String tourId) {
    if (!activeTours.contains(tourId)) {
      LoggerInstance.logger.w('Tour $tourId is already unactive.');
      return;
    }

    int activeTourIndex = activeTours.indexOf(tourId);
    activeTours.removeAt(activeTourIndex);
    toursNextStopId.removeAt(activeTourIndex);
    notifyListeners();
  }

  void advanceTour(int tourId) async {
    var tourIndex = activeTours.indexOf(tourId.toString());
    if (tourIndex == -1) {
      throw Exception('Tour $tourId is not active!');
    }

    SqliteCache cache = await SqliteCache.getInstance();
    List<String> tourStopIds = await cache.getTourStopIds(tourId);
    if (tourStopIds.isEmpty) {
      throw Exception('No stops found for tour $tourId!');
    }

    var tourStopIndex = tourStopIds.indexOf(toursNextStopId[tourIndex]);
    if (++tourStopIndex == tourStopIds.length) {
      LoggerInstance.logger
          .i('Tour $tourId is finished, removing from active tours for user.');

      toursNextStopId.removeAt(tourIndex);
      activeTours.removeAt(tourIndex);
    }

    toursNextStopId[tourIndex] = tourStopIds[tourStopIndex];

    notifyListeners();
  }
}
