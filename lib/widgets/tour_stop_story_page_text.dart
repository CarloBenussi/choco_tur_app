import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:flutter/material.dart';

class TourStopStoryPageText extends StatelessWidget {
  const TourStopStoryPageText({super.key, required this.stopStoryPage});

  final ChocoTurStopPage stopStoryPage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      children: [
        Center(child: Text(stopStoryPage.text!)),
        if (stopStoryPage.topImageUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(stopStoryPage.topImageUrl!),
            ),
          )
      ],
    );
  }
}
