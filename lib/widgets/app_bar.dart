import 'package:flutter/material.dart';

class ChocoTurAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChocoTurAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
