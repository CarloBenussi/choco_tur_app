import 'dart:convert';
import 'dart:typed_data';

import 'package:choco_tur/services/firebase_service.dart';
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

    for (var tastingInfo in tastingInfos) {
      if (tastingInfo.imageData == null) {
        return false;
      }
    }

    return true;
  }

  Future<void> downloadImages({bool tryFromCache = true, bool saveToCache = true}) async {
    imageData ??= await FirebaseService.downloadImage(imageId, tryFromCache: tryFromCache, saveToCache: saveToCache);

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
  late final LatLng coordinates;

  ChocoTurTourStopInfo.fromMap(Map<String, dynamic> map) {
    titles = Map.from(map['titles']);
    coordinates = LatLng(map['latitude'], map['longitude']);
  }

  ChocoTurTourStopInfo.fromCacheMap(Map<String, dynamic> map) {
    titles = Map.from(jsonDecode(map['titles']));
    coordinates = LatLng(map['latitude'], map['longitude']);
  }

  Map<String, dynamic> toMap() {
    return {
      'titles': titles,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'titles': jsonEncode(titles),
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
    };
  }
}

class ChocoTurTourTastingInfo {
  ChocoTurTourTastingInfo();

  late final Map<String, String> titles;
  late final String imageId;
  Uint8List? imageData;

  ChocoTurTourTastingInfo.fromMap(Map<String, dynamic> map) {
    titles = Map.from(map['titles']);
    imageId = map['imageId'];
  }

  ChocoTurTourTastingInfo.fromCacheMap(Map<String, dynamic> map) {
    titles = Map.from(jsonDecode(map['titles']));
    imageId = map['imageId'];
  }

  Map<String, dynamic> toMap() {
    return {
      'titles': titles,
      'imageId': imageId,
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'titles': jsonEncode(titles),
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
  late final String imageId;
  late final String audioId;
  late final String? tastingId;
  late final Uint8List? imageData;
  late final int? optionalGroup;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titles': titles,
      'descriptions': descriptions,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'imageId': imageId,
      'audioId': audioId,
      'tastingId': (tastingId != null) ? tastingId : '',
      'optionalGroup': (optionalGroup != null) ? optionalGroup : -1,
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'id': id,
      'titles': jsonEncode(titles),
      'descriptions': jsonEncode(descriptions),
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'imageId': imageId,
      'audioId': audioId,
      'tastingId': (tastingId != null) ? tastingId : '',
      'optionalGroup': (optionalGroup != null) ? optionalGroup : -1,
    };
  }

  ChocoTurStop.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    titles = Map.from(map['titles']);
    descriptions = Map.from(map['descriptions']);
    coordinates = LatLng(map['latitude'], map['longitude']);
    imageId = map['imageId'];
    audioId = map['audioId'];
    if (map.containsKey('tastingId') && (map['tastingId'] != '')) {
      tastingId = map['tastingId'];
    } else {
      tastingId = null;
    }
    if (map.containsKey('optionalGroup') && (map['optionalGroup'] != -1)) {
      optionalGroup = map['optionalGroup'];
    } else {
      optionalGroup = -1;
    }
  }

  ChocoTurStop.fromCacheMap(Map<String, dynamic> map) {
    id = map['id'];
    titles = Map.from(jsonDecode(map['titles']));
    descriptions = Map.from(jsonDecode(map['descriptions']));
    coordinates = LatLng(map['latitude'], map['longitude']);
    imageId = map['imageId'];
    audioId = map['audioId'];
    if (map.containsKey('tastingId') && (map['tastingId'] != '')) {
      tastingId = map['tastingId'];
    } else {
      tastingId = null;
    }
    if (map.containsKey('optionalGroup') && (map['optionalGroup'] != -1)) {
      optionalGroup = map['optionalGroup'];
    } else {
      optionalGroup = -1;
    }
  }
}

enum ChocoTurStopStoryType { text, image, answers, onAnswers }

enum ChocoTurStoryAnswerAction { none, skip, skipOptions, audio, finishWithPause }

class ChocoTurStopStory {
  late final int index;
  late final ChocoTurStopStoryType type;

  Map<String, String>? texts;
  List<Map<String, dynamic>>? answers;
  List<Map<String, String>>? onAnswers;
  String? imageId;

  ChocoTurStopStory.fromMap(Map<String, dynamic> map) {
    index = map['index'];
    type = ChocoTurStopStoryType.values[map['type']];
    var pageContent = Map.from(jsonDecode(map['contentJson']));

    imageId = pageContent['imageId'];
    texts = (pageContent['text'] != null) ? Map.from(pageContent['text']) : null;
    if (pageContent['answers'] != null) {
      List<dynamic> answerMaps = List.from(pageContent['answers']);
      answers = [];
      for (var i = 0; i < answerMaps.length; ++i) {
        answers!.add(Map.from(answerMaps[i]));
      }
    }
    if (pageContent['onAnswers'] != null) {
      List<dynamic> onAnswerMaps = List.from(pageContent['onAnswers']);
      onAnswers = [];
      for (var i = 0; i < onAnswerMaps.length; ++i) {
        onAnswers!.add(Map.from(onAnswerMaps[i]));
      }
    }
  }
}

class ChocoTurQuiz {
  ChocoTurQuiz();

  late final String id;
  late final Map<String, String> intro;
  late final List<ChocoTurQuizQuestion> questions;

  ChocoTurQuiz.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    intro = Map.from(map['intro']);
    List<dynamic> questionMaps = List.from(map['questions']);
    questions = [];
    for (var i = 0; i < questionMaps.length; ++i) {
      questions.add(ChocoTurQuizQuestion.fromMap(questionMaps[i]));
    }
    questions.sort((a, b) => a.index.compareTo(b.index));
  }
}

class ChocoTurQuizQuestion {
  ChocoTurQuizQuestion();

  late final int index;
  late final Map<String, String> question;
  late final List<Map<String, String>> answers;
  late final int correctAnswerIndex;
  late final List<Map<String, String>> onAnswers;

  ChocoTurQuizQuestion.fromMap(Map<String, dynamic> map) {
    index = map['index'];
    question = Map.from(map['question']);
    var answersList = List.from(map['answers']);
    answers = [];
    for (var answer in answersList) {
      answers.add(Map.from(answer));
    }
    correctAnswerIndex = map['correctAnswerIndex'];
    var onAnswersList = List.from(map['onAnswers']);
    onAnswers = [];
    for (var onAnswer in onAnswersList) {
      onAnswers.add(Map.from(onAnswer));
    }
  }

  ChocoTurQuizQuestion.fromCacheMap(Map<String, dynamic> map) {
    index = map['index'];
    question = Map.from(jsonDecode(map['question']));
    var answersList = List.from(jsonDecode(map['answers']));
    answers = [];
    for (var answer in answersList) {
      answers.add(Map.from(answer));
    }
    correctAnswerIndex = map['correctAnswerIndex'];
    var onAnswersList = List.from(jsonDecode(map['onAnswers']));
    onAnswers = [];
    for (var onAnswer in onAnswersList) {
      onAnswers.add(Map.from(onAnswer));
    }
  }
}

class ChocoTurTasting {
  ChocoTurTasting();

  late final String id;
  late final Map<String, String> titles;
  late final Map<String, String> descriptions;
  late final Map<String, String> ingredients;
  late final List<double> reviews;
  late final String imageId;
  late final Uint8List? imagesData;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titles': titles,
      'descriptions': descriptions,
      'ingredients': ingredients,
      'reviews': reviews,
      'imageId': imageId,
    };
  }

  Map<String, dynamic> toCacheMap() {
    return {
      'id': id,
      'titles': jsonEncode(titles),
      'descriptions': jsonEncode(descriptions),
      'ingredients': jsonEncode(ingredients),
      'reviews': jsonEncode(reviews),
      'imageId': imageId,
    };
  }

  ChocoTurTasting.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    titles = Map.from(map['titles']);
    descriptions = Map.from(map['descriptions']);
    ingredients = Map.from(map['ingredients']);
    reviews = List.from(map['reviews']);
    imageId = map['imageId'];
  }
}
