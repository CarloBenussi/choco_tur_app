import 'package:badges/badges.dart' as badges;
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/models/choco_tur_user_coins.dart';
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

    _collectedCoins = Provider.of<ChocoTurUserCoins>(context, listen: true).collectedCoins;
  }

  void onPressed(BuildContext context) {
    Navigator.pushNamed(context, RouteNames.myTours);
  }

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
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
