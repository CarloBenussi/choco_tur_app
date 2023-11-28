import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:choco_tur/widgets/purchaseTourButton.dart';
import 'package:choco_tur/widgets/tour_stops.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TourInfoPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  TourInfoPage({super.key});

  @override
  State<TourInfoPage> createState() => _TourInfoPageState();
}

class _TourInfoPageState extends State<TourInfoPage> {
  late ChocoTurTour chocoTurTour;

  bool _purchased = false;

  void onPurchasePressed() {
    setState(() {
      _purchased = true;
    });
  }

  void onPlayPressed() {} // TODO: Implement with audio_player.

  @override
  Widget build(BuildContext context) {
    chocoTurTour = ModalRoute.of(context)!.settings.arguments as ChocoTurTour;
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        children: [
          Hero(
            tag: chocoTurTour.id,
            child: Image.asset(chocoTurTour.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: (_purchased || chocoTurTour.isFree())
                      ? onPlayPressed
                      : null,
                  icon: const FaIcon(
                    FontAwesomeIcons.play,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Play tour description",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                if (!chocoTurTour.isFree())
                  PurchaseTourButton(
                    onPressedFunction: onPurchasePressed,
                    purchased: _purchased,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${chocoTurTour.title}\n\n",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: ChocoTurStyles.tourInfoTextOnBackgroundColor,
                    ),
                  ),
                  TextSpan(
                    text: chocoTurTour.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: ChocoTurStyles.tourInfoTextOnBackgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Divider(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Text(
              "Tour stops",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: ChocoTurStyles.tourInfoTextOnBackgroundColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: TourStops(
              tourStops: chocoTurTour.stops,
              tourStopDescriptions: chocoTurTour.stopDescriptions,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(),
    );
  }
}
