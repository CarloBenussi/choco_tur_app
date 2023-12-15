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
  Future<List<ChocoTurTour>>? _myTours;
  List<double>? _myTourProgresses;

  Future<List<ChocoTurTour>> _getMyTours(BuildContext context) async {
    int? activeTourId =
        Provider.of<ChocoTurUser>(context, listen: true).activeTourId;
    int? tourNextStopId =
        Provider.of<ChocoTurUser>(context, listen: true).tourNextStopId;

    List<ChocoTurTour> myTours = [];
    _myTourProgresses = [];

    if (activeTourId != null) {
      SqliteCache cache = await SqliteCache.getInstance();

      myTours = [await cache.getTourFromId(activeTourId)];
      var tourStopIds = await cache.getTourStopIds(myTours[0].id);
      var tourNextStopIndex = tourStopIds.indexOf(tourNextStopId!);
      _myTourProgresses = [tourNextStopIndex / myTours[0].numStops];
    }

    return myTours;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _myTours = _getMyTours(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      backgroundColor: Colors.white,
      body: Consumer<ChocoTurUser>(
        builder: (context, user, child) {
          return FutureBuilder(
            future: _myTours,
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
                      return ColoredBox(
                        color: Colors.red.shade300,
                        child: ListTile(
                          textColor: Colors.white,
                          leading: const Icon(Icons.tour_outlined),
                          iconColor: Colors.white,
                          title: Text(snapshot.data![index].name),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                backgroundColor: Colors.white,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey.shade500),
                                value: _myTourProgresses![index],
                              ),
                              const Text(
                                "ACTIVE",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<PopupMenuItem>(
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                onTap: () {
                                  user.revertTourStop(context);
                                },
                                child: const Text("Previous stop"),
                              ),
                              PopupMenuItem(
                                onTap: () {
                                  user.deactivateTour(user.activeTourId!);
                                },
                                child: const Text("Deactivate"),
                              ),
                            ],
                          ),
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
