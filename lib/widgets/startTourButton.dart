import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class StartTourButton extends StatelessWidget {
  StartTourButton({
    super.key,
    required this.available,
    required this.chocoTurTour,
  });

  bool available;
  ChocoTurTour chocoTurTour;

  void onStartTourPressed(BuildContext context) {
    Navigator.pushNamed(context, "/tour_play", arguments: chocoTurTour);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: available
          ? () {
              Navigator.pushNamed(context, "/tour_play",
                  arguments: chocoTurTour);
            }
          : null,
      icon: const FaIcon(
        FontAwesomeIcons.play,
      ),
      label: const Text(
        "Start tour",
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
