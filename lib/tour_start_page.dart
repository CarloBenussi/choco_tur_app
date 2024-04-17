import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring/spring.dart';

// ignore: must_be_immutable
class TourStartPage extends StatelessWidget {
  TourStartPage({super.key, required this.tour});

  final ChocoTurTour tour;
  Future<ChocoTurQuiz?>? _tourQuiz;
  final SpringController _springController = SpringController();

  void _onAnimationFinished(BuildContext context) async {
    Navigator.pushReplacementNamed(context, RouteNames.quiz, arguments: await _tourQuiz);
    // var tourStopId = (await _tourStops)!.firstWhere((element) => element.id == "9ZM1ySmjNlvjenLeFepM");
    // Navigator.pushReplacementNamed(context, RouteNames.tourStopStoryChat, arguments: tourStopId);
  }

  @override
  Widget build(BuildContext context) {
    _tourQuiz =
        WebappService.getWelcomeQuiz(context, Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken);
    return Scaffold(
      backgroundColor: Styles.lightPinkShade,
      appBar: const ChocoTurAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spring.bubbleButton(
              springController: _springController,
              animDuration: const Duration(seconds: 2),
              animStatus: (AnimStatus status) {
                if (status == AnimStatus.completed) {
                  _springController.play();
                }
              },
              child: Image.asset(
                "assets/chocolateIcon.png",
                width: 50,
              ),
            ),
            SizedBox(
              height: 50,
              child: AnimatedTextKit(
                isRepeatingAnimation: false,
                animatedTexts: [
                  FadeAnimatedText(
                    AppLocalizations.of(context)!.welcomeToChocoTur,
                    textStyle: TextStyle(fontSize: 20, color: Styles.redShade),
                    duration: const Duration(milliseconds: 3000),
                  ),
                  FadeAnimatedText(
                    tour.title,
                    textStyle: TextStyle(fontSize: 20, color: Styles.redShade),
                    duration: const Duration(milliseconds: 3000),
                  ),
                ],
                onFinished: () => _onAnimationFinished(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
