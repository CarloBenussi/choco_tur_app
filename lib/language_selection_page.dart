import 'package:choco_tur/utils/lang_codes.dart';
import 'package:choco_tur/widgets/language_selection_button.dart';
import 'package:flutter/material.dart';

class LanguageSelection extends StatelessWidget {
  const LanguageSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("ChocoTur",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                padding: const EdgeInsets.all(10),
                children: const [
                  LanguageSelectionButton(language: LanguageCodes.EN),
                  LanguageSelectionButton(language: LanguageCodes.IT),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
