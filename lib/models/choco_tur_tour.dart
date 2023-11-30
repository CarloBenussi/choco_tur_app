import 'package:duration/duration.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChocoTurTour {
  ChocoTurTour();

  late final String id;
  late final String name;
  late final int costInEuros;
  late final double lengthInKms;
  late final Duration avgDuration;
  late final String description;
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
      'avgDurationHour': avgDuration.toString(),
      'description': description,
      'mainImageUrl': mainImageUrl,
    };
  }

  ChocoTurTour.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    costInEuros = map['costEuro'];
    lengthInKms = map['lengthKm'];
    avgDuration = parseTime(map['avgDurationHour']);
    description = map['description'];
    mainImageUrl = map['mainImageUrl'];
  }

  // int getChocolatesCount() {
  //   int chocolatesCount = 0;
  //   for (var i = 0; i < stops.length; ++i) {
  //     if (stops[i].chocolate != null) chocolatesCount++;
  //   }

  //   return chocolatesCount;
  // }
}

class ChocoTurTourStop {
  ChocoTurTourStop();

  late final String id;
  late final String name;
  late final String description;
  late final LatLng coordinates;
  late final String mainImageUrl;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'mainImageUrl': mainImageUrl,
    };
  }

  ChocoTurTourStop.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    description = map['description'];
    coordinates = LatLng(map['latitude'], map['longitude']);
    mainImageUrl = map['mainImageUrl'];
  }
}

class Chocolate {
  Chocolate();

  late final String id;
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
