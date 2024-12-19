import 'package:badges/badges.dart' as badges;
import 'package:choco_tur/models/choco_tur_user.dart';
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

    _collectedCoins = Provider.of<ChocoTurUser>(context, listen: true).collectedCoins;
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
      child: Image.asset(
        "assets/chocolateIcon.png",
      ),
    );
    // TODO: Get user collected coins and show them (with question mark if not logged in)
  }
}
