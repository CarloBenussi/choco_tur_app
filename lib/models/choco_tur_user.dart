import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/services/facebook_login_service.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/services/google_login_service.dart';
import 'package:choco_tur/services/webapp_service.dart';
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
  manual,
  withGoogle,
  withFacebook,
  withApple,
}

class ChocoTurUser extends ChangeNotifier {
  static Future<ChocoTurUser> init() async {
    _prefs = await SharedPreferences.getInstance();

    LoginType? loginType;
    bool loggedIn = false;

    int? loginTypeIndex = _prefs.getInt(_loginTypeIndexKey);
    String? loginEmail = _prefs.getString(_loginEmailKey);
    String? loginAccessToken = _prefs.getString(_loginAccessTokenKey);
    String? loginRefreshToken = _prefs.getString(_loginRefreshTokenKey);
    if ((loginTypeIndex != null) && (loginEmail != null) && (loginAccessToken != null)) {
      loginType = LoginType.values[loginTypeIndex];

      if (loginType == LoginType.manual) {
        String? loginWithTokenResponse =
            await WebappService.loginUserWithToken(loginEmail, loginAccessToken, loginRefreshToken);
        if (loginWithTokenResponse != null) {
          loggedIn = true;
          // Copy eventually refreshed access token.
          loginAccessToken = loginWithTokenResponse;
          _prefs.setString(_loginAccessTokenKey, loginWithTokenResponse);
        }
      } else if (loginType == LoginType.withGoogle) {
        try {
          GoogleSignInAccount? account =
              await GoogleLoginService.signInWithGoogleWithToken(loginEmail, loginAccessToken);
          loggedIn = (account != null);
        } catch (error) {
          LoggerInstance.logger.e(error);
        }
      } else if (loginType == LoginType.withFacebook) {
        FacebookLoginResult? res = await FacebookLoginService.signInWithFacebook();
        loggedIn = (res != null);
      } else {
        LoggerInstance.logger.e('Unsupported login type $loginType');
      }
    }

    List<ChocoTurUserTour>? userTours;
    if (loggedIn) {
      userTours = await WebappService.getUserTours(loginAccessToken);
    }

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
      loginEmail: loginEmail,
      loginAccessToken: loginAccessToken,
      loginRefreshToken: loginRefreshToken,
      loginType: loginType,
      loggedIn: loggedIn,
      language: _prefs.getString(_languageKey),
      cameraPosition: cameraPosition,
      userTours: userTours,
    );
  }

  ChocoTurUser({
    this.loginEmail,
    this.loginAccessToken,
    this.loginRefreshToken,
    this.loginType,
    required this.loggedIn,
    this.language,
    this.cameraPosition,
    this.userTours,
  });

  // SharedPreferences keys.
  static const String _loginEmailKey = "email";
  static const String _loginTypeIndexKey = "loginType";
  static const String _loginAccessTokenKey = "loginAccessToken";
  static const String _loginRefreshTokenKey = "loginRefreshToken";
  static const String _languageKey = "lang";
  static const String _cameraLatituteKey = "cameraLatitute";
  static const String _cameraLongitudeKey = "cameraLongitude";
  static const String _cameraZoomKey = "cameraZoom";

  // User preferences to store.
  String? loginEmail;
  String? loginAccessToken;
  String? loginRefreshToken;
  LoginType? loginType;
  bool loggedIn;
  String? language;
  CameraPosition? cameraPosition;
  List<ChocoTurUserTour>? userTours;
  static late final SharedPreferences _prefs;

  Locale _locale = const Locale(LanguageCodes.EN);

  Locale get locale {
    if (language != null) {
      _locale = Locale(language!);
    }

    return _locale;
  }

  ChocoTurUserTour? get activeTour {
    if (userTours == null) {
      LoggerInstance.logger.d('No tours found for user');
      return null;
    }

    for (var userTour in userTours!) {
      if (userTour.isActive) {
        return userTour;
      }
    }

    LoggerInstance.logger.d('No active tour found among ${userTours!.length} tours for user');
    return null;
  }

  void setLanguage(BuildContext context, String lang) {
    if (language != null && language == lang) {
      LoggerInstance.logger.d('Language set is equivalent to language saved in preferences ($lang).');
      return;
    }

    language = lang;
    _locale = Locale(lang);
    _prefs.setString(_languageKey, lang);
    notifyListeners();
  }

  void saveLoginInfo(
    String email,
    String? accessToken,
    String? refreshToken,
    LoginType loginType,
    bool rememberUser,
  ) async {
    loginEmail = email;
    loginAccessToken = accessToken;
    loginRefreshToken = refreshToken;
    this.loginType = loginType;
    loggedIn = true;

    if (rememberUser) {
      _prefs.setString(_loginEmailKey, email);
      _prefs.setInt(_loginTypeIndexKey, loginType.index);
      if (accessToken != null) {
        _prefs.setString(_loginAccessTokenKey, accessToken);
      }
      if (refreshToken != null) {
        _prefs.setString(_loginRefreshTokenKey, refreshToken);
      }
    }

    // We logged in, hence we can download user tours.
    userTours = await WebappService.getUserTours(loginAccessToken);
    notifyListeners();
  }

  void setCameraPosition(CameraPosition position) {
    cameraPosition = position;
    _prefs.setDouble(_cameraLatituteKey, position.target.latitude);
    _prefs.setDouble(_cameraLongitudeKey, position.target.longitude);
    _prefs.setDouble(_cameraZoomKey, position.zoom);
    // notifyListeners(); Disabled since it is set on focus lost of map page.
  }

  Future<bool> activateTour(BuildContext context, ChocoTurTour tour) async {
    if (activeTour != null) {
      if (activeTour!.id == tour.id) {
        LoggerInstance.logger.i("Activating a tour that is already active, nothing to do.");
        return false;
      }

      LoggerInstance.logger.w("Activating a tour while there is a different one already active!");

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

    int userTourIndex = -1;
    if ((userTours == null) || (-1 == (userTourIndex = userTours!.indexWhere((element) => element.id == tour.id)))) {
      LoggerInstance.logger.e('No user tour found for ID ${tour.id}');
      return false;
    }

    // TODO: Activate tour on webapp.
    userTours!.elementAt(userTourIndex).isActive = true;
    notifyListeners();

    return true;
  }

  Future<void> deactivateTour(ChocoTurUserTour tour) async {
    if (activeTour == null) {
      LoggerInstance.logger.w('No active tour present for user.');
      return;
    }

    if (activeTour!.id != tour.id) {
      LoggerInstance.logger.w('Tour ${tour.id} is already unactive.');
      return;
    }

    // TODO: Deactivate tour on webapp.
    userTours!.firstWhere((element) => element.id == tour.id).isActive = false;
    notifyListeners();
  }

  Future<void> revertTourStop(BuildContext context, ChocoTurUserTour userTour) async {
    if (activeTour == null) {
      throw Exception('No active tour present!');
    }

    if (activeTour!.id != userTour.id) {
      throw Exception('Tour ${userTour.id} is not active');
    }

    SqliteCache cache = await SqliteCache.getInstance();
    ChocoTurTour? tour = await cache.getTourFromId(userTour.id);
    if (tour == null) {
      throw Exception('No tour on cache for ID ${userTour.id}');
    }

    var tourStopIndex = tour.stopIds.indexOf(userTour.nextStopId);
    if (--tourStopIndex < 0) {
      LoggerInstance.logger.i('Tour ${userTour.id} is already at the first stop, cannot go back further.');

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (_) => GenericAlertDialog(
          title: AppLocalizations.of(context)!.cannotRevert,
          content: AppLocalizations.of(context)!.cannotRevertIndication,
        ),
        barrierDismissible: true,
      );
    }

    // TODO: Revert tour stop on webapp.
    activeTour!.nextStopId = tour.stopIds[tourStopIndex];
    notifyListeners();
  }

  Future<void> advanceTour(ChocoTurUserTour userTour) async {
    if (activeTour == null) {
      throw Exception('No active tour present!');
    }

    if (activeTour!.id != userTour.id) {
      throw Exception('Tour ${userTour.id} is not active');
    }

    SqliteCache cache = await SqliteCache.getInstance();
    ChocoTurTour? tour = await cache.getTourFromId(userTour.id);
    if (tour == null) {
      throw Exception('No tour on cache for ID ${userTour.id}');
    }

    var tourStopIndex = tour.stopIds.indexOf(userTour.nextStopId);
    if (++tourStopIndex == tour.stopIds.length) {
      LoggerInstance.logger.i('Tour ${userTour.id} is finished, removing from active tours for user.');

      return deactivateTour(activeTour!);
    }

    // TODO: Advance tour on webapp.
    activeTour!.nextStopId = tour.stopIds[tourStopIndex];
    notifyListeners();
  }

  Future<void> logout() async {
    loginEmail = null;
    _prefs.remove(_loginEmailKey);
    _prefs.remove(_loginAccessTokenKey);

    // Logout from Google if used.
    if (loginType == LoginType.withGoogle) {
      await GoogleLoginService.googleSignIn.signOut();
    } else if (loginType == LoginType.withFacebook) {
      await FacebookLoginService.facebookLogin.logOut();
    }
    _prefs.remove(_loginTypeIndexKey);
  }
}

class ChocoTurUserTour {
  ChocoTurUserTour();

  late final String id;
  late final String title;
  late final String nextStopId;
  late final bool isActive;
  late final double progress;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'nextStopId': nextStopId,
      'active': isActive,
      'progress': progress,
    };
  }

  ChocoTurUserTour.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    nextStopId = map['nextStopId'];
    isActive = map['active'];
    progress = map['progress'];
  }
}
