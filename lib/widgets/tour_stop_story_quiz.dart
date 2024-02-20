import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class TourStopStoryQuiz extends StatefulWidget {
  const TourStopStoryQuiz({super.key, required this.stopStory});

  final ChocoTurStopStory stopStory;

  @override
  State<TourStopStoryQuiz> createState() => _TourStopStoryQuizState();
}

class _TourStopStoryQuizState extends State<TourStopStoryQuiz> {
  int? _selectedAnswerIndex;

  Color _decideOnColor(int answerIndex) {
    if (_selectedAnswerIndex == null) {
      return Colors.grey.shade300;
    } else if (answerIndex == widget.stopStory.correctAnswerIndex) {
      return Colors.green;
    } else if (answerIndex == _selectedAnswerIndex) {
      return Colors.red;
    } else {
      return Colors.transparent;
    }
  }

  void _giveAnswer(BuildContext context, int answerIndex) {
    _selectedAnswerIndex = answerIndex;
    setState(() {});

    bool isAnswerCorret = (_selectedAnswerIndex == widget.stopStory.correctAnswerIndex);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Styles.redShade,
        icon: isAnswerCorret
            ? const Icon(
                Icons.check_rounded,
                color: Colors.green,
              )
            : const Icon(
                Icons.clear_rounded,
                color: Styles.onRedShade,
              ),
        title: Text(
          isAnswerCorret ? AppLocalizations.of(context)!.correct : AppLocalizations.of(context)!.wrong,
          style: const TextStyle(color: Styles.onRedShade),
        ),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${widget.stopStory.onAnswerTexts![_selectedAnswerIndex!]}\n',
                style: const TextStyle(color: Styles.onRedShade),
              ),
              TextSpan(
                text: widget.stopStory.afterQuizText!,
                style: const TextStyle(color: Styles.onRedShade),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              "QUIZ!",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(color: Styles.redShade, borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text(
                widget.stopStory.quizQuestion!,
                style: const TextStyle(color: Styles.onRedShade),
              )),
            ),
          ),
          for (var i = 0; i < widget.stopStory.quizAnswers!.length; ++i)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                decoration: BoxDecoration(color: _decideOnColor(i), borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  leading: Text((i + 1).toString()),
                  title: Text(widget.stopStory.quizAnswers![i]),
                  onTap: () => _giveAnswer(context, i),
                ),
              ),
            ),
          // To avoid back-next buttons to be on top
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
