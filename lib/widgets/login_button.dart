import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Styles.redShade,
      ),
      onPressed: () => {Navigator.pushNamed(context, RouteNames.login)},
      icon: const Icon(
        Icons.login_rounded,
        color: Styles.onRedShade,
      ),
      label: Text(
        AppLocalizations.of(context)!.signInButtonLabel,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Styles.onRedShade),
      ),
    );
  }
}
