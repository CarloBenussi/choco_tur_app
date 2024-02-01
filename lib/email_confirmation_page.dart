import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmailConfirmationPage extends StatefulWidget {
  const EmailConfirmationPage({super.key, required this.email});

  final String email;

  @override
  State<EmailConfirmationPage> createState() => _EmailConfirmationPageState();
}

class _EmailConfirmationPageState extends State<EmailConfirmationPage> {
  final codeController = TextEditingController();
  bool _waitingForWebResponse = false;

  void _checkCodeCompletion(BuildContext context) async {
    if (codeController.text.length == 6) {
      setState(() {
        _waitingForWebResponse = true;
      });
      bool confirmSuccess =
          await WebappService.confirmEmail(widget.email, codeController.text);
      setState(() {
        _waitingForWebResponse = false;
      });

      if (confirmSuccess) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      } else {
        // TODO: Show alert dialog (wrong code).
      }
    }
  }

  void _resendCode() {
    // TODO: Implement
  }

  @override
  void initState() {
    super.initState();

    codeController.addListener(() => _checkCodeCompletion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.confirmEmailCode),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextButton(
                    onPressed: _resendCode,
                    child: Text(
                      AppLocalizations.of(context)!.resendEmailCode,
                    ),
                  ),
                ),
              ],
            ),
            if (_waitingForWebResponse)
              const Opacity(
                opacity: 0.5,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }
}
