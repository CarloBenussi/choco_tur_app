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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: Text(
                "CHOCO TUR",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Styles.onRedShade),
              ),
            ),
            LanguageSelectionDropdownMenu(),
          ],
        ),
      ),
    );
  }
}
