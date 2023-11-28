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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < widget.tourStops.length; ++i)
                ElevatedButton(
                  onPressed: () => _onPressed(i),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                  child: Text(
                    (i + 1).toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              for (var i = 0; i < widget.tourStops.length; ++i)
                if (i != widget.tourStops.length)
                  const VerticalDivider(
                    thickness: 0.4,
                    color: Colors.grey,
                    indent: 5,
                    endIndent: 5,
                  )
            ],
          ),
        ),
        Flexible(
          flex: 4,
          child: PageTransitionSwitcher(
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
              color: Colors.white,
              child: Column(
                children: [
                  Image.asset(
                    widget.tourStops[_currentSelectedIndex].imageUrl,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "${widget.tourStops[_currentSelectedIndex].title}\n\n",
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color:
                                  ChocoTurStyles.tourInfoTextOnBackgroundColor,
                            ),
                          ),
                          TextSpan(
                            text: widget
                                .tourStops[_currentSelectedIndex].stopInfo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                              color:
                                  ChocoTurStyles.tourInfoTextOnBackgroundColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
