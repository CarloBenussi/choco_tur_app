// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';
import 'package:choco_tur/utils/logger.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FirebaseService {
  static const String firebaseBucket = String.fromEnvironment('FIREBASE_BUCKET');
  static const String imagesPath = "images";
  static const String audiosPath = "audio";
  static const String imageOnError = "assets/chocolateGobino.jpg";

  static FirebaseApp? _fbApp;
  static FirebaseStorage? _fbStorage;
  static Reference? _appRef;
  static Reference? _imagesRef;
  static Reference? _audiosRef;

  static Future<void> init() async {
    _fbApp = await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
      appId: String.fromEnvironment('FIREBASE_APP_ID'),
      messagingSenderId: String.fromEnvironment('FIREBASE_APP_ID'),
      projectId: String.fromEnvironment('FIREBASE_PRJECT_ID'),
    ));
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.appAttest,
    );
    _fbStorage = FirebaseStorage.instanceFor(bucket: firebaseBucket);
    _appRef = _fbStorage!.ref();
    _imagesRef = _appRef!.child(imagesPath);
    _audiosRef = _appRef!.child(audiosPath);
  }

  static Future<Uint8List> downloadImage(String imageId, {bool tryFromCache = true, bool saveToCache = true}) async {
    try {
      Uint8List? ret;
      if (tryFromCache) {
        FileInfo? imageFile = await DefaultCacheManager().getFileFromCache(imageId);
        if (imageFile == null) {
          LoggerInstance.logger.d('Could not find on cache image with ID $imageId');
        } else {
          ret = imageFile.file.readAsBytesSync();
        }
      }

      if (ret == null) {
        Reference imageRef = _imagesRef!.child(imageId);
        const oneMegabyte = 1024 * 1024;
        ret = await imageRef.getData(oneMegabyte);
        if (ret == null) {
          throw FirebaseException(plugin: "Storage", message: "Got null image data");
        }
      }

      if (saveToCache) {
        DefaultCacheManager().putFile(imageId, ret, maxAge: const Duration(days: 1));
      }

      return ret;
    } on FirebaseException catch (e) {
      LoggerInstance.logger.e('Failed to download image $imageId: ${e.message}');
      return Uint8List(0);
    }
  }

  static Future<Uint8List> downloadAudio(String langCode, String audioId) async {
    try {
      Uint8List? ret;
      Reference audioLangRef = _audiosRef!.child(langCode);
      Reference audioRef = audioLangRef.child(audioId);
      const oneMegabyte = 1024 * 1024;
      ret = await audioRef.getData(oneMegabyte);
      if (ret == null) {
        throw FirebaseException(plugin: "Storage", message: "Got null audio data");
      }

      return ret;
    } on FirebaseException catch (e) {
      LoggerInstance.logger.e('Failed to download audio $audioId: ${e.message}');
      return Uint8List(0);
    }
  }
}
