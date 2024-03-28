import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';

class HomePageTour extends StatelessWidget {
  const HomePageTour({super.key, required this.chocoTurTour});

  final ChocoTurTour chocoTurTour;

  static const double clipRadius = 10.0;

  void onTapped(BuildContext context) {
    Navigator.pushNamed(context, RouteNames.tourInfo, arguments: chocoTurTour);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(clipRadius)),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Styles.redShade, width: 3.0)),
        child: GestureDetector(
          onTap: () => onTapped(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Hero(
                tag: chocoTurTour.id,
                child: Image.memory(chocoTurTour.imageData!),
              ),
              Divider(
                color: Styles.redShade,
                thickness: 15,
              ),
              Text(
                chocoTurTour.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Styles.redShade),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
