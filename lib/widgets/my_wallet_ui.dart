// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/models/choco_tur_user_wallet.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/logger.dart';
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
  ChangeNotifier? _walletProvider;
  List<ChocoTurOffer>? _offers;
  List<ChocoTurUserPurchaseInfo>? _userPurchases;

  Future<void> _refresh(BuildContext context) async {
    _offers = null;
    _userPurchases = null;
    await _getOffersAndUserPurchases(context, refresh: true);

    setState(() {});
  }

  Future<bool> _getOffersAndUserPurchases(BuildContext context, {bool refresh = false}) async {
    _offers ??= await WebappService.getOffers(context, tryFromCache: !refresh);
    if (refresh) {
      await Provider.of<ChocoTurUserWallet>(context, listen: false).refresh();
    }
    _userPurchases ??= Provider.of<ChocoTurUserWallet>(context, listen: false).userPurchases;

    return true;
  }

  ChocoTurOffer? _getOfferFromPurchase(ChocoTurUserPurchaseInfo purchaseInfo) {
    for (var offer in _offers!) {
      if (offer.id == purchaseInfo.offerId) {
        return offer;
      }
    }

    LoggerInstance.logger.e('No offer found with ID ${purchaseInfo.offerId}');
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // final newWalletProvider = Provider.of<ChocoTurUserWallet>(context, listen: true);

    // if (_walletProvider != newWalletProvider && mounted) {
    //   _walletProvider?.removeListener(() => _refresh(context));
    //   _walletProvider = newWalletProvider;
    //   _walletProvider?.addListener(() => _refresh(context));
    // }
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
                                  Provider.of<ChocoTurUserWallet>(context, listen: true).collectedCoins?.toString() ??
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
                          future: _getOffersAndUserPurchases(context),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                              return RefreshIndicator(
                                onRefresh: () => _refresh(context),
                                child: ListView.builder(
                                    itemCount: _offers!.length,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: OfferTile(offer: _offers![index]),
                                      );
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
                          future: _getOffersAndUserPurchases(context),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                              return RefreshIndicator(
                                onRefresh: () => _refresh(context),
                                child: ListView.builder(
                                    itemCount: _userPurchases!.length,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(bottom: 5),
                                    itemBuilder: (BuildContext context, int index) {
                                      return UserPurchaseTile(
                                          userPurchase: _userPurchases![index],
                                          offer: _getOfferFromPurchase(_userPurchases![index])!);
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
              ],
            );
          } else {
            return const Center(child: LoginButton());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    //_walletProvider?.removeListener(() => _refresh(context));

    super.dispose();
  }
}
