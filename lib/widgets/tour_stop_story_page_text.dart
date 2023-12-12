import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:flutter/material.dart';

class TourStopStoryPageText extends StatelessWidget {
  const TourStopStoryPageText({super.key, required this.stopStoryPage});

  final ChocoTurStopPage stopStoryPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(stopStoryPage.text!),
      ],
    );
  }
}
