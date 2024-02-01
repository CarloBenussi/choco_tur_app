import 'package:choco_tur/services/facebook_login_service.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/services/google_login_service.dart';
import 'package:choco_tur/utils/lang_codes.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/widgets/generic_alert_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoginType {
  withGoogle,
  withFacebook,
  withApple,
}

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

    LoginType? loginType;
    bool loggedIn = false;

    int? loginTypeIndex = _prefs.getInt(_loginTypeIndexKey);
    String? loginToken = _prefs.getString(_loginTokenKey);
    if ((loginTypeIndex != null) && (loginToken != null)) {
      loginType = LoginType.values[loginTypeIndex];

      if (loginType == LoginType.withGoogle) {
        try {
          GoogleSignInAccount? account =
              await GoogleLoginService.signInWithGoogleWithToken(loginToken);
          loggedIn = (account != null);
        } catch (error) {
          LoggerInstance.logger.e(error);
        }
      } else if (loginType == LoginType.withFacebook) {
        FacebookLoginResult? res =
            await FacebookLoginService.signInWithFacebook();
        loggedIn = (res != null);
      } else {
        LoggerInstance.logger.e('Unsupported login type $loginType');
      }
    }

    return ChocoTurUser(
      loginEmail: _prefs.getString(_loginEmailKey),
      loginType: loginType,
      loggedIn: loggedIn,
      language: _prefs.getString(_languageKey),
      cameraPosition: cameraPosition,
      activeTourId: _prefs.getInt(_activeTourIdKey),
      tourNextStopId: _prefs.getInt(_tourNextStopIdKey),
      tourNextStopStoryPageIndex: _prefs.getInt(_tourNextStopStoryPageIndexKey),
    );
  }

  ChocoTurUser({
    this.loginEmail,
    this.loginType,
    required this.loggedIn,
    this.language,
    this.cameraPosition,
    this.activeTourId,
    this.tourNextStopId,
    this.tourNextStopStoryPageIndex,
  });

  // SharedPreferences keys.
  static const String _loginEmailKey = "email";
  static const String _loginTypeIndexKey = "loginType";
  static const String _loginTokenKey = "loginToken";
  static const String _languageKey = "lang";
  static const String _cameraLatituteKey = "cameraLatitute";
  static const String _cameraLongitudeKey = "cameraLongitude";
  static const String _cameraZoomKey = "cameraZoom";
  static const String _activeTourIdKey = "activeTourId";
  static const String _tourNextStopStoryPageIndexKey =
      "tourNextStopStoryPageIndex";
  static const String _tourNextStopIdKey = "tourNextStopId";

  // User preferences to store.
  String? loginEmail;
  LoginType? loginType;
  bool loggedIn;
  String? language;
  CameraPosition? cameraPosition;
  int? activeTourId;
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

  void setExtProviderLoginInfo(
    String email,
    String? accessToken,
    LoginType loginType,
  ) {
    _prefs.setString(_loginEmailKey, email);
    _prefs.setInt(_loginTypeIndexKey, loginType.index);
    if (accessToken != null) _prefs.setString(_loginTokenKey, accessToken);

    this.loginType = loginType;
    loggedIn = true;
    notifyListeners();
  }

  void setCameraPosition(CameraPosition position) {
    cameraPosition = position;
    _prefs.setDouble(_cameraLatituteKey, position.target.latitude);
    _prefs.setDouble(_cameraLongitudeKey, position.target.longitude);
    _prefs.setDouble(_cameraZoomKey, position.zoom);
    // notifyListeners(); Disabled since it is set on focus lost of map page.
  }

  Future<bool> activateTour(BuildContext context, int tourId) async {
    if (activeTourId == tourId) {
      LoggerInstance.logger
          .i("Activating a tour that is already active, nothing to do.");
      return false;
    }

    if (activeTourId != null) {
      LoggerInstance.logger
          .w("Activating a tour while there is one already active!");

      showDialog(
        context: context,
        builder: (_) => GenericAlertDialog(
          title: AppLocalizations.of(context)!.alreadyActive,
          content: AppLocalizations.of(context)!.alreadyActiveIndication,
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

    activeTourId = tourId;
    tourNextStopId = tourStopIds[0];
    _prefs.setInt(_activeTourIdKey, tourId);
    _prefs.setInt(_tourNextStopIdKey, tourStopIds[0]);
    notifyListeners();

    return true;
  }

  void deactivateTour(int tourId) {
    if (activeTourId != tourId) {
      LoggerInstance.logger.w('Tour $tourId is already unactive.');
      return;
    }

    activeTourId = null;
    tourNextStopId = null;
    _prefs.remove(_activeTourIdKey);
    _prefs.remove(_tourNextStopIdKey);
    notifyListeners();
  }

  Future<void> revertTourStop(BuildContext context) async {
    if (activeTourId == null) {
      throw Exception('No active tour present!');
    }

    SqliteCache cache = await SqliteCache.getInstance();
    List<int> tourStopIds = await cache.getTourStopIds(activeTourId!);
    if (tourStopIds.isEmpty) {
      throw Exception('No stops found for tour $activeTourId!');
    }

    var tourStopIndex = tourStopIds.indexOf(tourNextStopId!);
    if (--tourStopIndex < 0) {
      LoggerInstance.logger.i(
          'Tour $activeTourId is already at the first stop, cannot go back further.');

      // ignore: use_build_context_synchronously
      return showDialog(
        context: context,
        builder: (_) => GenericAlertDialog(
          title: AppLocalizations.of(context)!.cannotRevert,
          content: AppLocalizations.of(context)!.cannotRevertIndication,
        ),
        barrierDismissible: true,
      );
    }

    tourNextStopId = tourStopIds[tourStopIndex];
    tourNextStopStoryPageIndex = 0;
    _prefs.setInt(_tourNextStopIdKey, tourNextStopId!);
    _prefs.setInt(_tourNextStopStoryPageIndexKey, tourNextStopStoryPageIndex!);

    notifyListeners();
  }

  Future<void> advanceTour() async {
    if (activeTourId == null) {
      throw Exception('No active tour present!');
    }

    SqliteCache cache = await SqliteCache.getInstance();
    List<int> tourStopIds = await cache.getTourStopIds(activeTourId!);
    if (tourStopIds.isEmpty) {
      throw Exception('No stops found for tour $activeTourId!');
    }

    var tourStopIndex = tourStopIds.indexOf(tourNextStopId!);
    if (++tourStopIndex == tourStopIds.length) {
      LoggerInstance.logger.i(
          'Tour $activeTourId is finished, removing from active tours for user.');

      return deactivateTour(activeTourId!);
    }

    tourNextStopId = tourStopIds[tourStopIndex];
    tourNextStopStoryPageIndex = 0;
    _prefs.setInt(_tourNextStopIdKey, tourNextStopId!);
    _prefs.setInt(_tourNextStopStoryPageIndexKey, tourNextStopStoryPageIndex!);

    notifyListeners();
  }

  Future<void> logout() async {
    loginEmail = null;
    _prefs.remove(_loginEmailKey);
    _prefs.remove(_loginTokenKey);

    // Logout from Google if used.
    if (loginType == LoginType.withGoogle) {
      await GoogleLoginService.googleSignIn.signOut();
    } else if (loginType == LoginType.withFacebook) {
      await FacebookLoginService.facebookLogin.logOut();
    }
    _prefs.remove(_loginTypeIndexKey);
  }
}
