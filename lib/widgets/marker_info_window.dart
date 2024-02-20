import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarkerInfoWindow extends StatelessWidget {
  const MarkerInfoWindow({
    super.key,
    required this.stop,
  });

  final ChocoTurStop stop;

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
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              stop.descriptions[Provider.of<ChocoTurUser>(context, listen: true).language]!,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Animation and meanwhile download (and cache, replacing the one spot) stop story
                Navigator.popAndPushNamed(context, RouteNames.tourStopStoryPages, arguments: stop.id);
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
            ),
          )
        ],
      ),
    );
  }
}
