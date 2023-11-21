import 'package:choco_tur/models/tour_description_model.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TourDescriptionPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  TourDescriptionPage({super.key});

  @override
  State<TourDescriptionPage> createState() => _TourDescriptionPageState();
}

class _TourDescriptionPageState extends State<TourDescriptionPage> {
  late TourDescriptionModel tourDescription;

  bool _purchased = false;

  void onPurchasePressed() {
    setState(() {
      _purchased = true;
    });
  }

  void onPlayPressed() {} // TODO: Implement with audio_player.

  @override
  Widget build(BuildContext context) {
    tourDescription =
        ModalRoute.of(context)!.settings.arguments as TourDescriptionModel;
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      body: ListView(
        children: [
          Hero(
            tag: tourDescription.heroTag,
            child: ClipRRect(child: Image.asset(tourDescription.imageUrl)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _purchased ? onPlayPressed : null,
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
                ElevatedButton.icon(
                  onPressed: onPurchasePressed,
                  icon: const FaIcon(
                    FontAwesomeIcons.cartShopping,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Purchase tour",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
          Text(
            tourDescription.text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          )
        ],
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(),
    );
  }
}
