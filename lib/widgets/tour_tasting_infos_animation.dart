import 'dart:async';

import 'package:animations/animations.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/title_and_description.dart';
import 'package:flutter/material.dart';

class TourTastingInfosAnimation extends StatefulWidget {
  const TourTastingInfosAnimation({
    super.key,
    required this.langCode,
    required this.tourId,
    required this.tourTastingInfos,
  });

  final String langCode;
  final String tourId;
  final List<ChocoTurTourTastingInfo> tourTastingInfos;

  @override
  State<TourTastingInfosAnimation> createState() => _TourTastingInfosAnimationState();
}

class _TourTastingInfosAnimationState extends State<TourTastingInfosAnimation> {
  int _currentSelectedIndex = 0;
  int _previousSelectedIndex = 0;
  bool _swipeEnabled = true;

  void _onPressed(int index) {
    setState(() {
      _previousSelectedIndex = _currentSelectedIndex;
      _currentSelectedIndex = index;
    });
  }

  void _onSwipeLeft() {
    if (_currentSelectedIndex <= 0) {
      return;
    }

    _swipeEnabled = false;
    Timer(const Duration(milliseconds: 1000), () {
      _swipeEnabled = true;
    });

    setState(() {
      _previousSelectedIndex = _currentSelectedIndex;
      --_currentSelectedIndex;
    });
  }

  void _onSwipeRight() {
    if (_currentSelectedIndex == widget.tourTastingInfos.length - 1) {
      return;
    }

    _swipeEnabled = false;
    Timer(const Duration(milliseconds: 1000), () {
      _swipeEnabled = true;
    });

    setState(() {
      _previousSelectedIndex = _currentSelectedIndex;
      ++_currentSelectedIndex;
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < widget.tourTastingInfos.length; ++i) ...[
              Flexible(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () => _onPressed(i),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: (i == _currentSelectedIndex) ? Colors.white : Styles.redShade,
                  ),
                  child: null,
                ),
              ),
              if (i < widget.tourTastingInfos.length - 1)
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Divider(
                      color: Styles.redShade,
                      thickness: 0.7,
                    ),
                  ),
                ),
            ]
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
          child: GestureDetector(
            key: ValueKey<int>(_currentSelectedIndex),
            onPanUpdate: (details) {
              if (_swipeEnabled) {
                int sensitivity = 8;
                if (details.delta.dx < -sensitivity) {
                  return _onSwipeRight();
                }

                if (details.delta.dx > sensitivity) {
                  return _onSwipeLeft();
                }
              }
            },
            child: LimitedBox(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: TitleAndDescription(
                      title: widget.tourTastingInfos[_currentSelectedIndex].titles[widget.langCode]!,
                      description: widget.tourTastingInfos[_currentSelectedIndex].descriptions[widget.langCode]!,
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          widget.tourTastingInfos[_currentSelectedIndex].imageData!,
                        ),
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
