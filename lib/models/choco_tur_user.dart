import 'package:choco_tur/services/sqlite_cache.dart';
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
      activeTour: _prefs.getInt(_activeTourKey),
      tourNextStopId: _prefs.getInt(_tourNextStopIdKey),
      tourNextStopStoryPageIndex: _prefs.getInt(_tourNextStopStoryPageIndexKey),
    );
  }

  ChocoTurUser({
    this.userName,
    this.language,
    this.cameraPosition,
    required this.activeTour,
    required this.tourNextStopId,
    required this.tourNextStopStoryPageIndex,
  });

  // SharedPreferences keys.
  static const String _userNameKey = "userName";
  static const String _languageKey = "lang";
  static const String _cameraLatituteKey = "cameraLatitute";
  static const String _cameraLongitudeKey = "cameraLongitude";
  static const String _cameraZoomKey = "cameraZoom";
  static const String _activeTourKey = "activeTour";
  static const String _tourNextStopStoryPageIndexKey =
      "tourNextStopStoryPageIndex";
  static const String _tourNextStopIdKey = "tourNextStopId";
  static const String _tokenKey = "token";

  // User preferences to store.
  String? userName;
  String? language;
  CameraPosition? cameraPosition;
  int? activeTour;
  int? tourNextStopId;
  int? tourNextStopStoryPageIndex;

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

  Future<bool> activateTour(BuildContext context, int tourId) async {
    if (activeTour == tourId) {
      LoggerInstance.logger
          .i("Activating a tour that is already active, nothing to do.");
      return false;
    }

    if (activeTour != null) {
      LoggerInstance.logger
          .w("Activating a tour while there is one already active!");

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("A choco tour is already active!"),
          content:
              Text("To activate a new tour, complete first the active tour."),
          elevation: 24.0,
        ),
        barrierDismissible: true,
      );
      return false;
    }

    SqliteCache cache = await SqliteCache.getInstance();
    List<int> tourStopIds = await cache.getTourStopIds(tourId);
    if (tourStopIds.isEmpty) {
      throw Exception('No stops found for tour $tourId!');
    }

    activeTour = tourId;
    tourNextStopId = tourStopIds[0];
    _prefs.setInt(_activeTourKey, tourId);
    _prefs.setInt(_tourNextStopIdKey, tourStopIds[0]);
    notifyListeners();

    return true;
  }

  void deactivateTour(int tourId) {
    if (activeTour != tourId) {
      LoggerInstance.logger.w('Tour $tourId is already unactive.');
      return;
    }

    activeTour = null;
    tourNextStopId = null;
    _prefs.remove(_activeTourKey);
    _prefs.remove(_tourNextStopIdKey);
    notifyListeners();
  }

  void advanceTour(int tourId) async {
    if (activeTour != tourId) {
      throw Exception('Tour $tourId is not active!');
    }

    SqliteCache cache = await SqliteCache.getInstance();
    List<int> tourStopIds = await cache.getTourStopIds(tourId);
    if (tourStopIds.isEmpty) {
      throw Exception('No stops found for tour $tourId!');
    }

    var tourStopIndex = tourStopIds.indexOf(tourNextStopId!);
    if (++tourStopIndex == tourStopIds.length) {
      LoggerInstance.logger
          .i('Tour $tourId is finished, removing from active tours for user.');

      _prefs.remove(_activeTourKey);
      _prefs.remove(_tourNextStopIdKey);
    }

    tourNextStopId = tourStopIds[tourStopIndex];
    _prefs.setInt(_tourNextStopIdKey, tourNextStopId!);

    notifyListeners();
  }
}
