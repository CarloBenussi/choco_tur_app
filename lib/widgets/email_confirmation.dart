import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmailConfirmation extends StatelessWidget {
  const EmailConfirmation({super.key, required this.email});

  final String email;

  void _checkCodeCompletion(String text, BuildContext context) async {
    LoggerInstance.logger.d(text);
    if (text.length == 6) {
      bool confirmSuccess = await WebappService.confirmEmail(context, email, text);

      if (confirmSuccess) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    }
  }

  void _resendCode() {
    // TODO: Implement
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.confirmEmailCode),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
            ),
            maxLength: 6,
            keyboardType: TextInputType.number,
            onChanged: (text) => _checkCodeCompletion(text, context),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextButton(
              onPressed: _resendCode,
              child: Text(
                AppLocalizations.of(context)!.resendEmailCode,
                style: TextStyle(color: Styles.redShade),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
