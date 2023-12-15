import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/language_selection_dropdown_menu.dart';
import 'package:flutter/material.dart';

class LanguageSelection extends StatelessWidget {
  const LanguageSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.redShade,
      body: const Center(
        child: LanguageSelectionDropdownMenu(),
      ),
    );
  }
}
