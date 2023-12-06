import 'package:duration/duration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChocoTurTour {
  ChocoTurTour();

  late final int id;
  late final String name;
  late final double costInEuros;
  late final double lengthInKms;
  late final Duration avgDuration;
  late final String description;
  late final int numStops;
  late final int numTastings;
  late final String mainImageUrl;

  bool isFree() {
    return costInEuros == 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'costEuro': costInEuros,
      'lengthKm': lengthInKms,
      'avgDuration': avgDuration.toString(),
      'description': description,
      'numStops': numStops,
      'numTastings': numTastings,
      'mainImageUrl': mainImageUrl,
    };
  }

  ChocoTurTour.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    costInEuros = map['costEuro'];
    lengthInKms = map['lengthKm'];
    avgDuration = parseTime(map['avgDuration']);
    description = map['description'];
    numStops = map['numStops'];
    numTastings = map['numTastings'];
    mainImageUrl = map['mainImageUrl'];
  }
}

class ChocoTurTourStop {
  ChocoTurTourStop();

  late final int id;
  late final String name;
  late final String description;
  late final LatLng coordinates;
  late final bool hasTasting;
  late final String mainImageUrl;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'hasTasting': hasTasting ? 1 : 0,
      'mainImageUrl': mainImageUrl,
    };
  }

  ChocoTurTourStop.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    description = map['description'];
    coordinates = LatLng(map['latitude'], map['longitude']);
    hasTasting = map['hasTasting'] == 1 ? true : false;
    mainImageUrl = map['mainImageUrl'];
  }
}

class Chocolate {
  Chocolate();

  late final int id;
  late final String name;
  late final String description;
  late final String mainImageUrl;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'mainImageUrl': mainImageUrl,
    };
  }

  Chocolate.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    description = map['description'];
    mainImageUrl = map['mainImageUrl'];
  }
}
