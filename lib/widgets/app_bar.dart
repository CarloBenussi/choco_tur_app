import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/gianduiotto_collector.dart';
import 'package:flutter/material.dart';

class ChocoTurAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChocoTurAppBar({super.key, this.tabBar});

  final TabBar? tabBar;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Styles.onRedShade,
      foregroundColor: Styles.redShade,
      actions: (tabBar != null) ? null : const [GianduiottoCollector()],
      bottom: tabBar,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
