import 'package:badges/badges.dart' as badges;
import 'package:choco_tur/models/choco_tur_user_wallet.dart';
import 'package:choco_tur/utils/global_keys.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GianduiottoCollector extends StatefulWidget {
  const GianduiottoCollector({super.key});

  @override
  State<GianduiottoCollector> createState() => _GianduiottoCollectorState();
}

class _GianduiottoCollectorState extends State<GianduiottoCollector> {
  int? _collectedCoins;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _collectedCoins = Provider.of<ChocoTurUserWallet>(context, listen: true).collectedCoins;
  }

  void onPressed(BuildContext context) {
    Navigator.pushNamed(context, RouteNames.myChocoTur, arguments: 1);
  }

  @override
  Widget build(BuildContext context) {
    GlobalKeys.globalKeysMap[GlobalKeys.APP_BAR_TOKENS_KEY] = GlobalKey();
    return badges.Badge(
      key: GlobalKeys.globalKeysMap[GlobalKeys.APP_BAR_TOKENS_KEY],
      position: badges.BadgePosition.bottomEnd(bottom: -8, end: 10),
      badgeContent: Text(
        (_collectedCoins != null) ? _collectedCoins.toString() : "?",
        style: const TextStyle(color: Styles.onRedShade),
      ),
      showBadge: true,
      badgeAnimation: const badges.BadgeAnimation.rotation(
        animationDuration: Duration(seconds: 1),
        colorChangeAnimationDuration: Duration(seconds: 1),
        loopAnimation: false,
        curve: Curves.fastOutSlowIn,
        colorChangeAnimationCurve: Curves.easeInCubic,
      ),
      badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.circle,
        badgeColor: Styles.redShade,
      ),
      child: IconButton(
        onPressed: () => onPressed(context),
        icon: Image.asset(
          "assets/chocolateIcon.png",
          width: 30,
        ),
      ),
    );
    // TODO: Get user collected coins and show them (with question mark if not logged in)
  }
}
