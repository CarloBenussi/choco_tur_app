import 'package:choco_tur/utils/route_names.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ChocoTurDrawer extends StatelessWidget {
  const ChocoTurDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text(
              "ChocoTur",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.settings_outlined,
            ),
            title: Text(AppLocalizations.of(context)!.settingsButton),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.settings);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.account_circle_outlined,
            ),
            title: Text(AppLocalizations.of(context)!.accountButton),
          ),
          ListTile(
              leading: const Icon(
                Icons.logout_outlined,
              ),
              title: Text(AppLocalizations.of(context)!.logoutButton),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.areYouSureLogout),
                    content: Text(AppLocalizations.of(context)!
                        .areYouSureLogoutIndication),
                    actions: [
                      TextButton(
                          onPressed: null,
                          child: Text(AppLocalizations.of(context)!.yesButton)),
                      TextButton(
                          onPressed: null,
                          child: Text(AppLocalizations.of(context)!.noButton)),
                    ],
                    elevation: 24.0,
                  ),
                  barrierDismissible: true,
                );
              }),
          const Divider(
            thickness: 0.5,
            color: Colors.grey,
          ),
          ListTile(
            leading: const Icon(
              Icons.question_mark_outlined,
            ),
            title: Text(AppLocalizations.of(context)!.guideAndFeedbackButton),
          ),
          ListTile(
              leading: const Icon(
                Icons.info_outline_rounded,
              ),
              title: Text(AppLocalizations.of(context)!.aboutButton),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationVersion: "1.0.0",
                  applicationIcon: const Icon(Icons.tour_rounded),
                  applicationLegalese: "Legalese",
                  barrierDismissible: true,
                );
              }),
        ],
      ),
    );
  }
}
