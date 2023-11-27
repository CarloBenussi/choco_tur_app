import 'package:animations/animations.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';

class TourStops extends StatefulWidget {
  const TourStops({
    super.key,
    required this.tourStops,
    required this.tourStopDescriptions,
  });

  final List<ChocoTurTourStop> tourStops;
  final List<String> tourStopDescriptions;

  @override
  State<TourStops> createState() => _TourStopsState();
}

class _TourStopsState extends State<TourStops> {
  int _currentSelectedIndex = 0;
  int _lastSelectedIndex = 0;

  void _onPressed(int index) {
    setState(() {
      _lastSelectedIndex = _currentSelectedIndex;
      _currentSelectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.tourStops.length; ++i)
              ElevatedButton(
                onPressed: () => _onPressed(i),
                child: Text(
                  (i + 1).toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        PageTransitionSwitcher(
          duration: const Duration(milliseconds: 2000),
          reverse: _currentSelectedIndex < _lastSelectedIndex,
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.vertical,
              child: child,
            );
          },
          child: Container(
            key: ValueKey<int>(_currentSelectedIndex),
            child: Text(
              widget.tourStops[_currentSelectedIndex].title,
              style: const TextStyle(
                color: ChocoTurStyles.textOnBackgroundColor,
                fontSize: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
