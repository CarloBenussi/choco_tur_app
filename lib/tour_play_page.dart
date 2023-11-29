import 'package:animations/animations.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:choco_tur/widgets/title_and_description.dart';
import 'package:flutter/material.dart';

class TourPlayPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  TourPlayPage({super.key, required this.chocoTurTour});

  final ChocoTurTour chocoTurTour;

  @override
  State<TourPlayPage> createState() => _TourPlayPageState();
}

class _TourPlayPageState extends State<TourPlayPage> {
  int _currentStopIndex = 0;

  bool backPressed = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const ChocoTurAppBar(),
        backgroundColor: Colors.white,
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 1000),
          reverse: backPressed,
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
            key: ValueKey<int>(_currentStopIndex),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      widget.chocoTurTour.stops[_currentStopIndex].imageUrl,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TitleAndDescription(
                    title: widget.chocoTurTour.stops[_currentStopIndex].title,
                    description:
                        widget.chocoTurTour.stops[_currentStopIndex].stopStory,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _currentStopIndex > 0
                            ? () {
                                _currentStopIndex--;
                                backPressed = true;
                                setState(() {});
                              }
                            : null,
                        child: const Text("BACK"),
                      ),
                      TextButton(
                        onPressed: _currentStopIndex <
                                widget.chocoTurTour.stops.length - 1
                            ? () {
                                _currentStopIndex++;
                                backPressed = true;
                                setState(() {});
                              }
                            : null,
                        child: const Text("NEXT"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const ChocoTurNavigationBar(),
      ),
    );
  }
}
