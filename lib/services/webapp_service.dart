// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/widgets/generic_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WebappService {
  static const String webAppUrl = String.fromEnvironment('WEBAPP_URL');
  static const String registrationEndpoint = "/users/registration";
  static const String confirmEmailEndpoint = "/users/registrationConfirmation";
  static const String loginEndpoint = "/users/login";
  static const String loginWithTokenEndpoint = "/users/loginWithToken";
  static const String refreshTokenEndpoint = "/users/refreshToken";

  static const String userToursEndpoint = "/tours/userTours";
  static const String activateUserTourEndpoint = "/tours/activateUserTour";
  static const String deactivateUserTourEndpoint = "/tours/deactivateUserTour";
  static const String advanceUserTourEndpoint = "/tours/advanceUserTour";
  static const String revertUserTourEndpoint = "/tours/revertUserTour";
  static const String toursEndpoint = "/tours/tours";
  static const String tourStopsEndpoint = "/tours/tourStops";
  static const String tourStopStoriesEndpoint = "/tours/tourStopStories";

  static List<int> tokenExpiredStatusCodes = [401, 403];

  static HttpClient? _client;

  static Future<void> init() async {
    SecurityContext securityContext = SecurityContext.defaultContext;
    ByteData data = await rootBundle.load("assets/keystore/chocotur.p12");
    securityContext.setTrustedCertificatesBytes(
      data.buffer.asUint8List(),
      password: const String.fromEnvironment('HTTPS_KEYSTORE_PASSWORD'),
    );
    _client = HttpClient(context: securityContext);
    _client!.connectionTimeout = const Duration(seconds: 5);
    _client!.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }

  static Future<bool> registerUser(
    BuildContext context,
    String email,
    String password,
    String matchingPassword,
    String? dateOfBirth,
    String? nationality,
  ) async {
    Uri uri = Uri.https(webAppUrl, registrationEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({
      'email': email,
      'password': password,
      'dateOfBirth': dateOfBirth,
      'nationality': nationality,
    });
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    if (response.statusCode != 200) {
      String reason = await response.transform(utf8.decoder).join();
      LoggerInstance.logger.e('Got error response for registration: ${response.statusCode}, $reason');

      showDialog(
        context: context,
        builder: (_) => GenericAlertDialog(
          title: AppLocalizations.of(context)!.registrationFailed,
          content: reason,
        ),
        barrierDismissible: true,
      );

      return false;
    }

    return true;
  }

  static Future<bool> confirmEmail(BuildContext context, String email, String numberSequence) async {
    var params = {
      'email': email,
      'number': numberSequence,
    };
    Uri uri = Uri.https(webAppUrl, confirmEmailEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    HttpClientResponse response = await request.close();
    if (response.statusCode != 200) {
      String reason = await response.transform(utf8.decoder).join();
      LoggerInstance.logger.e('Got error response for email confirmation: ${response.statusCode}, $reason');

      showDialog(
        context: context,
        builder: (_) => GenericAlertDialog(
          title: AppLocalizations.of(context)!.registrationConfirmationFailed,
          content: reason,
        ),
        barrierDismissible: true,
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

  static Future<bool> loginUser(BuildContext context, String email, String password, bool rememberUser) async {
    Uri uri = Uri.https(webAppUrl, loginEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({'email': email, 'password': password});
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    if (response.statusCode != 200) {
      String reason = await response.transform(utf8.decoder).join();
      LoggerInstance.logger.e('Got error response for registration: ${response.statusCode}, $reason');

      showDialog(
        context: context,
        builder: (_) => GenericAlertDialog(
          title: AppLocalizations.of(context)!.loginFailed,
          content: reason,
        ),
        barrierDismissible: true,
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

  static Future<String?> loginUserWithToken(String email, String accessToken, String? refreshToken) async {
    Uri uri = Uri.https(webAppUrl, loginWithTokenEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({'email': email, 'accessToken': accessToken});
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    if (response.statusCode == 200) {
      LoggerInstance.logger.d("Login with token successful");

      return accessToken;
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

  static Future<List<ChocoTurTour>?> getTours(BuildContext context) async {
    Uri uri = Uri.https(webAppUrl, toursEndpoint);
    HttpClientRequest request = await _client!.getUrl(uri);
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      List<dynamic> tourMaps = jsonDecode(body)["tours"];
      List<ChocoTurTour> tours = [];
      for (var tourMap in tourMaps) {
        tours.add(ChocoTurTour.fromMap(tourMap));
      }
      return tours;
    } else {
      LoggerInstance.logger.e('Got error response for tours download: ${response.statusCode}, $body');

      showDialog(
        context: context,
        builder: (_) => GenericAlertDialog(
          title: AppLocalizations.of(context)!.tourInfoDownloadFailed,
          content: body,
        ),
        barrierDismissible: true,
      );

      return null;
    }
  }

  static Future<List<ChocoTurUserTour>?> getUserTours(String? accessToken) async {
    Uri uri = Uri.https(webAppUrl, userToursEndpoint);
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
    Uri uri = Uri.https(webAppUrl, activateUserTourEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    request.add(utf8.encode(tourId));
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse = await _redoRequestWithRefreshedToken(context, request);
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
    Uri uri = Uri.https(webAppUrl, deactivateUserTourEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    request.add(utf8.encode(tourId));
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse = await _redoRequestWithRefreshedToken(context, request);
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
    Uri uri = Uri.https(webAppUrl, advanceUserTourEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    request.add(utf8.encode(tourId));
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse = await _redoRequestWithRefreshedToken(context, request);
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
    Uri uri = Uri.https(webAppUrl, revertUserTourEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    request.add(utf8.encode(tourId));
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse = await _redoRequestWithRefreshedToken(context, request);
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

  static Future<List<ChocoTurStop>?> getTourStops(BuildContext context, String tourId, String? accessToken) async {
    var params = {
      'tourId': tourId,
    };
    Uri uri = Uri.https(webAppUrl, tourStopsEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse = await _redoRequestWithRefreshedToken(context, request);
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
      return tourStops;
    } else {
      LoggerInstance.logger.e('Got error response for tour stops download: ${response.statusCode}, $body');

      showDialog(
        context: context,
        builder: (_) => GenericAlertDialog(
          title: AppLocalizations.of(context)!.tourStopDownloadFailed,
          content: body,
        ),
        barrierDismissible: true,
      );

      return null;
    }
  }

  static Future<List<ChocoTurStopStory>?> getTourStopStories(
      BuildContext context, String stopId, String? accessToken) async {
    var params = {
      'stopId': stopId,
    };
    Uri uri = Uri.https(webAppUrl, tourStopStoriesEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    request.headers.set('Authorization', "Bearer $accessToken");
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (tokenExpiredStatusCodes.contains(response.statusCode)) {
      LoggerInstance.logger.e("User access token expired, refreshing token and re-doing request.");
      HttpClientResponse? newResponse = await _redoRequestWithRefreshedToken(context, request);
      if (newResponse == null) {
        LoggerInstance.logger.e("Failed to resend tours info download request, redirecting user to login.");
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
      return tourStopStories;
    } else {
      LoggerInstance.logger.e('Got error response for tour stop stories download: ${response.statusCode}, $body');

      showDialog(
        context: context,
        builder: (_) => GenericAlertDialog(
          title: AppLocalizations.of(context)!.tourStopStoriesDownloadFailed,
          content: body,
        ),
        barrierDismissible: true,
      );

      return null;
    }
  }

  static Future<HttpClientResponse?> _redoRequestWithRefreshedToken(
      BuildContext context, HttpClientRequest request) async {
    String? email = Provider.of<ChocoTurUser>(context, listen: false).loginEmail;
    String? refreshToken = Provider.of<ChocoTurUser>(context, listen: false).loginRefreshToken;
    if ((email == null) || (refreshToken == null)) {
      LoggerInstance.logger.e("No email or refresh token stored for user, cannot download tours info.");
      return null;
    }

    String? newAccessToken = await _refreshToken(email, refreshToken);
    if (newAccessToken != null) {
      LoggerInstance.logger.e("Failed to refresh user token.");
      return null;
    }

    // Save refreshed user token.
    Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken = newAccessToken;

    // Redo request.
    request.headers.set('Authorization', "Bearer $newAccessToken");
    return await request.close();
  }

  static Future<String?> _refreshToken(String email, String refreshToken) async {
    var params = {
      'email': email,
      'refreshToken': refreshToken,
    };
    Uri uri = Uri.https(webAppUrl, refreshTokenEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    HttpClientResponse response = await request.close();
    String body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      LoggerInstance.logger.w('Got error response for refresh token: ${response.statusCode}, $body');
      return null;
    }

    return jsonDecode(body)["accessToken"];
  }
}
