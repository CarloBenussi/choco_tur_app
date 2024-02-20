import 'dart:convert';
import 'dart:typed_data';

import 'package:choco_tur/services/firebase_service.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:duration/duration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChocoTurTour {
  ChocoTurTour();

  late final String id;
  late final String title;
  late final double costEuros;
  late final double lengthKm;
  late final Duration avgDuration;
  late final Map<String, String> descriptions;
  late final List<String> stopIds;
  late final List<ChocoTurTourStopInfo> stopInfos;
  late final List<ChocoTurTourTastingInfo> tastingInfos;
  late final String imageId;
  Uint8List? imageData;

  bool isFree() {
    return costEuros == 0;
  }

  bool hasImages() {
    if (imageData == null) {
      return false;
    }

    for (var stopInfo in stopInfos) {
      if (stopInfo.imageData == null) {
        return false;
      }
    }

    for (var tastingInfo in tastingInfos) {
      if (tastingInfo.imageData == null) {
        return false;
      }
    }

    return true;
  }

  Future<void> downloadImages({bool tryFromCache = true, bool saveToCache = true}) async {
    imageData ??= await FirebaseService.downloadImage(imageId, tryFromCache: tryFromCache, saveToCache: saveToCache);

    for (var stopInfo in stopInfos) {
      stopInfo.imageData ??=
          await FirebaseService.downloadImage(stopInfo.imageId, tryFromCache: tryFromCache, saveToCache: saveToCache);
    }

    for (var tastingInfo in tastingInfos) {
      tastingInfo.imageData ??= await FirebaseService.downloadImage(tastingInfo.imageId,
          tryFromCache: tryFromCache, saveToCache: saveToCache);
    }

    return;
  }

  ChocoTurTour.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    costEuros = map['costEuros'];
    lengthKm = map['lengthKm'];
    avgDuration = parseTime(map['avgDuration']);
    descriptions = Map.from(map['descriptions']);
    stopIds = List.from(map['stopIds']);
    List<dynamic> stopInfoMaps = List.from(map['stopInfos']);
    stopInfos = [];
    for (var i = 0; i < stopInfoMaps.length; ++i) {
      stopInfos.add(ChocoTurTourStopInfo.fromMap(stopInfoMaps[i]));
    }
    List<dynamic> tastingInfoMaps = List.from(map['tastingInfos']);
    tastingInfos = [];
    for (var i = 0; i < tastingInfoMaps.length; ++i) {
      tastingInfos.add(ChocoTurTourTastingInfo.fromMap(Map.from(tastingInfoMaps[i])));
    }
    imageId = map['imageId'];
  }

  ChocoTurTour.fromCacheMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    costEuros = map['costEuros'];
    lengthKm = map['lengthKm'];
    avgDuration = parseTime(map['avgDuration']);
    descriptions = Map.from(jsonDecode(map['descriptions']));
    stopIds = List.from(jsonDecode(map['stopIds']));
    List<dynamic> stopInfoMaps = List.from(jsonDecode(map['stopInfos']));
    stopInfos = [];
    for (var i = 0; i < stopInfoMaps.length; ++i) {
      stopInfos.add(ChocoTurTourStopInfo.fromCacheMap(stopInfoMaps[i]));
    }
    List<dynamic> tastingInfoMaps = List.from(jsonDecode(map['tastingInfos']));
    tastingInfos = [];
    for (var i = 0; i < tastingInfoMaps.length; ++i) {
      tastingInfos.add(ChocoTurTourTastingInfo.fromCacheMap(Map.from(tastingInfoMaps[i])));
    }
    imageId = map['imageId'];
  }

  Map<String, dynamic> toCacheMap() {
    List<Map<String, dynamic>> stopInfoMaps = [];
    for (var stopInfo in stopInfos) {
      stopInfoMaps.add(stopInfo.toCacheMap());
    }
    List<Map<String, dynamic>> tastingInfoMaps = [];
    for (var tastingInfo in tastingInfos) {
      tastingInfoMaps.add(tastingInfo.toCacheMap());
    }
    return {
      'id': id,
      'title': title,
      'costEuros': costEuros,
      'lengthKm': lengthKm,
      'avgDuration': avgDuration.toString(),
      'descriptions': jsonEncode(descriptions),
      'stopIds': jsonEncode(stopIds),
      'stopInfos': jsonEncode(stopInfoMaps),
      'tastingInfos': jsonEncode(tastingInfoMaps),
      'imageId': imageId,
    };
  }
}

class ChocoTurTourStopInfo {
  ChocoTurTourStopInfo();

  late final Map<String, String> titles;
  late final Map<String, String> descriptions;
  late final String imageId;
  Uint8List? imageData;

  ChocoTurTourStopInfo.fromMap(Map<String, dynamic> map) {
    titles = Map.from(map['titles']);
    descriptions = Map.from(map['descriptions']);
    imageId = map['imageId'];
  }

  ChocoTurTourStopInfo.fromCacheMap(Map<String, dynamic> map) {
    titles = Map.from(jsonDecode(map['titles']));
    descriptions = Map.from(jsonDecode(map['descriptions']));
    imageId = map['imageId'];
  }

  Map<String, dynamic> toMap() {
    return {
      'titles': titles,
      'descriptions': descriptions,
      'imageId': imageId,
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'titles': jsonEncode(titles),
      'descriptions': jsonEncode(descriptions),
      'imageId': imageId,
    };
  }
}

class ChocoTurTourTastingInfo {
  ChocoTurTourTastingInfo();

  late final Map<String, String> titles;
  late final Map<String, String> descriptions;
  late final String imageId;
  Uint8List? imageData;

  ChocoTurTourTastingInfo.fromMap(Map<String, dynamic> map) {
    titles = Map.from(map['titles']);
    descriptions = Map.from(map['descriptions']);
    imageId = map['imageId'];
  }

  ChocoTurTourTastingInfo.fromCacheMap(Map<String, dynamic> map) {
    titles = Map.from(jsonDecode(map['titles']));
    descriptions = Map.from(jsonDecode(map['descriptions']));
    imageId = map['imageId'];
  }

  Map<String, dynamic> toMap() {
    return {
      'titles': titles,
      'descriptions': descriptions,
      'imageId': imageId,
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'titles': jsonEncode(titles),
      'descriptions': jsonEncode(descriptions),
      'imageId': imageId,
    };
  }
}

class ChocoTurStop {
  ChocoTurStop();

  late final String id;
  late final Map<String, String> titles;
  late final Map<String, String> descriptions;
  late final LatLng coordinates;
  late final String tastingId;
  late final String imageId;
  late final Uint8List? imageData;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titles': titles,
      'descriptions': descriptions,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'tastingId': tastingId,
      'imageId': imageId,
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'id': id,
      'titles': jsonEncode(titles),
      'descriptions': jsonEncode(descriptions),
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'tastingId': tastingId,
      'imageId': imageId,
    };
  }

  ChocoTurStop.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    titles = Map.from(map['name']);
    descriptions = Map.from(map['description']);
    coordinates = LatLng(map['latitude'], map['longitude']);
    tastingId = map['tastingId'];
    imageId = map['imageId'];
  }
}

class ChocoTurTasting {
  ChocoTurTasting();

  late final String id;
  late final Map<String, String> titles;
  late final Map<String, String> descriptions;
  late final Map<String, String> ingredients;
  late final String imageId;
  late final Uint8List? imagesData;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titles': titles,
      'descriptions': descriptions,
      'ingredients': ingredients,
      'imageId': imageId,
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'id': id,
      'titles': jsonEncode(titles),
      'descriptions': jsonEncode(descriptions),
      'ingredients': jsonEncode(ingredients),
      'imageId': imageId,
    };
  }

  ChocoTurTasting.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    titles = Map.from(map['name']);
    descriptions = Map.from(map['description']);
    ingredients = Map.from(map['ingredients']);
    imageId = map['imageId'];
  }
}

enum ChocoTurStopStoryType {
  text, // A page displaying a text with an image.
  quiz // A page displaying a quiz question with options.
}

class ChocoTurStopStory {
  late final ChocoTurStopStoryType type;

  String? text;
  String? topImageUrl;

  String? quizQuestion;
  List<dynamic>? quizAnswers;
  List<dynamic>? onAnswerTexts;
  int? correctAnswerIndex;
  String? afterQuizText;

  ChocoTurStopStory.fromJson(String pageContentJson) {
    try {
      var pageContent = jsonDecode(pageContentJson);
      String typeStr = pageContent['type'];
      switch (typeStr) {
        case "text":
          type = ChocoTurStopStoryType.text;
          break;

        case "quiz":
          type = ChocoTurStopStoryType.quiz;
          break;

        default:
          throw Exception('Page type $typeStr is unknown');
      }

      topImageUrl = pageContent['top_image_url'];

      if (type == ChocoTurStopStoryType.text) {
        text = pageContent['text'];
      } else if (type == ChocoTurStopStoryType.quiz) {
        quizQuestion = pageContent['quiz_question'];
        quizAnswers = pageContent['quiz_answers'];
        onAnswerTexts = pageContent['on_answer_texts'];
        correctAnswerIndex = pageContent['correct_answer_index'];
        afterQuizText = pageContent['after_quiz_text'];
      }
    } catch (e) {
      LoggerInstance.logger.e("Failed to parse stop page json.");
      rethrow;
    }
  }
}
