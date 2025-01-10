import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/material.dart';

class ChocoTurUserWallet extends ChangeNotifier {
  static Future<ChocoTurUserWallet> init(ChocoTurUser user) async {
    int? collectedCoins;
    List<ChocoTurUserPurchaseInfo>? userPurchases;
    if (user.loggedIn) {
      collectedCoins = await WebappService.getUserCollectedCoins(user.loginAccessToken);
      userPurchases = await WebappService.getUserPurchaseInfos(user.loginAccessToken);
    }

    return ChocoTurUserWallet(user: user, collectedCoins: collectedCoins, userPurchases: userPurchases);
  }

  ChocoTurUserWallet({
    required this.user,
    this.collectedCoins,
    this.userPurchases,
  }) {
    user.addListener(_onLoginChange);
  }

  ChocoTurUser user;
  int? collectedCoins;
  List<ChocoTurUserPurchaseInfo>? userPurchases;

  void _onLoginChange() async {
    // If we logged in (no previous collected coins and user is logged), download wallet info.
    if ((collectedCoins == null) && user.loggedIn) {
      collectedCoins = await WebappService.getUserCollectedCoins(user.loginAccessToken);
      userPurchases = await WebappService.getUserPurchaseInfos(user.loginAccessToken);
    }
    // If we logged out (previous collected coins and user is not logged), nullify wallet info.
    else if ((collectedCoins != null) && !user.loggedIn) {
      collectedCoins = null;
      userPurchases = null;
    }
    notifyListeners();
  }

  Future<void> addCollectedCoins(BuildContext context, int coins) async {
    bool addCollectedCoinsSuccess = await WebappService.addUserCollectedCoins(context, user.loginAccessToken, coins);
    if (!addCollectedCoinsSuccess) {
      LoggerInstance.logger.e('Failed to add $coins coins on webapp');
    }

    if (collectedCoins == null) {
      collectedCoins = coins;
    } else {
      collectedCoins = collectedCoins! + coins;
    }
    notifyListeners();
  }

  Future<void> purchaseOffer(BuildContext context, ChocoTurOffer offer) async {
    bool purchaseOfferSuccess = await WebappService.purchaseOffer(context, user.loginAccessToken, offer.id);
    if (!purchaseOfferSuccess) {
      LoggerInstance.logger.e('Failed to purchase offer ${offer.id} on webapp');
      return;
    }

    if (collectedCoins == null) {
      LoggerInstance.logger.e('Coins collected is null');
    } else {
      collectedCoins = collectedCoins! - offer.tokensCost;
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    collectedCoins = await WebappService.getUserCollectedCoins(user.loginAccessToken);
    userPurchases = await WebappService.getUserPurchaseInfos(user.loginAccessToken);

    notifyListeners();
  }

  @override
  void dispose() {
    user.removeListener(_onLoginChange);
    super.dispose();
  }
}
