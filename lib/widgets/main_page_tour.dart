import 'package:choco_tur/models/tour_description_model.dart';
import 'package:flutter/material.dart';

class MainPageTour extends StatelessWidget {
  const MainPageTour({super.key, required this.tourDescription});

  final TourDescriptionModel tourDescription;

  void onTapped(BuildContext context) {
    Navigator.pushNamed(context, '/tour_description',
        arguments: tourDescription);
  }

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 200,
      child: GestureDetector(
        onTap: () => onTapped(context),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(children: [
            Hero(
              tag: tourDescription.heroTag,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(tourDescription.imageUrl)),
            ),
            Positioned(
              bottom: 5,
              left: 5,
              child: Text(
                tourDescription.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Colors.white),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
