import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/utils/validation.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/user_text_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RegistrationProcessPage extends StatefulWidget {
  const RegistrationProcessPage({super.key});

  static const int pagesCount = 3;

  @override
  State<RegistrationProcessPage> createState() =>
      _RegistrationProcessPageState();
}

class _RegistrationProcessPageState extends State<RegistrationProcessPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  int _currentPageIndex = 0;
  bool _backPressed = false;
  bool _registering = false;

  late String _collectedEmail;
  late String _collectedPassword;
  late String _collectedMatchingPassword;

  String? _validateMatchingPassword(
      BuildContext context, String? matchingPassword) {
    if (matchingPassword != _collectedPassword) {
      return AppLocalizations.of(context)!.invalidMatchingPassword;
    }

    return null;
  }

  void _onNextPressed(BuildContext context) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    if (_currentPageIndex == 0) {
      _collectedEmail = _controller.text;
    } else if (_currentPageIndex == 1) {
      _collectedPassword = _controller.text;
    } else if (_currentPageIndex == 2) {
      _collectedMatchingPassword = _controller.text;
    }

    if (_currentPageIndex < RegistrationProcessPage.pagesCount - 1) {
      _currentPageIndex++;
      _backPressed = false;
      setState(() {
        _controller.clear();
      });
    } else {
      setState(() {
        _registering = true;
      });
      bool registrationSuccess = await WebappService.registerUser(
          _collectedEmail, _collectedPassword, _collectedMatchingPassword);
      setState(() {
        _registering = false;
      });

      if (registrationSuccess) {
        Navigator.pushReplacementNamed(context, RouteNames.emailConfirmation,
            arguments: _collectedEmail);
      } else {
        // TODO: Show alert dialog.
      }
    }
  }

  void _onBackPressed(BuildContext context) {
    _currentPageIndex--;
    _backPressed = true;
    setState(() {
      _controller.clear();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 800),
            reverse: _backPressed,
            transitionBuilder: (
              Widget child,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                fillColor: Colors.white,
                child: child,
              );
            },
            child: Container(
              key: ValueKey<int>(_currentPageIndex),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            UserTextInput(
                              controller: _controller,
                              hintText: (_currentPageIndex == 0)
                                  ? AppLocalizations.of(context)!.email
                                  : (_currentPageIndex == 1)
                                      ? AppLocalizations.of(context)!.password
                                      : AppLocalizations.of(context)!
                                          .matchingPassword,
                              validator: (input) => (_currentPageIndex == 0)
                                  ? Validation.validateEmail(context, input)
                                  : (_currentPageIndex == 1)
                                      ? Validation.validatePassword(
                                          context, input)
                                      : _validateMatchingPassword(
                                          context, input),
                              obscured: (_currentPageIndex == 1) ||
                                  (_currentPageIndex == 2),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: _currentPageIndex > 0
                                ? () => _onBackPressed(context)
                                : null,
                            child: Text(
                              AppLocalizations.of(context)!.backButton,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: (_currentPageIndex > 0)
                                    ? Styles.redShade
                                    : null,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _onNextPressed(context),
                            child: Text(
                              (_currentPageIndex <
                                      RegistrationProcessPage.pagesCount - 1)
                                  ? AppLocalizations.of(context)!.nextButton
                                  : AppLocalizations.of(context)!
                                      .registerButton,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Styles.redShade,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_registering)
                    BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ),
                      child: const Center(
                        child: LoadingAnimation(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
