import 'package:animations/animations.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/widgets/title_and_description.dart';
import 'package:flutter/material.dart';

class TourStopsInfoAnimation extends StatefulWidget {
  const TourStopsInfoAnimation({
    super.key,
    required this.tourId,
    required this.tourStops,
    required this.tourStopTastings,
  });

  final int tourId;
  final List<ChocoTurTourStop> tourStops;
  final List<Chocolate?> tourStopTastings;

  @override
  State<TourStopsInfoAnimation> createState() => _TourStopsInfoAnimationState();
}

class _TourStopsInfoAnimationState extends State<TourStopsInfoAnimation> {
  int _currentSelectedIndex = 0;
  int _previousSelectedIndex = 0;

  void _onPressed(int index) {
    setState(() {
      _previousSelectedIndex = _currentSelectedIndex;
      _currentSelectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < widget.tourStops.length; ++i)
              ElevatedButton(
                onPressed: () => _onPressed(i),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _currentSelectedIndex == i ? Colors.red : null,
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
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        PageTransitionSwitcher(
          duration: const Duration(milliseconds: 1000),
          reverse: _currentSelectedIndex < _previousSelectedIndex,
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
            key: ValueKey<int>(_currentSelectedIndex),
            color: Colors.white,
            child: LimitedBox(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        widget.tourStops[_currentSelectedIndex].mainImageUrl,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TitleAndDescription(
                        title: widget.tourStops[_currentSelectedIndex].name,
                        description:
                            widget.tourStops[_currentSelectedIndex].description,
                      ),
                    ),
                  ),
                  if (widget.tourStops[_currentSelectedIndex].hasTasting)
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: TitleAndDescription(
                          title: widget
                              .tourStopTastings[_currentSelectedIndex]!.name,
                          description: widget
                              .tourStopTastings[_currentSelectedIndex]!
                              .description,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
