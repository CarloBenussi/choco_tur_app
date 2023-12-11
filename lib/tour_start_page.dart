import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TourStartPage extends StatelessWidget {
  TourStartPage({super.key, required this.tourId});

  final int tourId;
  Future<String>? _tourName;

  void _onAnimationFinished(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/map");
  }

  Future<String> _getOrReturnTourName() async {
    if (_tourName == null) {
      SqliteCache cache = await SqliteCache.getInstance();
      _tourName = cache.getTourName(tourId);
    }

    return _tourName!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      body: Center(
        child: FutureBuilder(
          future: _getOrReturnTourName(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              return AnimatedTextKit(
                isRepeatingAnimation: false,
                animatedTexts: [
                  TyperAnimatedText(
                    "Welcome to the Choco Tur...",
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  FadeAnimatedText(
                    snapshot.data!,
                    textStyle: const TextStyle(fontSize: 30),
                  ),
                ],
                onFinished: () => _onAnimationFinished(context),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
