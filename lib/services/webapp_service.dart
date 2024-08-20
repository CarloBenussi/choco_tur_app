// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum HttpRequestMethod {
  get,
  post,
}

class WebappService {
  static const String webAppUrl = String.fromEnvironment('WEBAPP_URL');
  static const String registrationEndpoint = "/users/registration";
  static const String confirmEmailEndpoint = "/users/registrationConfirmation";
  static const String resendEmailVerificationNumberEndpoint = "/users/resendEmailVerificationNumber";
  static const String loginEndpoint = "/users/login";
  static const String loginWithTokenEndpoint = "/users/loginWithToken";
  static const String refreshTokenEndpoint = "/users/refreshToken";
  static const String resetPasswordEndpoint = "/users/resetPassword";
  static const String resetPasswordTestEndpoint = "/users/resetPasswordTest";
  static const String changePasswordEndpoint = "/users/changePassword";

  static const String userToursEndpoint = "/tours/userTours";
  static const String activateUserTourEndpoint = "/tours/activateUserTour";
  static const String deactivateUserTourEndpoint = "/tours/deactivateUserTour";
  static const String advanceUserTourEndpoint = "/tours/advanceUserTour";
  static const String revertUserTourEndpoint = "/tours/revertUserTour";
  static const String toursEndpoint = "/tours/tours";
  static const String tourStopsEndpoint = "/tours/tourStops";
  static const String tourStopStoriesEndpoint = "/tours/tourStopStories";

  static const String welcomeQuizEndpoint = "/quiz/welcome";
  static const String userQuizsEndpoint = "/quiz/userQuizs";
  static const String updateQuizScoreEndpoint = "/quiz/updateQuizScore";

  static const String tastingEndpoint = "/tastings/tasting";
  static const String tastingReviewEndpoint = "/tastings/review";

  static List<int> tokenExpiredStatusCodes = [401, 403];

  static HttpClient? _client;

  static Future<void> init() async {
    SecurityContext securityContext = SecurityContext.defaultContext;
    _client = HttpClient(context: securityContext);
    _client!.connectionTimeout = const Duration(seconds: 5);
    _client!.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }

  static Future<String?> registerUser(
    BuildContext context,
    String email,
    String password,
    String matchingPassword,
    String? dateOfBirth,
    String? nationality,
  ) async {
    Uri uri = _buildUri(registrationEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({
      'email': email,
      'password': password,
      'matchingPassword': matchingPassword,
      'dateOfBirth': dateOfBirth,
      'nationality': nationality,
    });
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    String responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      LoggerInstance.logger.e('Got error response for registration: ${response.statusCode}, $responseBody');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.registrationFailed,
        description: responseBody,
        dismissable: true,
      );

      return null;
    }

    // The returned body is the email verification number itself: return it so we can call "resendEmailVerificationNumber".
    return responseBody;
  }

  static Future<bool> confirmEmail(BuildContext context, String email, String numberSequence) async {
    var params = {
      'email': email,
      'number': numberSequence,
    };
    Uri uri = _buildUri(confirmEmailEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    HttpClientResponse response = await request.close();
    if (response.statusCode != 200) {
      String reason = await response.transform(utf8.decoder).join();
      LoggerInstance.logger.e('Got error response for email confirmation: ${response.statusCode}, $reason');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.registrationConfirmationFailed,
        description: reason,
        dismissable: true,
      );

      return false;
    }

    Map<String, dynamic> body = jsonDecode(await response.transform(utf8.decoder).join());
    Provider.of<ChocoTurUser>(context, listen: false).saveLoginInfo(
      email,
      body["accessToken"],
      body["refreshToken"],
      LoginType.manual,
      true,
    );
    return true;
  }

  static Future<String?> resendEmailVerificationCode(
    BuildContext context,
    String email,
    String number,
  ) async {
    var params = {
      'email': email,
      'number': number,
    };
    Uri uri = _buildUri(resendEmailVerificationNumberEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    HttpClientResponse response = await request.close();

    String responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      LoggerInstance.logger
          .e('Got error response for resend email verification code request:${response.statusCode}, $responseBody');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.resendEmailVerificaionCodeFailed,
        description: responseBody,
        dismissable: true,
      );

      return null;
    }

    // The returned body is the email verification number itself: return it so we can call "resendEmailVerificationNumber" again.
    return responseBody;
  }

  static Future<bool> loginUser(BuildContext context, String email, String password, bool rememberUser) async {
    Uri uri = _buildUri(loginEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({'email': email, 'password': password});
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    if (response.statusCode != 200) {
      String reason = await response.transform(utf8.decoder).join();
      LoggerInstance.logger.e('Got error response for registration: ${response.statusCode}, $reason');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.loginFailed,
        description: reason,
        dismissable: true,
      );

      return false;
    }

    Map<String, dynamic> returnBody = jsonDecode(await response.transform(utf8.decoder).join());
    Provider.of<ChocoTurUser>(context, listen: false).saveLoginInfo(
      email,
      returnBody["accessToken"],
      returnBody["refreshToken"],
      LoginType.manual,
      rememberUser,
    );

    return true;
  }

  static Future<dynamic> loginUserWithToken(String email, String accessToken, String? refreshToken) async {
    Uri uri = _buildUri(loginWithTokenEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({'email': email, 'accessToken': accessToken});
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    if (response.statusCode == 200) {
      LoggerInstance.logger.d("Login with token successful");

      return jsonDecode(await response.transform(utf8.decoder).join());
    } else if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.d("Expired access token, trying to use refresh token.");

      if (refreshToken == null) {
        LoggerInstance.logger.w("No refresh token save on user preferences.");
        return null;
      }

      return _refreshToken(email, refreshToken);
    } else {
      LoggerInstance.logger.e('Got error response for registration: ${response.statusCode}, ${response.reasonPhrase}');
      return null;
    }
  }

  static Future<bool> resetPassword(
    BuildContext context,
    String email,
  ) async {
    Uri uri = _buildUri(resetPasswordEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    request.add(utf8.encode(email));
    HttpClientResponse response = await request.close();

    String responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      LoggerInstance.logger.e('Got error response for password reset: ${response.statusCode}, $responseBody');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.passwordResetFailed,
        description: responseBody,
        dismissable: true,
      );

      return false;
    }

    return true;
  }

  static Future<bool> resetPasswordTest(BuildContext context, String email, String numberSequence) async {
    var params = {
      'email': email,
      'number': numberSequence,
    };
    Uri uri = _buildUri(resetPasswordTestEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    HttpClientResponse response = await request.close();
    if (response.statusCode != 200) {
      String reason = await response.transform(utf8.decoder).join();
      LoggerInstance.logger.e('Got error response for password reset test: ${response.statusCode}, $reason');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.passwordResetTestFailed,
        description: reason,
        dismissable: true,
      );

      return false;
    }

    return true;
  }

  static Future<bool> changePassword(
    BuildContext context,
    String email,
    String number,
    String password,
    String matchingPassword,
  ) async {
    Uri uri = _buildUri(changePasswordEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({
      'email': email,
      'passwordRecoveryNumber': number,
      'password': password,
      'matchingPassword': matchingPassword,
    });
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    String responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      LoggerInstance.logger.e('Got error response for password change: ${response.statusCode}, $responseBody');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.passwordChangeFailed,
        description: responseBody,
        dismissable: true,
      );

      return false;
    }

    return true;
  }

  static Future<List<ChocoTurTour>?> getTours(BuildContext context,
      {bool tryFromCache = true, bool saveToCache = true}) async {
    if (tryFromCache) {
      // Try from cache first.
      SqliteCache cache = await SqliteCache.getInstance();
      List<ChocoTurTour>? tours = await cache.getTours();
      if ((tours != null) && (tours.isNotEmpty)) {
        return tours;
      }
    }

    Uri uri = _buildUri(toursEndpoint);
    HttpClientRequest request = await _client!.getUrl(uri);
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      List<dynamic> tourMaps = jsonDecode(body)["tours"];
      List<ChocoTurTour> tours = [];
      for (var tourMap in tourMaps) {
        tours.add(ChocoTurTour.fromMap(tourMap));
      }

      if (saveToCache) {
        SqliteCache cache = await SqliteCache.getInstance();
        await cache.saveTours(tours);
      }

      return tours;
    } else {
      LoggerInstance.logger.e('Got error response for tours download: ${response.statusCode}, $body');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.tourInfoDownloadFailed,
        description: body,
        dismissable: true,
      );

      return null;
    }
  }

  static Future<List<ChocoTurUserTour>?> getUserTours(String? accessToken) async {
    Uri uri = _buildUri(userToursEndpoint);
    HttpClientRequest request = await _client!.getUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      List<dynamic> userTourMaps = jsonDecode(body);
      List<ChocoTurUserTour> userTours = [];
      for (var userTourMap in userTourMaps) {
        userTours.add(ChocoTurUserTour.fromMap(userTourMap));
      }
      return userTours;
    } else {
      LoggerInstance.logger.e('Got error response for user tours download: ${response.statusCode}, $body');
      return null;
    }
  }

  static Future<bool> activateUserTour(BuildContext context, String? accessToken, String tourId) async {
    Uri uri = _buildUri(activateUserTourEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    request.add(utf8.encode(tourId));
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse =
          await _redoRequestWithRefreshedToken(context, uri, HttpRequestMethod.post, tourId);
      if (newResponse == null) {
        LoggerInstance.logger.e("Failed to resend user tour activation request, redirecting user to login.");
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }

      response = newResponse!;
    }

    if (response.statusCode == 200) {
      return true;
    } else {
      LoggerInstance.logger.e('Got error response for user tour activation: ${response.statusCode}, $body');
      return false;
    }
  }

  static Future<bool> deactivateUserTour(BuildContext context, String? accessToken, String tourId) async {
    Uri uri = _buildUri(deactivateUserTourEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    request.add(utf8.encode(tourId));
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse =
          await _redoRequestWithRefreshedToken(context, uri, HttpRequestMethod.post, tourId);
      if (newResponse == null) {
        LoggerInstance.logger.e("Failed to resend user tour deactivation request, redirecting user to login.");
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }

      response = newResponse!;
    }

    if (response.statusCode == 200) {
      return true;
    } else {
      LoggerInstance.logger.e('Got error response for user tour deactivation: ${response.statusCode}, $body');
      return false;
    }
  }

  static Future<bool> advanceUserTour(BuildContext context, String? accessToken, String tourId) async {
    Uri uri = _buildUri(advanceUserTourEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    request.add(utf8.encode(tourId));
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse =
          await _redoRequestWithRefreshedToken(context, uri, HttpRequestMethod.post, tourId);
      if (newResponse == null) {
        LoggerInstance.logger.e("Failed to resend user tour advance request, redirecting user to login.");
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }

      response = newResponse!;
    }

    if (response.statusCode == 200) {
      return true;
    } else {
      LoggerInstance.logger.e('Got error response for user tour advance: ${response.statusCode}, $body');
      return false;
    }
  }

  static Future<bool> revertUserTour(BuildContext context, String? accessToken, String tourId) async {
    Uri uri = _buildUri(revertUserTourEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    request.add(utf8.encode(tourId));
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse =
          await _redoRequestWithRefreshedToken(context, uri, HttpRequestMethod.post, tourId);
      if (newResponse == null) {
        LoggerInstance.logger.e("Failed to resend user tour revert request, redirecting user to login.");
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }

      response = newResponse!;
    }

    if (response.statusCode == 200) {
      return true;
    } else {
      LoggerInstance.logger.e('Got error response for user tour revert: ${response.statusCode}, $body');
      return false;
    }
  }

  static Future<List<ChocoTurStop>?> getTourStops(BuildContext context, String tourId, String? accessToken,
      {bool tryFromCache = true, bool saveToCache = true}) async {
    if (tryFromCache) {
      // Try from cache first.
      SqliteCache cache = await SqliteCache.getInstance();
      List<ChocoTurStop>? tourStops = await cache.getTourStops(tourId);
      if (tourStops != null) {
        return tourStops;
      }
    }

    var params = {
      'tourId': tourId,
    };
    Uri uri = _buildUri(tourStopsEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse = await _redoRequestWithRefreshedToken(context, uri, HttpRequestMethod.get);
      if (newResponse == null) {
        LoggerInstance.logger.e("Failed to resend tours info download request, redirecting user to login.");
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }

      response = newResponse!;
    }

    if (response.statusCode == 200) {
      List<dynamic> tourStopMaps = jsonDecode(body);
      List<ChocoTurStop> tourStops = [];
      for (var tourStopMap in tourStopMaps) {
        tourStops.add(ChocoTurStop.fromMap(tourStopMap));
      }

      if (saveToCache) {
        SqliteCache cache = await SqliteCache.getInstance();
        await cache.saveTourStops(tourStops);
      }

      return tourStops;
    } else {
      LoggerInstance.logger.e('Got error response for tour stops download: ${response.statusCode}, $body');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.tourStopDownloadFailed,
        description: body,
        dismissable: true,
      );

      return null;
    }
  }

  static Future<List<ChocoTurStopStory>?> getTourStopStories(
      BuildContext context, String stopId, String? accessToken) async {
    var params = {
      'stopId': stopId,
    };
    Uri uri = _buildUri(tourStopStoriesEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse = await _redoRequestWithRefreshedToken(context, uri, HttpRequestMethod.get);
      if (newResponse == null) {
        LoggerInstance.logger.e("Failed to resend tour stop stories download request, redirecting user to login.");
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }

      response = newResponse!;
    }

    if (response.statusCode == 200) {
      List<dynamic> tourStopStoryMaps = jsonDecode(body);
      List<ChocoTurStopStory> tourStopStories = [];
      for (var tourStopStoryMap in tourStopStoryMaps) {
        tourStopStories.add(ChocoTurStopStory.fromMap(tourStopStoryMap));
      }
      tourStopStories.sort((a, b) => a.index.compareTo(b.index));
      return tourStopStories;
    } else {
      LoggerInstance.logger.e('Got error response for tour stop stories download: ${response.statusCode}, $body');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.tourStopStoriesDownloadFailed,
        description: body,
        dismissable: true,
      );

      return null;
    }
  }

  static Future<ChocoTurQuiz?> getWelcomeQuiz(BuildContext context, String? accessToken) async {
    Uri uri = _buildUri(welcomeQuizEndpoint);
    HttpClientRequest request = await _client!.getUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse = await _redoRequestWithRefreshedToken(context, uri, HttpRequestMethod.get);
      if (newResponse == null) {
        LoggerInstance.logger.e("Failed to resend welcome quiz download request, redirecting user to login.");
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }

      response = newResponse!;
    }

    if (response.statusCode == 200) {
      dynamic quizMap = jsonDecode(body);
      return ChocoTurQuiz.fromMap(quizMap);
    } else {
      LoggerInstance.logger.e('Got error response for welcome quiz download: ${response.statusCode}, $body');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.welcomeQuizDownloadFailed,
        description: body,
        dismissable: true,
      );

      return null;
    }
  }

  static Future<List<ChocoTurUserQuiz>?> getUserQuizs(String? accessToken) async {
    Uri uri = _buildUri(userQuizsEndpoint);
    HttpClientRequest request = await _client!.getUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      List<dynamic> userQuizMaps = jsonDecode(body);
      List<ChocoTurUserQuiz> userQuizs = [];
      for (var userQuizMap in userQuizMaps) {
        userQuizs.add(ChocoTurUserQuiz.fromMap(userQuizMap));
      }
      return userQuizs;
    } else {
      LoggerInstance.logger.e('Got error response for user quizs download: ${response.statusCode}, $body');
      return null;
    }
  }

  static Future<bool> updateQuizScore(
      BuildContext context, String? accessToken, String quizId, int questionIndex, bool correct) async {
    Uri uri = _buildUri(updateQuizScoreEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({'quizId': quizId, 'questionIndex': questionIndex, 'correct': correct});
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse =
          await _redoRequestWithRefreshedToken(context, uri, HttpRequestMethod.post, body);
      if (newResponse == null) {
        LoggerInstance.logger.e("Failed to resend quiz score upload, redirecting user to login.");
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }

      response = newResponse!;
    }

    if (response.statusCode == 200) {
      LoggerInstance.logger.d("Update quiz $quizId score successful");
      return true;
    } else {
      LoggerInstance.logger.e('Got error response for quiz  update: ${response.statusCode}, $body');
      return false;
    }
  }

  static Future<ChocoTurTasting?> getTasting(BuildContext context, String? accessToken, String tastingId) async {
    var params = {
      'tastingId': tastingId,
    };
    Uri uri = _buildUri(tastingEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse = await _redoRequestWithRefreshedToken(context, uri, HttpRequestMethod.get);
      if (newResponse == null) {
        LoggerInstance.logger.e("Failed to resend tasting download request, redirecting user to login.");
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }

      response = newResponse!;
    }

    if (response.statusCode == 200) {
      dynamic tastingMap = jsonDecode(body);
      return ChocoTurTasting.fromMap(tastingMap);
    } else {
      LoggerInstance.logger.e('Got error response for tasting download: ${response.statusCode}, $body');

      showChocoTurDialog(
        context: context,
        title: AppLocalizations.of(context)!.tastingDownloadFailed,
        description: body,
        dismissable: true,
      );

      return null;
    }
  }

  static Future<bool> reviewTasting(
      BuildContext context, String? accessToken, String email, String tastingId, double score) async {
    Uri uri = _buildUri(tastingReviewEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({'email': email, 'tastingId': tastingId, 'score': score});
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse =
          await _redoRequestWithRefreshedToken(context, uri, HttpRequestMethod.post, body);
      if (newResponse == null) {
        LoggerInstance.logger.e("Failed to resend tasting review, redirecting user to login.");
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }

      response = newResponse!;
    }

    if (response.statusCode == 200) {
      LoggerInstance.logger.d("Review tasting $tastingId score successful");
      return true;
    } else {
      LoggerInstance.logger.e('Got error response for tasting review: ${response.statusCode}, $body');
      return false;
    }
  }

  /*---------------------------------------------------------------------------*/

  static Uri _buildUri(String endpoint, [dynamic params]) {
    bool ssl = const bool.fromEnvironment('SSL_ENABLED');
    if (ssl) {
      return Uri.https(webAppUrl, endpoint, params);
    } else {
      return Uri.http(webAppUrl, endpoint, params);
    }
  }

  static Future<HttpClientResponse?> _redoRequestWithRefreshedToken(
      BuildContext context, Uri uri, HttpRequestMethod method,
      [String? body]) async {
    String? email = Provider.of<ChocoTurUser>(context, listen: false).loginEmail;
    String? refreshToken = Provider.of<ChocoTurUser>(context, listen: false).loginRefreshToken;
    if ((email == null) || (refreshToken == null)) {
      LoggerInstance.logger.e("No email or refresh token stored for user, cannot download tours info.");
      return null;
    }

    var refreshResponse = await _refreshToken(email, refreshToken);
    if (refreshResponse == null) {
      LoggerInstance.logger.e("Failed to refresh user token.");
      return null;
    }

    // Save refreshed user tokens.
    Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken = refreshResponse["accessToken"];
    Provider.of<ChocoTurUser>(context, listen: false).loginRefreshToken = refreshResponse["refreshToken"];

    // Redo request.
    HttpClientRequest newRequest =
        (method == HttpRequestMethod.get) ? await _client!.getUrl(uri) : await _client!.postUrl(uri);
    if (method == HttpRequestMethod.post) newRequest.add(utf8.encode(body!));
    newRequest.headers
        .set('Authorization', "Bearer ${Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken}");
    return await newRequest.close();
  }

  static Future<dynamic> _refreshToken(String email, String refreshToken) async {
    var params = {
      'email': email,
      'refreshToken': refreshToken,
    };
    Uri uri = _buildUri(refreshTokenEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      LoggerInstance.logger.w('Got error response for refresh token: ${response.statusCode}, $body');
      return null;
    }

    return jsonDecode(body);
  }
}
