import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/tutorial_coach_mark_service.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/coordinates.dart';
import 'package:choco_tur/utils/global_keys.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/home_page_background_painter.dart';
import 'package:choco_tur/widgets/home_page_tour.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    // TODO: Clear cache.
    _tours = null;
    await _getOrReturnTours(context, fromCache: false);
    for (var i = 0; i < _tours!.length; ++i) {
      await _getOrReturnTourImages(_tours![i], fromCache: false);
    }

    setState(() {});
  }

  Future<List<ChocoTurTour>> _getOrReturnTours(BuildContext context, {bool fromCache = true}) async {
    _tours ??= await WebappService.getTours(context, tryFromCache: fromCache);

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    // if (!Provider.of<ChocoTurUser>(context, listen: false).hasSeenTutorial) {
    //   TutorialCoachMarkService.show(context);
    //   Provider.of<ChocoTurUser>(context, listen: false).setHasSeenTutorial();
    // }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKeys.globalKeysMap[GlobalKeys.HOME_TOURS_TITLE_KEY] = GlobalKey();
    GlobalKeys.globalKeysMap[GlobalKeys.APP_BAR_DRAWER_KEY] = GlobalKey();
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      backgroundColor: Colors.transparent,
      drawer: Container(key: GlobalKeys.globalKeysMap[GlobalKeys.APP_BAR_DRAWER_KEY], child: const ChocoTurDrawer()),
      body: CustomPaint(
        painter: HomePageBackgroundPainter(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                "CHOCO TUR",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Styles.darkRedShade,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                AppLocalizations.of(context)!.welcomeToChocoTurHomeSubTitle,
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18, color: Styles.darkRedShade),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 10, right: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  AppLocalizations.of(context)!.toursTitle,
                  key: GlobalKeys.globalKeysMap[GlobalKeys.HOME_TOURS_TITLE_KEY],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Styles.darkRedShade,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _getOrReturnTours(context),
                builder: (context, toursSnapshot) {
                  if (toursSnapshot.hasData &&
                      toursSnapshot.connectionState == ConnectionState.done &&
                      toursSnapshot.data != null) {
                    return RefreshIndicator(
                      onRefresh: () => _onRefresh(context),
                      child: ListView.builder(
                        itemCount: toursSnapshot.data!.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: FutureBuilder(
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
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(child: LoadingAnimation());
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(
        selectedIndex: 0,
      ),
    );
  }
}
