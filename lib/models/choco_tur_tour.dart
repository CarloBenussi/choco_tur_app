class ChocoTurTour {
  ChocoTurTour(
      {required this.id,
      required this.imageUrl,
      required this.text,
      required this.title,
      required this.costInEuros,
      required this.stops});

  final String id;
  final String imageUrl;
  final String text;
  final String title;
  final int costInEuros;
  final List<ChocoTurTourStop> stops;

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
      required this.text,
      required this.title,
      this.chocolate});

  final String id;
  final String imageUrl;
  final String text;
  final String title;
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
