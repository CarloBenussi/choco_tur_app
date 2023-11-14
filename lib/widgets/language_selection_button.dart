import 'package:choco_tur/models/choco_tur_model.dart';
import 'package:choco_tur/utils/lang_codes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSelectionButton extends StatelessWidget {
  LanguageSelectionButton({super.key, required this.language});

  final String language;
  late final BuildContext context;

  void onLanguagePressed() {
    Provider.of<ChocoTurModel>(context, listen: false)
        .setLanguage(context, language);
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Column(
      children: [
        IconButton.filled(
          onPressed: onLanguagePressed,
          icon: Image.asset('assets/flags/$language.png'),
        ),
        Text(
          LanguageCodes.langCodeToLabel(language) ?? "Unknown Language",
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
