import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChocoTurDrawer extends StatelessWidget {
  const ChocoTurDrawer({super.key});

  void _onLogoutPressed(BuildContext context) async {
    await Provider.of<ChocoTurUser>(context, listen: false).logout();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Styles.redShade,
      surfaceTintColor: Styles.onRedShade,
      shadowColor: Styles.onRedShade,
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text(
              "CHOCO TUR",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Styles.onRedShade),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.settings_outlined,
              color: Styles.onRedShade,
            ),
            title: Text(
              AppLocalizations.of(context)!.settingsButton,
              style: const TextStyle(color: Styles.onRedShade),
            ),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.settings);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.account_circle_outlined,
              color: Styles.onRedShade,
            ),
            title: Text(
              AppLocalizations.of(context)!.accountButton,
              style: const TextStyle(color: Styles.onRedShade),
            ),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.account);
            },
          ),
          ListTile(
              leading: const Icon(
                Icons.logout_outlined,
                color: Styles.onRedShade,
              ),
              title: Text(
                AppLocalizations.of(context)!.logoutButton,
                style: const TextStyle(color: Styles.onRedShade),
              ),
              onTap: Provider.of<ChocoTurUser>(context).loggedIn
                  ? () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: Styles.redShade,
                          title: Text(
                            AppLocalizations.of(context)!.areYouSureLogout,
                            style: const TextStyle(color: Styles.onRedShade),
                          ),
                          content: Text(
                            AppLocalizations.of(context)!.areYouSureLogoutIndication,
                            style: const TextStyle(color: Styles.onRedShade),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => {Navigator.pop(context)},
                                child: Text(
                                  AppLocalizations.of(context)!.noButton,
                                  style: const TextStyle(color: Styles.onRedShade),
                                )),
                            TextButton(
                                onPressed: () => _onLogoutPressed(context),
                                child: Text(
                                  AppLocalizations.of(context)!.yesButton,
                                  style: const TextStyle(color: Styles.onRedShade),
                                )),
                          ],
                          elevation: 24.0,
                        ),
                        barrierDismissible: true,
                      );
                    }
                  : null),
          const Divider(
            thickness: 0.5,
            color: Styles.onRedShade,
          ),
          ListTile(
            leading: const Icon(
              Icons.question_mark_outlined,
              color: Styles.onRedShade,
            ),
            title: Text(
              AppLocalizations.of(context)!.guideAndFeedbackButton,
              style: const TextStyle(color: Styles.onRedShade),
            ),
          ),
          ListTile(
              leading: const Icon(
                Icons.info_outline_rounded,
                color: Styles.onRedShade,
              ),
              title: Text(
                AppLocalizations.of(context)!.aboutButton,
                style: const TextStyle(color: Styles.onRedShade),
              ),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "CHOCO TUR",
                  applicationVersion: "1.0.0",
                  applicationIcon: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      "assets/logo.png",
                      width: 40,
                    ),
                  ),
                  applicationLegalese: "Legalese",
                  barrierDismissible: true,
                );
              }),
        ],
      ),
    );
  }
}
