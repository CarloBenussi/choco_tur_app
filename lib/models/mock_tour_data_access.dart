import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MockTourDataAccess {
  static List<ChocoTurTour> getTourInfos() {
    List<Chocolate> chocolates = [
      Chocolate(
        id: "Cremino",
        name: "Cremino",
        description: ChocoTurPlaceholder.placeholderShort,
        imageUrl: "assets/cremino.jpg",
      ),
      Chocolate(
        id: "Gianduiotto",
        name: "Gianduiotto",
        description: ChocoTurPlaceholder.placeholderShort,
        imageUrl: "assets/gianduiottoSingolo.jpg",
      ),
    ];

    List<ChocoTurTourStop> stops = [
      ChocoTurTourStop(
        id: "Choco Tour Stop 1",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Choco Tour Stop 1",
        stopInfo: ChocoTurPlaceholder.placeholderShort,
        stopStory: ChocoTurPlaceholder.placeholderLong,
        coordinates: const LatLng(45.066980, 7.681970),
      ),
      ChocoTurTourStop(
        id: "Choco Tour Stop 2",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Choco Tour Stop 2",
        stopInfo: ChocoTurPlaceholder.placeholderShort,
        stopStory: ChocoTurPlaceholder.placeholderLong,
        coordinates: const LatLng(45.071786, 7.680763),
        chocolate: chocolates[0],
      ),
      ChocoTurTourStop(
        id: "Choco Tour Stop 3",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Choco Tour Stop 3",
        stopInfo: ChocoTurPlaceholder.placeholderShort,
        stopStory: ChocoTurPlaceholder.placeholderLong,
        coordinates: const LatLng(45.068058, 7.685398),
      ),
      ChocoTurTourStop(
        id: "Choco Tour Stop 4",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Choco Tour Stop 4",
        stopInfo: ChocoTurPlaceholder.placeholderShort,
        stopStory: ChocoTurPlaceholder.placeholderLong,
        coordinates: const LatLng(45.070058, 7.682780),
        chocolate: chocolates[1],
      ),
      ChocoTurTourStop(
        id: "Choco Tour Stop 5",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Choco Tour Stop 5",
        stopInfo: ChocoTurPlaceholder.placeholderShort,
        stopStory: ChocoTurPlaceholder.placeholderLong,
        coordinates: const LatLng(45.068391, 7.683810),
        chocolate: chocolates[0],
      ),
      ChocoTurTourStop(
        id: "Choco Tour Stop 6",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Choco Tour Stop 6",
        stopInfo: ChocoTurPlaceholder.placeholderShort,
        stopStory: ChocoTurPlaceholder.placeholderLong,
        coordinates: const LatLng(45.070998, 7.686085),
        chocolate: chocolates[1],
      ),
    ];

    return [
      ChocoTurTour(
        id: "Tour 1",
        imageUrl: 'assets/piazzaSanCarlo.jpg',
        title: "Choco Tour 1",
        tourInfo: ChocoTurPlaceholder.placeholder,
        costInEuros: 0,
        lengthInKms: 0.7,
        avgDuration: const Duration(hours: 1, minutes: 30),
        stops: stops.sublist(1, 4),
      ),
      ChocoTurTour(
        id: "Tour 2",
        imageUrl: 'assets/piazzaSanCarlo.jpg',
        title: "Choco Tour 2",
        tourInfo: ChocoTurPlaceholder.placeholder,
        costInEuros: 7,
        lengthInKms: 1.3,
        avgDuration: const Duration(hours: 2),
        stops: stops.sublist(1, 5),
      ),
      ChocoTurTour(
        id: "Tour 3",
        imageUrl: 'assets/piazzaSanCarlo.jpg',
        title: "Choco Tour 3",
        tourInfo: ChocoTurPlaceholder.placeholder,
        costInEuros: 8,
        lengthInKms: 1.8,
        avgDuration: const Duration(hours: 2, minutes: 45),
        stops: stops.sublist(1, 6),
      ),
      ChocoTurTour(
        id: "Tour 4",
        imageUrl: 'assets/piazzaSanCarlo.jpg',
        title: "Choco Tour 4",
        tourInfo: ChocoTurPlaceholder.placeholder,
        costInEuros: 15,
        lengthInKms: 3,
        avgDuration: const Duration(hours: 3, minutes: 30),
        stops: stops,
      ),
    ];
  }
}
