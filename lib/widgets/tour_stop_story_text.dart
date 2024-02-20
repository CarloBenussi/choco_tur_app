import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:flutter/material.dart';

class TourStopStoryText extends StatelessWidget {
  const TourStopStoryText({super.key, required this.stopStory});

  final ChocoTurStopStory stopStory;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      children: [
        Center(child: Text(stopStory.text!)),
        if (stopStory.topImageUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(stopStory.topImageUrl!),
            ),
          )
      ],
    );
  }
}
