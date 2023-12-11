import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class StartTourButton extends StatelessWidget {
  StartTourButton({
    super.key,
    required this.available,
    required this.tourId,
  });

  bool available;
  int tourId;

  void _onStartTourPressed(BuildContext context) {
    LoggerInstance.logger.d('Activating tour $tourId');
    Provider.of<ChocoTurUser>(context, listen: false).activateTour(tourId);
    Navigator.pushNamed(context, "/tour_play", arguments: tourId);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: available ? () => _onStartTourPressed(context) : null,
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
