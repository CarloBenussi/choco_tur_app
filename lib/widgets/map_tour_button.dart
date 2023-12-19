import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/generic_alert_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTourButton extends StatelessWidget {
  const MapTourButton(
      this.activeTourId, this.tourNextStopId, this.onPressedAction,
      {super.key});

  final int? activeTourId;
  final int? tourNextStopId;
  final void Function(LatLng, double) onPressedAction;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        if (activeTourId != null) {
          SqliteCache cache = await SqliteCache.getInstance();
          ChocoTurTourStop stop =
              await cache.getTourStopFromId(tourNextStopId!);
          // ignore: use_build_context_synchronously
          onPressedAction(stop.coordinates, 16);
        } else {
          showDialog(
            context: context,
            builder: (_) => GenericAlertDialog(
              title: AppLocalizations.of(context)!.noActiveTourToGoTo,
              content:
                  AppLocalizations.of(context)!.noActiveTourToGoToIndication,
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
