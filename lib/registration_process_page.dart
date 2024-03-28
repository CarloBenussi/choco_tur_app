import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/utils/validation.dart';
import 'package:choco_tur/widgets/email_confirmation.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/user_text_input.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dob_input_field/dob_input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RegistrationProcessPage extends StatefulWidget {
  const RegistrationProcessPage({super.key});

  @override
  State<RegistrationProcessPage> createState() => _RegistrationProcessPageState();
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
  DateTime? _collectedBirthday;
  String? _collectedNationality;

  String? _validateMatchingPassword(BuildContext context, String? matchingPassword) {
    if (matchingPassword != _collectedPassword) {
      return AppLocalizations.of(context)!.invalidMatchingPassword;
    }

    return null;
  }

  void _onCountrySelected(BuildContext context, Country country) {
    _collectedNationality = country.name;
    setState(() {});
  }

  Future<bool> _register(BuildContext context) async {
    setState(() {
      _registering = true;
    });
    bool registrationSuccess = await WebappService.registerUser(
      context,
      _collectedEmail,
      _collectedPassword,
      _collectedMatchingPassword,
      (_collectedBirthday != null) ? _collectedBirthday!.toIso8601String() : null,
      _collectedNationality,
    );
    setState(() {
      _registering = false;
    });

    return registrationSuccess;
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

    if (_currentPageIndex < 4) {
      _backPressed = false;
    } else if (_currentPageIndex == 4) {
      bool registrationSuccess = await _register(context);
      if (!registrationSuccess) {
        return;
      }
    }

    setState(() {
      _currentPageIndex++;
      _controller.clear();
    });
  }

  void _onBackPressed(BuildContext context) {
    _currentPageIndex--;
    _backPressed = true;
    setState(() {
      _controller.clear();
    });
  }

  void _onSkipPressed(BuildContext context) {
    _currentPageIndex++;
    _backPressed = false;
    setState(() {});
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
                        child: Builder(builder: (context) {
                          if (_currentPageIndex == 0) {
                            return UserTextInput(
                              controller: _controller,
                              hintText: AppLocalizations.of(context)!.email,
                              validator: (input) => Validation.validateEmail(context, input),
                            );
                          } else if (_currentPageIndex == 1) {
                            return UserTextInput(
                              controller: _controller,
                              hintText: AppLocalizations.of(context)!.password,
                              validator: (input) => Validation.validatePassword(context, input),
                              obscured: true,
                            );
                          } else if (_currentPageIndex == 2) {
                            return UserTextInput(
                              controller: _controller,
                              hintText: AppLocalizations.of(context)!.matchingPassword,
                              validator: (input) => _validateMatchingPassword(context, input),
                              obscured: true,
                            );
                          } else if (_currentPageIndex == 3) {
                            return Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.pleaseInsertBirthday,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                DOBInputField(
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  showLabel: true,
                                  dateFormatType: DateFormatType.DDMMYYYY,
                                  autovalidateMode: AutovalidateMode.always,
                                  errorFormatText: "",
                                  onDateSubmitted: (date) => {_collectedBirthday = date},
                                ),
                              ],
                            );
                          } else if (_currentPageIndex == 4) {
                            return UserTextInput(
                              controller: _controller,
                              hintText: (_collectedNationality != null)
                                  ? _collectedNationality!
                                  : AppLocalizations.of(context)!.selectNationalityLabel,
                              onTap: (context) => showCountryPicker(
                                context: context,
                                showPhoneCode: true, // optional. Shows phone code before the country name.
                                onSelect: (country) => _onCountrySelected(context, country),
                              ),
                            );
                          } else {
                            return EmailConfirmation(email: _collectedEmail);
                          }
                        }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: _currentPageIndex > 0 ? () => _onBackPressed(context) : null,
                            child: Text(
                              AppLocalizations.of(context)!.backButton,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: (_currentPageIndex > 0) ? Styles.redShade : null,
                              ),
                            ),
                          ),
                          if (_currentPageIndex == 3)
                            TextButton(
                              onPressed: () => _onSkipPressed(context),
                              child: Text(
                                AppLocalizations.of(context)!.skipButton,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: (_currentPageIndex > 0) ? Styles.redShade : null,
                                ),
                              ),
                            ),
                          if (_currentPageIndex < 5)
                            TextButton(
                              onPressed: () => _onNextPressed(context),
                              child: Text(
                                (_currentPageIndex < 4)
                                    ? AppLocalizations.of(context)!.nextButton
                                    : AppLocalizations.of(context)!.registerButton,
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
