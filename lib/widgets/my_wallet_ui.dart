// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/models/choco_tur_user_coins.dart';
import 'package:choco_tur/models/choco_tur_user_purchases.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/login_button.dart';
import 'package:choco_tur/widgets/my_tours_background_painter.dart';
import 'package:choco_tur/widgets/offer_tile.dart';
import 'package:choco_tur/widgets/user_purchase_tile.dart';
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
  List<ChocoTurOffer>? _offers;
  List<ChocoTurUserPurchaseInfo>? _userPurchases;

  Future<void> _onRefresh(BuildContext context) async {
    // TODO: Clear cache?.
    _offers = null;
    await _getOrReturnOffers(context, fromCache: false);
    await _getOrReturnUserPurchases(context, refresh: true);

    setState(() {});
  }

  Future<void> _onOfferPurchased(BuildContext context, ChocoTurOffer offer) async {
    setState(() {
      _processing = true;
    });

    // TODO: Send web request for purchase, refresh

    setState(() {
      _processing = false;
    });
  }

  Future<void> _onUserPurchaseRedeemed(BuildContext context, ChocoTurUserPurchaseInfo userPurchase) async {
    setState(() {
      _processing = true;
    });

    // TODO: Code and stuff, refresh

    setState(() {
      _processing = false;
    });
  }

  Future<List<ChocoTurOffer>> _getOrReturnOffers(BuildContext context, {bool fromCache = true}) async {
    _offers ??= await WebappService.getOffers(context, tryFromCache: fromCache);

    return _offers!;
  }

  Future<List<ChocoTurUserPurchaseInfo>> _getOrReturnUserPurchases(BuildContext context, {bool refresh = false}) async {
    if (refresh) {
      await Provider.of<ChocoTurUserPurchases>(context, listen: false).refresh();
    }
    _userPurchases ??= Provider.of<ChocoTurUserPurchases>(context, listen: false).userPurchases;

    return _userPurchases!;
  }

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
                          AppLocalizations.of(context)!.availableOffers,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Styles.redShade),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: FutureBuilder(
                          future: _getOrReturnOffers(context),
                          builder: (context, offersSnapshot) {
                            if (offersSnapshot.hasData &&
                                offersSnapshot.connectionState == ConnectionState.done &&
                                offersSnapshot.data != null) {
                              return RefreshIndicator(
                                onRefresh: () => _onRefresh(context),
                                child: ListView.builder(
                                    itemCount: offersSnapshot.data!.length,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (BuildContext context, int index) {
                                      return OfferTile(
                                          offer: offersSnapshot.data![index], onPurchase: _onOfferPurchased);
                                    }),
                              );
                            } else {
                              return const Center(child: LoadingAnimation());
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          AppLocalizations.of(context)!.purchasedOffers,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Styles.redShade),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: FutureBuilder(
                          future: _getOrReturnUserPurchases(context),
                          builder: (context, userPurchasesSnapshot) {
                            if (userPurchasesSnapshot.hasData &&
                                userPurchasesSnapshot.connectionState == ConnectionState.done &&
                                userPurchasesSnapshot.data != null) {
                              return RefreshIndicator(
                                onRefresh: () => _onRefresh(context),
                                child: ListView.builder(
                                    itemCount: userPurchasesSnapshot.data!.length,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (BuildContext context, int index) {
                                      return UserPurchaseTile(
                                          userPurchase: userPurchasesSnapshot.data![index],
                                          onRedeem: _onUserPurchaseRedeemed);
                                    }),
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
