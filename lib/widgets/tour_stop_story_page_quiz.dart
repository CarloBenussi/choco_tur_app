import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class TourStopStoryPageQuiz extends StatefulWidget {
  const TourStopStoryPageQuiz({super.key, required this.stopStoryPage});

  final ChocoTurStopPage stopStoryPage;

  @override
  State<TourStopStoryPageQuiz> createState() => _TourStopStoryPageQuizState();
}

class _TourStopStoryPageQuizState extends State<TourStopStoryPageQuiz> {
  int? _selectedAnswerIndex;

  Color _decideOnColor(int answerIndex) {
    if (_selectedAnswerIndex == null) {
      return Colors.grey.shade300;
    } else if (answerIndex == widget.stopStoryPage.correctAnswerIndex) {
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

    bool isAnswerCorret =
        (_selectedAnswerIndex == widget.stopStoryPage.correctAnswerIndex);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade300,
        icon: isAnswerCorret
            ? const Icon(
                Icons.check_rounded,
                color: Colors.green,
              )
            : const Icon(
                Icons.clear_rounded,
                color: Colors.white,
              ),
        title: Text(
          isAnswerCorret
              ? AppLocalizations.of(context)!.correct
              : AppLocalizations.of(context)!.wrong,
          style: const TextStyle(color: Colors.white),
        ),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    '${widget.stopStoryPage.onAnswerTexts![_selectedAnswerIndex!]}\n',
                style: const TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: widget.stopStoryPage.afterQuizText!,
                style: const TextStyle(color: Colors.white),
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
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
            decoration: BoxDecoration(
                color: Colors.red.shade300,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(
              widget.stopStoryPage.quizQuestion!,
              style: const TextStyle(color: Colors.white),
            )),
          ),
        ),
        for (var i = 0; i < widget.stopStoryPage.quizAnswers!.length; ++i)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              decoration: BoxDecoration(
                  color: _decideOnColor(i),
                  borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: Text(i.toString()),
                title: Text(widget.stopStoryPage.quizAnswers![i]),
                onTap: () => _giveAnswer(context, i),
              ),
            ),
          ),
        // To avoid back-next buttons to be on top
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
