import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MarkerInfoWindow extends StatelessWidget {
  const MarkerInfoWindow({
    super.key,
    required this.stop,
  });

  final ChocoTurTourStop stop;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 5,
          color: Styles.redShade,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            stop.name,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              stop.description,
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.popAndPushNamed(context, RouteNames.tourStopStoryPages,
                  arguments: stop.id);
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
            ),
          )
        ],
      ),
    );
  }
}
