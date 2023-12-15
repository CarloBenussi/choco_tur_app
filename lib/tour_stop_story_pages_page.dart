import 'package:animations/animations.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
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

  void _onNextPressed(BuildContext context, int stopStoryPagesLength) async {
    if (_currentPageIndex < stopStoryPagesLength - 1) {
      _currentPageIndex++;
      Provider.of<ChocoTurUser>(context, listen: false)
          .tourNextStopStoryPageIndex = _currentPageIndex;
      _backPressed = false;
      setState(() {});
    } else {
      await Provider.of<ChocoTurUser>(context, listen: false).advanceTour();
      if (mounted) {
        if (Provider.of<ChocoTurUser>(context, listen: false).activeTourId !=
            null) {
          Navigator.pushReplacementNamed(context, RouteNames.map,
              arguments: true);
        } else {
          Navigator.pushReplacementNamed(context, RouteNames.home);
        }
      }
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
        child: Stack(
          children: [
            if (widget.tourStopStoryPages[_currentPageIndex].type ==
                ChocoTurStopPageType.text)
              TourStopStoryPageText(
                  stopStoryPage: widget.tourStopStoryPages[_currentPageIndex]),
            if (widget.tourStopStoryPages[_currentPageIndex].type ==
                ChocoTurStopPageType.quiz)
              TourStopStoryPageQuiz(
                  stopStoryPage: widget.tourStopStoryPages[_currentPageIndex]),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _currentPageIndex > 0
                        ? () => _onBackPressed(context)
                        : null,
                    style: TextButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.red.shade300,
                    ),
                    child: const Text(
                      "BACK",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _onNextPressed(
                        context, widget.tourStopStoryPages.length),
                    style: TextButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.red.shade300,
                    ),
                    child: Text(
                      (_currentPageIndex < widget.tourStopStoryPages.length - 1)
                          ? "NEXT"
                          : "-->",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
