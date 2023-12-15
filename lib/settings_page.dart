import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/lang_codes.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ChocoTurAppBar(),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(
              AppLocalizations.of(context)!.generalSettingsSection,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.languageSetting),
                value: Text(LanguageCodes.langCodeToLabel(
                    Provider.of<ChocoTurUser>(context, listen: true)
                        .language!)!),
                onPressed: (context) => {},
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(),
    );
  }
}
