import 'package:animations/animations.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/widgets/tour_stop_story_page_quiz.dart';
import 'package:choco_tur/widgets/tour_stop_story_page_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TourStopStoryPagesPage extends StatefulWidget {
  const TourStopStoryPagesPage({super.key, required this.tourStopStoryPages});

  final List<ChocoTurStopPage> tourStopStoryPages;

  @override
  State<TourStopStoryPagesPage> createState() => _TourStopStoryPagesPageState();
}

class _TourStopStoryPagesPageState extends State<TourStopStoryPagesPage> {
  late int _currentPageIndex;
  bool _backPressed = false;

  void _onNextPressed(BuildContext context, int stopStoryPagesLength) {
    if (_currentPageIndex < stopStoryPagesLength - 1) {
      _currentPageIndex++;
      Provider.of<ChocoTurUser>(context, listen: false)
          .tourNextStopStoryPageIndex = _currentPageIndex;
      _backPressed = false;
      setState(() {});
    } else {
      // TODO: Advance stop and go to map page.
    }
  }

  void _onBackPressed(BuildContext context) {
    _currentPageIndex--;
    Provider.of<ChocoTurUser>(context, listen: false)
        .tourNextStopStoryPageIndex = _currentPageIndex;
    _backPressed = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _currentPageIndex = Provider.of<ChocoTurUser>(context, listen: false)
            .tourNextStopStoryPageIndex ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 1000),
      reverse: _backPressed,
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
        child: ListView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          children: [
            if (widget.tourStopStoryPages[_currentPageIndex].type ==
                ChocoTurStopPageType.text)
              TourStopStoryPageText(
                  stopStoryPage: widget.tourStopStoryPages[_currentPageIndex]),
            if (widget.tourStopStoryPages[_currentPageIndex].type ==
                ChocoTurStopPageType.quiz)
              TourStopStoryPageQuiz(
                  stopStoryPage: widget.tourStopStoryPages[_currentPageIndex]),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _currentPageIndex > 0
                        ? () => _onBackPressed(context)
                        : null,
                    child: const Text("BACK"),
                  ),
                  TextButton(
                    onPressed: () => _onNextPressed(
                        context, widget.tourStopStoryPages.length),
                    child: const Text("NEXT"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
