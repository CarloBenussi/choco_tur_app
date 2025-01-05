import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:flutter/material.dart';

class ChocoTurUserPurchases extends ChangeNotifier {
  static Future<ChocoTurUserPurchases> init(ChocoTurUser user) async {
    List<ChocoTurUserPurchaseInfo>? userPurchases;
    if (user.loggedIn) {
      userPurchases = await WebappService.getUserPurchaseInfos(user.loginAccessToken);
    }

    return ChocoTurUserPurchases(user: user, userPurchases: userPurchases);
  }

  ChocoTurUserPurchases({
    required this.user,
    this.userPurchases,
  }) {
    user.addListener(_onLoginChange);
  }

  ChocoTurUser user;
  List<ChocoTurUserPurchaseInfo>? userPurchases;

  void _onLoginChange() async {
    // If we logged in (no previous collected coins and user is logged), download purchases.
    if ((userPurchases == null) && user.loggedIn) {
      userPurchases = await WebappService.getUserPurchaseInfos(user.loginAccessToken);
    }
    // If we logged out (previous collected coins and user is not logged), nullify purchases.
    else if ((userPurchases != null) && !user.loggedIn) {
      userPurchases = null;
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    userPurchases = await WebappService.getUserPurchaseInfos(user.loginAccessToken);
    notifyListeners();
  }

  @override
  void dispose() {
    user.removeListener(_onLoginChange);
    super.dispose();
  }
}
