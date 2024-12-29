import 'dart:ui';

import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/models/choco_tur_user_coins.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/login_button.dart';
import 'package:choco_tur/widgets/my_tours_background_painter.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:choco_tur/widgets/prize_list_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MyTourPage extends StatefulWidget {
  const MyTourPage({super.key, this.initialIndex});

  final int? initialIndex;

  @override
  State<MyTourPage> createState() => _MyTourPageState();
}

class _MyTourPageState extends State<MyTourPage> {
  List<ChocoTurUserTour>? _userTours;
  bool _processing = false;

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
    return DefaultTabController(
      initialIndex: widget.initialIndex ?? 0,
      length: 2,
      child: Scaffold(
        appBar: ChocoTurAppBar(
          tabBar: TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.tour_outlined,
                  color: Styles.redShade,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.wallet_outlined,
                  color: Styles.redShade,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        body: TabBarView(
          children: [
            CustomPaint(
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
                        child: Text(AppLocalizations.of(context)!.noUserTourFound,
                            style: TextStyle(color: Styles.redShade)));
                  }
                },
              ),
            ),
            CustomPaint(
              painter: MyToursBackgroundPainter(),
              child: Consumer<ChocoTurUser>(
                builder: (context, user, child) {
                  if (Provider.of<ChocoTurUser>(context, listen: false).loggedIn) {
                    return Column(
                      children: [
                        Flexible(
                          child: ListView(
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.all(10.0),
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                                child: Container(
                                  color: Styles.redShade,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          Provider.of<ChocoTurUserCoins>(context, listen: true)
                                                  .collectedCoins
                                                  ?.toString() ??
                                              "?",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 24, color: Styles.onRedShade),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.tokensInYourWallet,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 12, color: Styles.onRedShade),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  AppLocalizations.of(context)!.prizes,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Styles.redShade),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: PrizeListTile(
                                  cost: 5,
                                  title: "10% discount",
                                  info:
                                      "You have 10% discount on one purchase redeemable at the following shops: Guido Castagna",
                                  onPressed: (context) => {},
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: PrizeListTile(
                                  cost: 20,
                                  title: "Chocolate tasting",
                                  info:
                                      "You can use this prize to get a special chocolate tasting at the following shops: Gobino",
                                  onPressed: (context) => {},
                                ),
                              ),
                            ],
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
                  } else {
                    return const Center(child: LoginButton());
                  }
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const ChocoTurNavigationBar(
          selectedIndex: 2,
        ),
      ),
    );
  }
}
