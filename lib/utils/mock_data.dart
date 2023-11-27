import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/placeholder.dart';

class MockData {
  static List<ChocoTurTour> mockTours() {
    List<Chocolate> chocolates = [
      Chocolate(
        id: "Cremino",
        name: "Cremino",
        description: ChocoTurPlaceholder.loremIpsum,
        imageUrl: "assets/cremino.jpg",
      ),
      Chocolate(
        id: "Gianduiotto",
        name: "Gianduiotto",
        description: ChocoTurPlaceholder.loremIpsum,
        imageUrl: "assets/gianduiottoSingolo.jpg",
      ),
    ];

    List<ChocoTurTourStop> stops = [
      ChocoTurTourStop(
        id: "Choco Tour Stop 1",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Caffé san Carlo.",
        stopInfo: ChocoTurPlaceholder.loremIpsum,
      ),
      ChocoTurTourStop(
        id: "Choco Tour Stop 2",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Caffé san Carlo.",
        stopInfo: ChocoTurPlaceholder.loremIpsum,
        chocolate: chocolates[0],
      ),
      ChocoTurTourStop(
        id: "Choco Tour Stop 3",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Caffé san Carlo.",
        stopInfo: ChocoTurPlaceholder.loremIpsum,
      ),
      ChocoTurTourStop(
        id: "Choco Tour Stop 4",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Caffé san Carlo.",
        stopInfo: ChocoTurPlaceholder.loremIpsum,
        chocolate: chocolates[1],
      ),
      ChocoTurTourStop(
        id: "Choco Tour Stop 5",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Caffé san Carlo.",
        stopInfo: ChocoTurPlaceholder.loremIpsum,
        chocolate: chocolates[0],
      ),
      ChocoTurTourStop(
        id: "Choco Tour Stop 6",
        imageUrl: 'assets/caffeSanCarlo.jpg',
        title: "Caffé san Carlo.",
        stopInfo: ChocoTurPlaceholder.loremIpsum,
        chocolate: chocolates[1],
      ),
    ];

    return [
      ChocoTurTour(
        id: "Tour 1",
        imageUrl: 'assets/piazzaSanCarlo.jpg',
        text: ChocoTurPlaceholder.loremIpsum,
        title: "Choco Tour 1",
        costInEuros: 0,
        stops: stops.sublist(1, 4),
        stopDescriptions:
            List<String>.generate(3, (index) => ChocoTurPlaceholder.loremIpsum),
      ),
      ChocoTurTour(
        id: "Tour 2",
        imageUrl: 'assets/piazzaSanCarlo.jpg',
        text: ChocoTurPlaceholder.loremIpsum,
        title: "Choco Tour 2",
        costInEuros: 7,
        stops: stops.sublist(1, 5),
        stopDescriptions:
            List<String>.generate(4, (index) => ChocoTurPlaceholder.loremIpsum),
      ),
      ChocoTurTour(
        id: "Tour 3",
        imageUrl: 'assets/piazzaSanCarlo.jpg',
        text: ChocoTurPlaceholder.loremIpsum,
        title: "Choco Tour 3",
        costInEuros: 8,
        stops: stops.sublist(1, 6),
        stopDescriptions:
            List<String>.generate(5, (index) => ChocoTurPlaceholder.loremIpsum),
      ),
      ChocoTurTour(
        id: "Tour 4",
        imageUrl: 'assets/piazzaSanCarlo.jpg',
        text: ChocoTurPlaceholder.loremIpsum,
        title: "Choco Tour 4",
        costInEuros: 15,
        stops: stops,
        stopDescriptions:
            List<String>.generate(6, (index) => ChocoTurPlaceholder.loremIpsum),
      ),
    ];
  }
}
