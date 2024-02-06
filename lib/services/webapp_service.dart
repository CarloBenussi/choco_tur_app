import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class WebappService {
  static const String webAppUrl = String.fromEnvironment('WEBAPP_URL');
  static const String registrationEndpoint = "/users/registration";
  static const String confirmEmailEndpoint = "/users/registrationConfirmation";
  static const String loginEndpoint = "/users/login";
  static const String loginWithTokenEndpoint = "/users/loginWithToken";
  static const String refreshTokenEndpoint = "/users/refreshToken";

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
    _client!.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  }

  static Future<bool> registerUser(
      String email, String password, String matchingPassword) async {
    Uri uri = Uri.https(webAppUrl, registrationEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({
      'email': email,
      'password': password,
      'matchingPassword': matchingPassword,
    });
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    if (response.statusCode != 200) {
      LoggerInstance.logger.e(
          'Got error response for registration: ${response.statusCode}, ${response.reasonPhrase}');
      return false;
    }

    //var decodedResponse = jsonDecode(utf8.decode(response.)) as Map;
    return true;
  }

  static Future<bool> confirmEmail(String email, String numberSequence) async {
    var params = {
      'email': email,
      'number': numberSequence,
    };
    Uri uri = Uri.https(webAppUrl, confirmEmailEndpoint, params);
    HttpClientRequest request = await _client!.getUrl(uri);
    HttpClientResponse response = await request.close();
    if (response.statusCode != 200) {
      LoggerInstance.logger.e(
          'Got error response for email confirmation: ${response.statusCode}');
      return false;
    }

    //var decodedResponse = jsonDecode(utf8.decode(response.)) as Map;
    // TODO: Extract and save token.
    return true;
  }

  static Future<bool> loginUser(BuildContext context, String email,
      String password, bool rememberUser) async {
    Uri uri = Uri.https(webAppUrl, loginEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({'email': email, 'password': password});
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    if (response.statusCode != 200) {
      LoggerInstance.logger.e(
          'Got error response for registration: ${response.statusCode}, ${response.reasonPhrase}');
      return false;
    }

    if (rememberUser) {
      Map<String, dynamic> body =
          jsonDecode(await response.transform(utf8.decoder).join());
      Provider.of<ChocoTurUser>(context, listen: false).saveLoginInfo(
        email,
        body["accessToken"],
        body["refreshToken"],
        LoginType.manual,
      );
    }
    return true;
  }

  static Future<Map<String, dynamic>?> loginUserWithToken(
      String email, String accessToken, String? refreshToken) async {
    Uri uri = Uri.https(webAppUrl, loginWithTokenEndpoint);
    HttpClientRequest request = await _client!.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    String body = jsonEncode({'email': email, 'accessToken': accessToken});
    request.add(utf8.encode(body));
    HttpClientResponse response = await request.close();

    if (response.statusCode == 200) {
      LoggerInstance.logger.d("Login with token successful");

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else if (response.statusCode == 401) {
      LoggerInstance.logger
          .d("Expired access token, trying to use refresh token.");

      if (refreshToken == null) {
        LoggerInstance.logger.w("No refresh token save on user preferences.");
        return null;
      }

      var params = {
        'email': email,
        'refreshToken': refreshToken,
      };
      uri = Uri.https(webAppUrl, refreshTokenEndpoint, params);
      request = await _client!.getUrl(uri);
      response = await request.close();

      if (response.statusCode != 200) {
        LoggerInstance.logger.w(
            'Got error response for refresh token: ${response.statusCode}, ${response.reasonPhrase}');
        return null;
      }

      return jsonDecode(await response.transform(utf8.decoder).join());
    } else {
      LoggerInstance.logger.e(
          'Got error response for registration: ${response.statusCode}, ${response.reasonPhrase}');
      return null;
    }
  }
}
