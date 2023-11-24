import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/lang_codes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSelection extends StatelessWidget {
  const LanguageSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey.shade500, Colors.white])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: DropdownMenu(
            width: 0.7 * MediaQuery.of(context).size.width,
            label: const Text('Select a language'),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 5.0),
            ),
            trailingIcon: const Icon(Icons.arrow_downward_rounded),
            onSelected: (String? langCode) {
              Provider.of<ChocoTurUser>(context, listen: false)
                  .setLanguage(context, langCode!);
              Navigator.pushReplacementNamed(context, '/login');
            },
            dropdownMenuEntries: [
              DropdownMenuEntry(
                  value: LanguageCodes.EN,
                  leadingIcon: Image.asset('assets/flags/en.png'),
                  label: "English"),
              DropdownMenuEntry(
                  value: LanguageCodes.IT,
                  leadingIcon: Image.asset('assets/flags/it.png'),
                  label: "Italian"),
            ],
          ),
        ),
      ),
    );
  }
}
