import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class StartTourButton extends StatelessWidget {
  StartTourButton({
    super.key,
    required this.available,
    required this.tour,
  });

  bool available;
  ChocoTurTour tour;

  void _onStartTourPressed(BuildContext context) async {
    LoggerInstance.logger.d('Activating tour ${tour.id}');
    bool activateSuccess = await Provider.of<ChocoTurUser>(context, listen: false).activateTour(
      context,
      tour,
    );
    if (activateSuccess) {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, RouteNames.tourPlay, arguments: tour);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Styles.redShade,
      ),
      onPressed: available ? () => _onStartTourPressed(context) : null,
      icon: const FaIcon(
        FontAwesomeIcons.play,
        color: Styles.onRedShade,
      ),
      label: Text(
        AppLocalizations.of(context)!.startTourButton,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Styles.onRedShade),
      ),
    );
  }
}
