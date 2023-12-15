import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TourStartPage extends StatelessWidget {
  TourStartPage({super.key, required this.tourId});

  final int tourId;
  Future<ChocoTurTour>? _tour;

  void _onAnimationFinished(BuildContext context) {
    Navigator.pushReplacementNamed(context, RouteNames.map, arguments: true);
    // Navigator.pushNamed(context, RouteNames.tourStopStoryPages, arguments: 2);
  }

  Future<ChocoTurTour> _getOrReturnTour() async {
    if (_tour == null) {
      SqliteCache cache = await SqliteCache.getInstance();
      _tour = cache.getTourFromId(tourId);
    }

    return _tour!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      body: Center(
        child: FutureBuilder(
          future: _getOrReturnTour(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AnimatedTextKit(
                    isRepeatingAnimation: false,
                    animatedTexts: [
                      TyperAnimatedText(
                        AppLocalizations.of(context)!.welcomeToChocoTur,
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      FadeAnimatedText(
                        snapshot.data!.name,
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                    ],
                    onFinished: () => _onAnimationFinished(context),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Hero(
                      tag: snapshot.data!.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(snapshot.data!.mainImageUrl),
                      ),
                    ),
                  ),
                ],
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
