import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TourStopStoryText extends StatelessWidget {
  TourStopStoryText({super.key, required this.stopStory});

  final ChocoTurStopStory stopStory;
  String? _langCode;

  @override
  Widget build(BuildContext context) {
    _langCode = Provider.of<ChocoTurUser>(context, listen: true).language;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      children: [
        Center(child: Text(stopStory.texts![_langCode]!)),
        if (stopStory.imageId != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(stopStory.imageId!),
            ),
          )
      ],
    );
  }
}
