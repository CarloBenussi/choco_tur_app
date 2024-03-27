import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TourStartPage extends StatelessWidget {
  TourStartPage({super.key, required this.tour});

  final ChocoTurTour tour;
  Future<List<ChocoTurStop>?>? _tourStops;

  void _onAnimationFinished(BuildContext context) async {
    List<ChocoTurStop>? stops = await _tourStops;
    // TODO: Fail if null.
    SqliteCache cache = await SqliteCache.getInstance();
    await cache.saveTourStops(stops!);
    // Navigator.pushReplacementNamed(context, RouteNames.map, arguments: true);
    Navigator.pushReplacementNamed(context, RouteNames.tourStopStoryChat,
        arguments: stops.firstWhere((element) => element.id == "9ZM1ySmjNlvjenLeFepM"));
  }

  @override
  Widget build(BuildContext context) {
    _tourStops = WebappService.getTourStops(
        context, tour.id, Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ChocoTurAppBar(),
      body: Center(
        child: AnimatedTextKit(
          isRepeatingAnimation: false,
          animatedTexts: [
            TyperAnimatedText(
              AppLocalizations.of(context)!.welcomeToChocoTur,
              textStyle: const TextStyle(fontSize: 20),
            ),
            FadeAnimatedText(
              tour.title,
              textStyle: const TextStyle(fontSize: 20),
            ),
          ],
          onFinished: () => _onAnimationFinished(context),
        ),
      ),
    );
  }
}
