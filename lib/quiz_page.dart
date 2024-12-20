// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animations/animations.dart';
import 'package:choco_tur/map_page.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/models/choco_tur_user_coins.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/dialog.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/quiz_background_painter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.quiz});

  final ChocoTurQuiz quiz;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentPageIndex = 0;
  double _score = 0;
  int? _givenAnswerIndex;
  bool _processing = false;

  String? _langCode;

  void _giveAnswer(BuildContext context, int answerIndex) async {
    if (_givenAnswerIndex != null) return;

    bool correct = (answerIndex == widget.quiz.questions[_currentPageIndex - 1].correctAnswerIndex);

    setState(() {
      _processing = true;
    });
    bool updateQuizScoreSuccess = await WebappService.updateQuizScore(
        context,
        Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken,
        widget.quiz.id,
        _currentPageIndex - 1,
        correct);
    if (!updateQuizScoreSuccess) {
      LoggerInstance.logger.e('Failed to update quiz score for question at index ${_currentPageIndex - 1}');
    }
    if (correct) {
      await Provider.of<ChocoTurUserCoins>(listen: false, context).addCollectedCoins(context, 1);
    }
    setState(() {
      _processing = false;
    });

    setState(() {
      _givenAnswerIndex = answerIndex;
      _score = _score + ((correct ? 1 : 0) / widget.quiz.questions.length);
    });

    showChocoTurDialog(
      context: context,
      title: correct ? AppLocalizations.of(context)!.correct : AppLocalizations.of(context)!.wrong,
      description: widget.quiz.questions[_currentPageIndex - 1].onAnswers[answerIndex][_langCode]!,
      icon: Icon(
        correct ? Icons.check_box_rounded : Icons.close_rounded,
        color: Styles.onRedShade,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _next(context);
          },
          child: Text(
            AppLocalizations.of(context)!.nextButton,
            style: const TextStyle(color: Styles.onRedShade),
          ),
        ),
      ],
      dismissable: true,
    );
  }

  Border? _getBorder(int answerIndex) {
    if (_givenAnswerIndex == null) return null;

    if (answerIndex == widget.quiz.questions[_currentPageIndex - 1].correctAnswerIndex) {
      return Border.all(width: 3, color: Styles.pinkShade);
    }

    if (_givenAnswerIndex == answerIndex) {
      return Border.all(width: 3, color: Styles.redShade);
    }

    return null;
  }

  Icon _getAnswerIcon(int answerIndex) {
    if (_givenAnswerIndex == null) {
      return const Icon(null);
    }

    if (answerIndex == widget.quiz.questions[_currentPageIndex - 1].correctAnswerIndex) {
      return Icon(Icons.check_box_rounded, color: Styles.pinkShade);
    }

    if (_givenAnswerIndex == answerIndex) {
      return Icon(Icons.close_rounded, color: Styles.redShade);
    }

    return const Icon(null);
  }

  void _next(BuildContext context) async {
    if (_currentPageIndex == widget.quiz.questions.length + 1) {
      Navigator.pushReplacementNamed(context, RouteNames.map, arguments: IntroDialog(IntroDialogType.goToNextStop));
    } else {
      setState(() {
        _givenAnswerIndex = null;
        _currentPageIndex++;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _langCode = Provider.of<ChocoTurUser>(context, listen: true).language;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const ChocoTurAppBar(),
        backgroundColor: Colors.transparent,
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 800),
          reverse: false,
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              fillColor: Colors.white,
              child: child,
            );
          },
          child: Container(
            key: ValueKey<int>(_currentPageIndex),
            child: CustomPaint(
              painter: QuizBackgroundPainter(),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Builder(
                      builder: (context) {
                        if (_currentPageIndex == 0) {
                          return Center(
                            child: AnimatedTextKit(
                              isRepeatingAnimation: false,
                              animatedTexts: [
                                TyperAnimatedText(
                                  widget.quiz.intro[_langCode]!,
                                  textStyle: TextStyle(fontSize: 24, color: Styles.redShade),
                                  speed: const Duration(milliseconds: 20),
                                ),
                              ],
                            ),
                          );
                        } else if (_currentPageIndex <= widget.quiz.questions.length) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  minHeight: 150,
                                  maxHeight: 250,
                                ),
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Styles.onRedShade,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5), //color of shadow
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Text(
                                        '${_currentPageIndex.toString()}/${widget.quiz.questions.length}',
                                        style: TextStyle(fontSize: 16, color: Styles.redShade),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: CircularProgressIndicator(
                                        value: _score,
                                        backgroundColor: Colors.grey.shade300,
                                        strokeWidth: 5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Styles.pinkShade),
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 40),
                                        child: Text(
                                          widget.quiz.questions[_currentPageIndex - 1].question[_langCode]!,
                                          style: TextStyle(
                                              fontSize: 18, fontWeight: FontWeight.w600, color: Styles.redShade),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0;
                                      i < widget.quiz.questions[_currentPageIndex - 1].answers.length;
                                      ++i) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        decoration: BoxDecoration(
                                          color: Styles.onRedShade,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5), //color of shadow
                                              spreadRadius: 2,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                          border: _getBorder(i),
                                        ),
                                        child: Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: TextButton.icon(
                                            onPressed: () => _giveAnswer(context, i),
                                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                            icon: _getAnswerIcon(i),
                                            label: Text(
                                              widget.quiz.questions[_currentPageIndex - 1].answers[i][_langCode]!,
                                              style: TextStyle(fontSize: 18, color: Styles.redShade),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              )
                            ],
                          );
                        } else if (_currentPageIndex == widget.quiz.questions.length + 1) {
                          return Center(
                              child: Text("TODO: Page showing the score and giving discount or additional tasting."));
                          // TODO: Page showing the score and giving discount or additional tasting.
                        } else {
                          LoggerInstance.logger.e("Unsupported page index $_currentPageIndex");
                          return const Placeholder();
                        }
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Styles.redShade,
                        ),
                        onPressed: () => _next(context),
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Styles.onRedShade,
                        ),
                        label: Text(
                          (_currentPageIndex == 0)
                              ? AppLocalizations.of(context)!.nextButton
                              : (_givenAnswerIndex == null)
                                  ? AppLocalizations.of(context)!.skipButton
                                  : AppLocalizations.of(context)!.nextButton,
                          style: const TextStyle(color: Styles.onRedShade),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  if (_processing)
                    BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ),
                      child: const Center(
                        child: LoadingAnimation(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
