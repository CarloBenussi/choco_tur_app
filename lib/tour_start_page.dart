import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:choco_tur/map_page.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/quiz_background_painter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring/spring.dart';

// ignore: must_be_immutable
class TourStartPage extends StatelessWidget {
  TourStartPage({super.key, required this.tour});

  final ChocoTurTour tour;

  bool isWelcomeQuizDone = false;
  Future<ChocoTurQuiz?>? _tourQuiz;
  Future<List<ChocoTurStop>?>? _tourStops;
  final SpringController _springController = SpringController();

  void _onAnimationFinished(BuildContext context) async {
    if (!isWelcomeQuizDone) {
      Navigator.pushReplacementNamed(context, RouteNames.quiz, arguments: await _tourQuiz);
    } else {
      await _tourStops;
      Navigator.pushReplacementNamed(context, RouteNames.map, arguments: IntroDialog(IntroDialogType.goToNextStop));
    }
    // var tourStop = (await WebappService.getTourStops(
    //         context, tour.id, Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken))!
    //     .firstWhere((element) => element.id == "BSaX03wbqXyHcDC1e6gw");
    // Navigator.pushReplacementNamed(context, RouteNames.tourStopStoryChat, arguments: tourStop);
  }

  void _init(BuildContext context) {
    List<ChocoTurUserQuiz>? userQuizs = Provider.of<ChocoTurUser>(context, listen: false).userQuizs;
    if (userQuizs != null) {
      int userWelcomeQuizIndex = userQuizs.indexWhere((element) => element.id == "welcomeQuiz");
      if ((userWelcomeQuizIndex != -1) && userQuizs[userWelcomeQuizIndex].progress >= 0.99) {
        isWelcomeQuizDone = true;
      }
    }

    if (!isWelcomeQuizDone) {
      _tourQuiz =
          WebappService.getWelcomeQuiz(context, Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken);
    } else {
      _tourStops = WebappService.getTourStops(
          context, tour.id, Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken,
          tryFromCache: false, saveToCache: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const ChocoTurAppBar(),
      body: CustomPaint(
        painter: QuizBackgroundPainter(),
        child: Center(
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
      ),
    );
  }
}
