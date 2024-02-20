import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/generic_alert_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTourButton extends StatelessWidget {
  const MapTourButton(this.nextStopCoordinates, this.onPressedAction, {super.key});

  final LatLng? nextStopCoordinates;
  final void Function(LatLng, double) onPressedAction;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        if (nextStopCoordinates != null) {
          onPressedAction(nextStopCoordinates!, 16);
        } else {
          showDialog(
            context: context,
            builder: (_) => GenericAlertDialog(
              title: AppLocalizations.of(context)!.noActiveTourToGoTo,
              content: AppLocalizations.of(context)!.noActiveTourToGoToIndication,
            ),
            barrierDismissible: true,
          );
        }
      },
      heroTag: "ToursButton",
      backgroundColor: Styles.redShade,
      child: const FaIcon(
        Icons.tour_outlined,
        color: Styles.onRedShade,
      ),
    );
  }
}
