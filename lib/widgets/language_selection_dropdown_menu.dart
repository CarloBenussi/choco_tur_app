import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/lang_codes.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSelectionDropdownMenu extends StatelessWidget {
  const LanguageSelectionDropdownMenu({super.key, required this.afterSelection});

  final Function(BuildContext) afterSelection;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: DropdownMenu(
        width: 0.7 * MediaQuery.of(context).size.width,
        label: const Text('Select a language'),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
        ),
        leadingIcon: const Icon(Icons.language),
        trailingIcon: const Icon(Icons.arrow_downward_rounded),
        onSelected: (String? langCode) {
          Provider.of<ChocoTurUser>(context, listen: false).setLanguage(context, langCode!);
          afterSelection(context);
        },
        dropdownMenuEntries: [
          DropdownMenuEntry(
              value: LanguageCodes.EN,
              leadingIcon: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    'icons/flags/png100px/gb.png',
                    package: 'country_icons',
                    width: 30,
                    height: 30,
                  )),
              label: LanguageCodes.langCodeToLabel(LanguageCodes.EN)!),
          DropdownMenuEntry(
              value: LanguageCodes.IT,
              leadingIcon: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    'icons/flags/png100px/it.png',
                    package: 'country_icons',
                    width: 30,
                    height: 30,
                  )),
              label: LanguageCodes.langCodeToLabel(LanguageCodes.IT)!),
        ],
      ),
    );
  }
}
