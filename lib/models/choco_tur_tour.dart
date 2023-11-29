import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChocoTurTour {
  ChocoTurTour(
      {required this.id,
      required this.imageUrl,
      required this.title,
      required this.tourInfo,
      required this.costInEuros,
      required this.lengthInKms,
      required this.avgDuration,
      required this.stops,
      required this.stopDescriptions}) {
    if (stops.length != stopDescriptions.length) {
      throw Error();
    }
  }

  final String id;
  final String imageUrl;
  final String title;
  final String tourInfo;
  final int costInEuros;
  final double lengthInKms;
  final Duration avgDuration;
  final List<ChocoTurTourStop> stops;
  final List<String> stopDescriptions;

  bool isFree() {
    return costInEuros == 0;
  }

  int getChocolatesCount() {
    int chocolatesCount = 0;
    for (var i = 0; i < stops.length; ++i) {
      if (stops[i].chocolate != null) chocolatesCount++;
    }

    return chocolatesCount;
  }
}

class ChocoTurTourStop {
  ChocoTurTourStop(
      {required this.id,
      required this.imageUrl,
      required this.title,
      required this.stopInfo,
      required this.stopStory,
      required this.coordinates,
      this.chocolate});

  final String id;
  final String imageUrl;
  final String title;
  final String stopInfo;
  final String stopStory;
  final LatLng coordinates;
  final Chocolate? chocolate;
}

class Chocolate {
  Chocolate({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
}
