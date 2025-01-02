import 'dart:ui';

import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/models/choco_tur_user_coins.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/login_button.dart';
import 'package:choco_tur/widgets/my_tours_background_painter.dart';
import 'package:choco_tur/widgets/prize_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyWalletUi extends StatefulWidget {
  const MyWalletUi({super.key});

  @override
  State<MyWalletUi> createState() => _MyWalletUiState();
}

class _MyWalletUiState extends State<MyWalletUi> {
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
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
                                  Provider.of<ChocoTurUserCoins>(context, listen: true).collectedCoins?.toString() ??
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
    );
  }
}
