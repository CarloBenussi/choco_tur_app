import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyTourPage extends StatefulWidget {
  const MyTourPage({super.key});

  @override
  State<MyTourPage> createState() => _MyTourPageState();
}

class _MyTourPageState extends State<MyTourPage> {
  int? _lastActiveTourId;
  int? _lastTourNextStopId;
  List<ChocoTurTour>? _myTours;
  List<double>? _myTourProgresses;

  Future<List<ChocoTurTour>> _getOrReturnMyTours(
      int? activeTourId, int? tourNextStopId) async {
    if ((_lastActiveTourId == activeTourId) &&
        (_lastTourNextStopId == tourNextStopId)) {
      return _myTours ?? [];
    }

    _lastActiveTourId = activeTourId;
    _lastTourNextStopId = tourNextStopId;

    if (activeTourId == null) {
      _myTours = [];
      _myTourProgresses = [];
    } else {
      SqliteCache cache = await SqliteCache.getInstance();

      _myTours = [await cache.getTourFromId(activeTourId)];
      var tourStopIds = await cache.getTourStopIds(_myTours![0].id);
      var tourNextStopIndex = tourStopIds.indexOf(tourNextStopId!);
      _myTourProgresses = [tourNextStopIndex / _myTours![0].numStops];
    }

    return _myTours!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      body: Consumer<ChocoTurUser>(
        builder: (context, user, child) {
          return FutureBuilder(
            future: _getOrReturnMyTours(user.activeTourId, user.tourNextStopId),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data!.isNotEmpty) {
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(5),
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 5);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: const Icon(Icons.tour_outlined),
                        title: Text(snapshot.data![index].name),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _myTourProgresses![index],
                            ),
                            const Text("ACTIVE"),
                          ],
                        ),
                        trailing: PopupMenuButton<PopupMenuItem>(
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              onTap: () {
                                user.deactivateTour(user.activeTourId!);
                              },
                              child: const Text("Deactivate"),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No Active tour found"));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(
        selectedIndex: 2,
      ),
    );
  }
}
