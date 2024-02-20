import 'package:animations/animations.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/tour_stop_story_quiz.dart';
import 'package:choco_tur/widgets/tour_stop_story_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TourStopStoriesPage extends StatefulWidget {
  const TourStopStoriesPage({super.key, required this.tourStopStories});

  final List<ChocoTurStopStory> tourStopStories;

  @override
  State<TourStopStoriesPage> createState() => _TourStopStoriesPageState();
}

class _TourStopStoriesPageState extends State<TourStopStoriesPage> {
  late int _currentPageIndex;
  bool _backPressed = false;

  void _onNextPressed(BuildContext context, int stopStoryPagesLength) async {
    if (_currentPageIndex < stopStoryPagesLength - 1) {
      _currentPageIndex++;
      _backPressed = false;
      setState(() {});
    } else {
      ChocoTurUserTour? userTour = Provider.of<ChocoTurUser>(context, listen: false).activeTour;
      await Provider.of<ChocoTurUser>(context, listen: false).advanceTour(userTour!);
      if (mounted) {
        if (Provider.of<ChocoTurUser>(context, listen: false).activeTour != null) {
          Navigator.pushReplacementNamed(context, RouteNames.map, arguments: true);
        } else {
          Navigator.pushReplacementNamed(context, RouteNames.home);
        }
      }
    }
  }

  void _onBackPressed(BuildContext context) {
    _currentPageIndex--;
    _backPressed = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _currentPageIndex = 0;
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
            if (widget.tourStopStories[_currentPageIndex].type == ChocoTurStopStoryType.text)
              TourStopStoryText(stopStory: widget.tourStopStories[_currentPageIndex]),
            if (widget.tourStopStories[_currentPageIndex].type == ChocoTurStopStoryType.quiz)
              TourStopStoryQuiz(stopStory: widget.tourStopStories[_currentPageIndex]),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _currentPageIndex > 0 ? () => _onBackPressed(context) : null,
                    child: Text(
                      AppLocalizations.of(context)!.backButton,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: (_currentPageIndex > 0) ? Styles.redShade : null,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _onNextPressed(context, widget.tourStopStories.length),
                    child: Text(
                      (_currentPageIndex < widget.tourStopStories.length - 1)
                          ? AppLocalizations.of(context)!.nextButton
                          : "-->",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Styles.redShade,
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
