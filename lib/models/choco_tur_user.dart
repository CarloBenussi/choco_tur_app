import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/services/app_review_service.dart';
import 'package:choco_tur/services/facebook_login_service.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/services/google_login_service.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/lang_codes.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/widgets/dialog.dart';
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
        var loginWithTokenResponse =
            await WebappService.loginUserWithToken(loginEmail, loginAccessToken, loginRefreshToken);
        if (loginWithTokenResponse != null) {
          loggedIn = true;
          // Copy eventually refreshed access token and refresh token.
          loginAccessToken = loginWithTokenResponse["accessToken"];
          _prefs.setString(_loginAccessTokenKey, loginAccessToken!);
          loginRefreshToken = loginWithTokenResponse["refreshToken"];
          _prefs.setString(_loginRefreshTokenKey, loginRefreshToken!);
        } else {
          LoggerInstance.logger.e("Failed to login with token.");
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

    bool hasSeenTutorial = (_prefs.getBool(_hasSeenTutorialKey) != null) ? _prefs.getBool(_hasSeenTutorialKey)! : false;

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

    List<ChocoTurUserTour>? userTours;
    List<ChocoTurUserQuiz>? userQuizs;
    if (loggedIn) {
      userTours = await WebappService.getUserTours(loginAccessToken);
      userQuizs = await WebappService.getUserQuizs(loginAccessToken);
    }

    return ChocoTurUser(
      loginEmail: loginEmail,
      loginAccessToken: loginAccessToken,
      loginRefreshToken: loginRefreshToken,
      loginType: loginType,
      loggedIn: loggedIn,
      hasSeenTutorial: hasSeenTutorial,
      language: _prefs.getString(_languageKey),
      cameraPosition: cameraPosition,
      userTours: userTours,
      userQuizs: userQuizs,
    );
  }

  ChocoTurUser({
    this.loginEmail,
    this.loginAccessToken,
    this.loginRefreshToken,
    this.loginType,
    required this.loggedIn,
    required this.hasSeenTutorial,
    this.language,
    this.cameraPosition,
    this.userTours,
    this.userQuizs,
  });

  // SharedPreferences keys.
  static const String _loginEmailKey = "email";
  static const String _loginTypeIndexKey = "loginType";
  static const String _loginAccessTokenKey = "loginAccessToken";
  static const String _loginRefreshTokenKey = "loginRefreshToken";
  static const String _hasSeenTutorialKey = "hasSeenTutorial";
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
  bool hasSeenTutorial;
  String? language;
  CameraPosition? cameraPosition;
  List<ChocoTurUserTour>? userTours;
  List<ChocoTurUserQuiz>? userQuizs;
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

    // We logged in, hence we can download user tours and quizzes.
    userTours = await WebappService.getUserTours(loginAccessToken);
    userQuizs = await WebappService.getUserQuizs(loginAccessToken);
    notifyListeners();
  }

  void setHasSeenTutorial() {
    hasSeenTutorial = true;
    _prefs.setBool(_hasSeenTutorialKey, true);
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

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.alreadyActive,
        description: AppLocalizations.of(context)!.alreadyActiveIndication,
        dismissable: true,
      );

      return false;
    }

    bool userTourActivationSuccess = await WebappService.activateUserTour(context, loginAccessToken, tour.id);
    if (!userTourActivationSuccess) {
      LoggerInstance.logger.e('Failed to activate tour ${tour.id} on webapp');
    }

    int userTourIndex = -1;
    if ((userTours == null) || (-1 == (userTourIndex = userTours!.indexWhere((element) => element.id == tour.id)))) {
      LoggerInstance.logger.d('No user tour found for ID ${tour.id}: creating it...');
      ChocoTurUserTour userTour = ChocoTurUserTour();
      userTour.id = tour.id;
      userTour.title = tour.title;
      userTour.progress = 0;
      userTours!.add(userTour);
      userTourIndex = userTours!.length - 1;
    }
    userTours!.elementAt(userTourIndex).isActive = true;
    userTours!.elementAt(userTourIndex).nextStopId = tour.stopIds[0];
    notifyListeners();

    return true;
  }

  Future<void> deactivateTour(BuildContext context, ChocoTurUserTour tour) async {
    if (activeTour == null) {
      LoggerInstance.logger.w('No active tour present for user.');
      return;
    }

    if (activeTour!.id != tour.id) {
      LoggerInstance.logger.w('Tour ${tour.id} is already unactive.');
      return;
    }

    bool userTourDeactivationSuccess = await WebappService.deactivateUserTour(context, loginAccessToken, tour.id);
    if (!userTourDeactivationSuccess) {
      LoggerInstance.logger.e('Failed to deactivate tour ${tour.id} on webapp');
    }
    userTours!.firstWhere((element) => element.id == tour.id).isActive = false;
    userTours!.firstWhere((element) => element.id == tour.id).nextStopId = "";
    userTours!.firstWhere((element) => element.id == tour.id).progress = 0;
    notifyListeners();
  }

  Future<void> advanceTour(BuildContext context, ChocoTurUserTour userTour, [bool skipOptions = false]) async {
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

    // Retrieve the current stop optional group if we want to skip the nexts.
    int? optionalGroupToSkip;
    if (skipOptions) {
      int currentStopIndex = tour.stopIds.indexOf(userTour.nextStopId);
      ChocoTurStop? currentStop = await cache.getTourStop(tour.id, tour.stopIds[currentStopIndex]);
      optionalGroupToSkip = currentStop!.optionalGroup;
    }

    int? nextStopOptionalGroup;
    do {
      var tourStopIndex = tour.stopIds.indexOf(userTour.nextStopId);
      if (++tourStopIndex == tour.stopIds.length) {
        LoggerInstance.logger.i('Tour ${userTour.id} is finished, removing from active tours for user.');

        // ignore: use_build_context_synchronously
        await AppReviewService.review(context);
        return deactivateTour(context, activeTour!);
      }

      bool userTourAdvanceSuccess = await WebappService.advanceUserTour(context, loginAccessToken, tour.id);
      if (!userTourAdvanceSuccess) {
        LoggerInstance.logger.e('Failed to advance tour ${tour.id} on webapp');
      }

      ChocoTurStop? nextStop = await cache.getTourStop(tour.id, tour.stopIds[tourStopIndex]);
      activeTour!.nextStopId = nextStop!.id;
      activeTour!.progress = tourStopIndex / tour.stopIds.length;
      nextStopOptionalGroup = nextStop.optionalGroup;
    } while ((optionalGroupToSkip != null) &&
        (nextStopOptionalGroup != null) &&
        (optionalGroupToSkip == nextStopOptionalGroup));

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
      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.cannotRevert,
        description: AppLocalizations.of(context)!.cannotRevertIndication,
        dismissable: true,
      );
    }

    bool userTourRevertSuccess = await WebappService.revertUserTour(context, loginAccessToken, tour.id);
    if (!userTourRevertSuccess) {
      LoggerInstance.logger.e('Failed to revert tour ${tour.id} on webapp');
    }
    activeTour!.nextStopId = tour.stopIds[tourStopIndex];
    activeTour!.progress = tourStopIndex / tour.stopIds.length;
    notifyListeners();
  }

  Future<void> logout() async {
    // Logout from ext provider if used.
    if (loginType == LoginType.withGoogle) {
      await GoogleLoginService.googleSignIn.signOut();
    } else if (loginType == LoginType.withFacebook) {
      await FacebookLoginService.facebookLogin.logOut();
    }

    loginEmail = null;
    loginAccessToken = null;
    loginRefreshToken = null;
    loggedIn = false;
    loginType = null;
    cameraPosition = null;
    userTours = null;
    userQuizs = null;
    _prefs.remove(_loginEmailKey);
    _prefs.remove(_loginAccessTokenKey);
    _prefs.remove(_loginRefreshTokenKey);
    _prefs.remove(_loginTypeIndexKey);
    _prefs.remove(_cameraLatituteKey);
    _prefs.remove(_cameraLongitudeKey);
    _prefs.remove(_cameraZoomKey);

    notifyListeners();
  }

  Future<void> delete(BuildContext context) async {
    bool success = await WebappService.deleteAccount(context, loginAccessToken);
    if (!success) {
      LoggerInstance.logger.e("Failed to delete user account");
      return;
    }

    // Logout from ext provider if used.
    if (loginType == LoginType.withGoogle) {
      await GoogleLoginService.googleSignIn.signOut();
    } else if (loginType == LoginType.withFacebook) {
      await FacebookLoginService.facebookLogin.logOut();
    }

    loginEmail = null;
    loginAccessToken = null;
    loginRefreshToken = null;
    loggedIn = false;
    loginType = null;
    cameraPosition = null;
    userTours = null;
    userQuizs = null;
    _prefs.remove(_loginEmailKey);
    _prefs.remove(_loginAccessTokenKey);
    _prefs.remove(_loginRefreshTokenKey);
    _prefs.remove(_loginTypeIndexKey);
    _prefs.remove(_cameraLatituteKey);
    _prefs.remove(_cameraLongitudeKey);
    _prefs.remove(_cameraZoomKey);

    notifyListeners();
  }
}

class ChocoTurUserTour {
  ChocoTurUserTour();

  late final String id;
  late final String title;
  late String nextStopId;
  late bool isActive;
  late double progress;

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

class ChocoTurUserQuiz {
  ChocoTurUserQuiz();

  late final String id;
  late double progress;
  late double score;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'progress': progress,
      'score': score,
    };
  }

  ChocoTurUserQuiz.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    progress = map['progress'];
    score = map['score'];
  }
}

class ChocoTurUserAnswer {
  ChocoTurUserAnswer();

  late final String id;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
    };
  }

  ChocoTurUserAnswer.fromMap(Map<String, dynamic> map) {
    id = map['id'];
  }
}

class ChocoTurUserPurchaseInfo {
  ChocoTurUserPurchaseInfo();

  late final String id;
  late final String offerId;
  late final bool redeemed;
  late final String purchaseTime;
  late final String expiryTime;
  late final int purchaseMethod;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'offerId': offerId,
      'redeemed': redeemed,
      'purchaseTime': purchaseTime,
      'expiryTime': expiryTime,
      'purchaseMethod': purchaseMethod,
    };
  }

  ChocoTurUserPurchaseInfo.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    offerId = map['offerId'];
    redeemed = map['redeemed'];
    purchaseTime = map['purchaseTime'];
    expiryTime = map['expiryTime'];
    purchaseMethod = map['purchaseMethod'];
  }
}
