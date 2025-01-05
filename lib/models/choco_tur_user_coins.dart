import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/material.dart';

class ChocoTurUserCoins extends ChangeNotifier {
  static Future<ChocoTurUserCoins> init(ChocoTurUser user) async {
    int? collectedCoins;
    if (user.loggedIn) {
      collectedCoins = await WebappService.getUserCollectedCoins(user.loginAccessToken);
    }

    return ChocoTurUserCoins(user: user, collectedCoins: collectedCoins);
  }

  ChocoTurUserCoins({
    required this.user,
    this.collectedCoins,
  }) {
    user.addListener(_onLoginChange);
  }

  ChocoTurUser user;
  int? collectedCoins;

  void _onLoginChange() async {
    // If we logged in (no previous collected coins and user is logged), download coins.
    if ((collectedCoins == null) && user.loggedIn) {
      collectedCoins = await WebappService.getUserCollectedCoins(user.loginAccessToken);
    }
    // If we logged out (previous collected coins and user is not logged), nullify coins.
    else if ((collectedCoins != null) && !user.loggedIn) {
      collectedCoins = null;
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

  @override
  void dispose() {
    user.removeListener(_onLoginChange);
    super.dispose();
  }
}
