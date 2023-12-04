import 'package:animations/animations.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/services/SqliteCache.dart';
import 'package:choco_tur/widgets/title_and_description.dart';
import 'package:flutter/material.dart';

class TourStopsInfoAnimation extends StatefulWidget {
  const TourStopsInfoAnimation({
    super.key,
    required this.tourId,
  });

  final String tourId;

  @override
  State<TourStopsInfoAnimation> createState() => _TourStopsInfoAnimationState();
}

class _TourStopsInfoAnimationState extends State<TourStopsInfoAnimation> {
  late final Future<List<ChocoTurTourStop>> _tourStops;
  late final List<Future<Chocolate?>> _tourStopChocolates;

  int _currentSelectedIndex = 0;
  int _previousSelectedIndex = 0;

  void _onPressed(int index) {
    setState(() {
      _previousSelectedIndex = _currentSelectedIndex;
      _currentSelectedIndex = index;
    });
  }

  @override
  void initState() async {
    super.initState();

    SqliteCache cache = await SqliteCache.getInstance();

    _tourStops = cache.getTourStops(widget.tourId);

    var tourStops = await _tourStops;
    for (var i = 0; i < tourStops.length; ++i) {
      _tourStopChocolates.add(cache.getStopchocolate(tourStops[i].id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _tourStops,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < snapshot.data!.length; ++i)
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
                              snapshot
                                  .data![_currentSelectedIndex].mainImageUrl,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TitleAndDescription(
                              title: snapshot.data![_currentSelectedIndex].name,
                              description: snapshot
                                  .data![_currentSelectedIndex].description,
                            ),
                          ),
                        ),
                        if (snapshot.data![_currentSelectedIndex].hasTasting)
                          FutureBuilder(
                            future: _tourStopChocolates[_currentSelectedIndex],
                            builder: (context, chocolateSnapshot) {
                              if (chocolateSnapshot.hasData &&
                                  chocolateSnapshot.connectionState ==
                                      ConnectionState.done &&
                                  (chocolateSnapshot.data != null)) {
                                return Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: TitleAndDescription(
                                      title: chocolateSnapshot.data!.name,
                                      description:
                                          chocolateSnapshot.data!.description,
                                    ),
                                  ),
                                );
                              } else if (chocolateSnapshot.hasData &&
                                  chocolateSnapshot.connectionState ==
                                      ConnectionState.done &&
                                  (chocolateSnapshot.data == null)) {
                                return const Text(
                                    "COULD NOT FIND CHOCOLATE DATA.");
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
