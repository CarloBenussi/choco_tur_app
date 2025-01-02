import 'dart:ui';

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/login_button.dart';
import 'package:choco_tur/widgets/my_tours_background_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyToursUi extends StatefulWidget {
  const MyToursUi({super.key});

  @override
  State<MyToursUi> createState() => _MyToursUiState();
}

class _MyToursUiState extends State<MyToursUi> {
  bool _processing = false;
  List<ChocoTurUserTour>? _userTours;

  List<ChocoTurUserTour>? _getUserTours(BuildContext context) {
    return Provider.of<ChocoTurUser>(context, listen: true).userTours;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _userTours = _getUserTours(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MyToursBackgroundPainter(),
      child: Consumer<ChocoTurUser>(
        builder: (context, user, child) {
          if ((_userTours != null) && (_userTours!.isNotEmpty)) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ListView.separated(
                    itemCount: _userTours!.length,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(5),
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 5);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Styles.redShade,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          textColor: Styles.onRedShade,
                          leading: const Icon(Icons.tour_outlined),
                          iconColor: Styles.onRedShade,
                          title: Text(_userTours![index].title),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                backgroundColor: Styles.onRedShade,
                                valueColor: const AlwaysStoppedAnimation<Color>(Styles.gold),
                                value: _userTours![index].progress,
                              ),
                              Text(
                                _userTours![index].isActive
                                    ? AppLocalizations.of(context)!.active
                                    : AppLocalizations.of(context)!.inactive,
                                style: const TextStyle(color: Styles.onRedShade),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<PopupMenuItem>(
                            itemBuilder: (BuildContext context) => [
                              if (_userTours![index].isActive)
                                PopupMenuItem(
                                  onTap: () async {
                                    setState(() {
                                      _processing = true;
                                    });
                                    await user.advanceTour(context, _userTours![index]);
                                    setState(() {
                                      _processing = false;
                                    });
                                  },
                                  child: Text(AppLocalizations.of(context)!.nextStop),
                                ),
                              if (_userTours![index].isActive)
                                PopupMenuItem(
                                  onTap: () async {
                                    setState(() {
                                      _processing = true;
                                    });
                                    await user.revertTourStop(context, _userTours![index]);
                                    setState(() {
                                      _processing = false;
                                    });
                                  },
                                  child: Text(AppLocalizations.of(context)!.previousStop),
                                ),
                              if (!_userTours![index].isActive)
                                PopupMenuItem(
                                  onTap: () async {
                                    setState(() {
                                      _processing = true;
                                    });
                                    SqliteCache cache = await SqliteCache.getInstance();
                                    ChocoTurTour? tour = await cache.getTourFromId(_userTours![index].id);
                                    await user.activateTour(context, tour!);
                                    setState(() {
                                      _processing = false;
                                    });
                                  },
                                  child: Text(AppLocalizations.of(context)!.reactivateTour),
                                ),
                              if (_userTours![index].isActive)
                                PopupMenuItem(
                                  onTap: () async {
                                    setState(() {
                                      _processing = true;
                                    });
                                    await user.deactivateTour(context, _userTours![index]);
                                    setState(() {
                                      _processing = false;
                                    });
                                  },
                                  child: Text(AppLocalizations.of(context)!.deactivate),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_processing)
                  Flexible(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ),
                      child: const Center(
                        child: LoadingAnimation(),
                      ),
                    ),
                  ),
              ],
            );
          } else if (!Provider.of<ChocoTurUser>(context, listen: false).loggedIn) {
            return const Center(child: LoginButton());
          } else {
            return Center(
                child: Text(AppLocalizations.of(context)!.noUserTourFound, style: TextStyle(color: Styles.redShade)));
          }
        },
      ),
    );
  }
}
