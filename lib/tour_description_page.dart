import 'package:choco_tur/models/tour_description_model.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';

class TourDescriptionPage extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  TourDescriptionPage({super.key});

  late final TourDescriptionModel tourDescription;

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
