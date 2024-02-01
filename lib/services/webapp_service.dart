import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class WebappService {
  static const String webAppUrl = String.fromEnvironment('WEBAPP_URL');
  static const String registrationEndpoint = "/users/registration";
  static const String confirmEmailEndpoint = "/users/registrationConfirmation";

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
    return true;
  }
}
