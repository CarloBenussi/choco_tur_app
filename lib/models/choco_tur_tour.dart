class ChocoTurTour {
  ChocoTurTour(
      {required this.id,
      required this.imageUrl,
      required this.text,
      required this.title,
      required this.costInEuros,
      required this.stops,
      required this.stopDescriptions}) {
    if (stops.length != stopDescriptions.length) {
      throw Error();
    }
  }

  final String id;
  final String imageUrl;
  final String text;
  final String title;
  final int costInEuros;
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
      this.chocolate});

  final String id;
  final String imageUrl;
  final String title;
  final String stopInfo;
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
