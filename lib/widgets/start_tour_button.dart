import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
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

  void _onStartTourPressed(BuildContext context) async {
    LoggerInstance.logger.d('Activating tour $tourId');
    bool activateSuccess =
        await Provider.of<ChocoTurUser>(context, listen: false)
            .activateTour(context, tourId);
    if (activateSuccess) {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, RouteNames.tourPlay, arguments: tourId);
    }
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
