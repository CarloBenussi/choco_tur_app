import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MarkerInfoWindow extends StatelessWidget {
  const MarkerInfoWindow({
    super.key,
    required this.stop,
    required this.getDirectionsToStop,
  });

  final ChocoTurStop stop;
  final Function(LatLng destination) getDirectionsToStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 3,
          color: Styles.redShade,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            stop.titles[Provider.of<ChocoTurUser>(context, listen: true).language]!,
            style: TextStyle(fontSize: 20, color: Styles.redShade),
            textAlign: TextAlign.center,
          ),
          Text(
            stop.descriptions[Provider.of<ChocoTurUser>(context, listen: true).language]!,
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                getDirectionsToStop(stop.coordinates);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.redShade,
              ),
              icon: const Icon(
                Icons.directions_walk_rounded,
                color: Styles.onRedShade,
              ),
              label: Text(
                AppLocalizations.of(context)!.getDirectionsToStopLabel,
                style: const TextStyle(color: Styles.onRedShade),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.popAndPushNamed(context, RouteNames.tourStopStoryChat, arguments: stop);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.redShade,
              ),
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: Styles.onRedShade,
              ),
              label: Text(
                AppLocalizations.of(context)!.visitStopButton,
                style: const TextStyle(color: Styles.onRedShade),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
