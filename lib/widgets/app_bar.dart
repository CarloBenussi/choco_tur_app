import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/gianduiotto_collector.dart';
import 'package:flutter/material.dart';

class ChocoTurAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChocoTurAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Styles.onRedShade,
      foregroundColor: Styles.redShade,
      actions: const [GianduiottoCollector()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
