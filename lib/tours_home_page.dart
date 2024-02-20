import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/coordinates.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/home_page_tour.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToursHomePage extends StatefulWidget {
  const ToursHomePage({super.key});

  @override
  State<ToursHomePage> createState() => HomePageState();
}

class HomePageState extends State<ToursHomePage> {
  List<ChocoTurTour>? _tours;

  Future<void> _onRefresh(BuildContext context) async {
    _tours = null;
    await _getOrReturnTours(context, fromCache: false);
    for (var i = 0; i < _tours!.length; ++i) {
      await _getOrReturnTourImages(_tours![i], fromCache: false);
    }

    setState(() {});
  }

  Future<List<ChocoTurTour>> _getOrReturnTours(BuildContext context, {bool fromCache = true}) async {
    if (_tours == null) {
      if (fromCache) {
        SqliteCache cache = await SqliteCache.getInstance();
        _tours = await cache.getTours();
      }

      if ((_tours == null) || _tours!.isEmpty) {
        String? accessToken = Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken;
        _tours = await WebappService.getTours(context, accessToken);

        SqliteCache cache = await SqliteCache.getInstance();
        cache.saveTours(_tours!);
      }
    }

    return _tours!;
  }

  Future<int> _getOrReturnTourImages(ChocoTurTour tour, {bool fromCache = true}) async {
    if (!tour.hasImages()) {
      await tour.downloadImages(tryFromCache: fromCache);
    }

    return 0;
  }

  @override
  void initState() {
    super.initState();

    Coordinates.checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      backgroundColor: Colors.white,
      drawer: const ChocoTurDrawer(),
      body: Stack(
        children: [
          FutureBuilder(
            future: _getOrReturnTours(context),
            builder: (context, toursSnapshot) {
              if (toursSnapshot.hasData &&
                  toursSnapshot.connectionState == ConnectionState.done &&
                  toursSnapshot.data != null) {
                return RefreshIndicator(
                  onRefresh: () => _onRefresh(context),
                  child: ListView.separated(
                    itemCount: toursSnapshot.data!.length,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(5),
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 5);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return FutureBuilder(
                        future: _getOrReturnTourImages(toursSnapshot.data![index]),
                        builder: (context, voidSnapshot) {
                          if (voidSnapshot.hasData &&
                              voidSnapshot.connectionState == ConnectionState.done &&
                              voidSnapshot.data != null) {
                            return HomePageTour(chocoTurTour: toursSnapshot.data![index]);
                          } else {
                            return const Center(child: LoadingAnimation());
                          }
                        },
                      );
                    },
                  ),
                );
              } else {
                return const Center(child: LoadingAnimation());
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(
        selectedIndex: 0,
      ),
    );
  }
}
