// import 'dart:ui';

// import 'package:animations/animations.dart';
// import 'package:choco_tur/services/webapp_service.dart';
// import 'package:choco_tur/utils/route_names.dart';
// import 'package:choco_tur/utils/styles.dart';
// import 'package:choco_tur/utils/validation.dart';
// import 'package:choco_tur/widgets/loading_animation.dart';
// import 'package:choco_tur/widgets/user_text_input.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter/material.dart';

// // ignore: must_be_immutable
// class ForgotPasswordProcessPage extends StatefulWidget {
//   const ForgotPasswordProcessPage({super.key});

//   static const int pagesCount = 6;

//   @override
//   State<ForgotPasswordProcessPage> createState() => _ForgotPasswordProcessPageState();
// }

// class _ForgotPasswordProcessPageState extends State<ForgotPasswordProcessPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _controller = TextEditingController();

//   int _currentPageIndex = 0;
//   bool _backPressed = false;
//   bool _processing = false;

//   late String _collectedEmail;
//   late String _collectedNewPassword;
//   late String _collectedNewMatchingPassword;

//   String? _validateMatchingPassword(BuildContext context, String? matchingPassword) {
//     if (matchingPassword != _collectedNewPassword) {
//       return AppLocalizations.of(context)!.invalidMatchingPassword;
//     }

//     return null;
//   }

//   void _onNextPressed(BuildContext context) async {
//     if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_currentPageIndex == 0) {
//       _collectedEmail = _controller.text;
//     } else if (_currentPageIndex == 1) {
//       _collectedNewPassword = _controller.text;
//     } else if (_currentPageIndex == 2) {
//       _collectedNewMatchingPassword = _controller.text;
//     }

//     if (_currentPageIndex < ForgotPasswordProcessPage.pagesCount - 1) {
//       _currentPageIndex++;
//       _backPressed = false;
//       setState(() {
//         _controller.clear();
//       });
//     } else {
//       setState(() {
//         _processing = true;
//       });
//       bool registrationSuccess = await WebappService.registerUser(
//         context,
//         _collectedEmail,
//         _collectedNewPassword,
//         _collectedNewMatchingPassword,
//       );
//       setState(() {
//         _processing = false;
//       });

//       if (registrationSuccess && mounted) {
//         Navigator.pushReplacementNamed(context, RouteNames.emailConfirmation, arguments: _collectedEmail);
//       } else {
//         // TODO: Show alert dialog.
//       }
//     }
//   }

//   void _onBackPressed(BuildContext context) {
//     _currentPageIndex--;
//     _backPressed = true;
//     setState(() {
//       _controller.clear();
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.only(left: 15, right: 15),
//           child: PageTransitionSwitcher(
//             duration: const Duration(milliseconds: 800),
//             reverse: _backPressed,
//             transitionBuilder: (
//               Widget child,
//               Animation<double> animation,
//               Animation<double> secondaryAnimation,
//             ) {
//               return SharedAxisTransition(
//                 animation: animation,
//                 secondaryAnimation: secondaryAnimation,
//                 transitionType: SharedAxisTransitionType.horizontal,
//                 fillColor: Colors.white,
//                 child: child,
//               );
//             },
//             child: Container(
//               key: ValueKey<int>(_currentPageIndex),
//               child: Stack(
//                 children: [
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Form(
//                         key: _formKey,
//                         child: Builder(builder: (context) {
//                           if (_currentPageIndex == 0) {
//                             return UserTextInput(
//                               controller: _controller,
//                               hintText: AppLocalizations.of(context)!.email,
//                               validator: (input) => Validation.validateEmail(context, input),
//                             );
//                           } else if (_currentPageIndex == 1) {
//                             return UserTextInput(
//                               controller: _controller,
//                               hintText: AppLocalizations.of(context)!.password,
//                               validator: (input) => Validation.validatePassword(context, input),
//                               obscured: true,
//                             );
//                           } else if (_currentPageIndex == 2) {
//                             return UserTextInput(
//                               controller: _controller,
//                               hintText: AppLocalizations.of(context)!.matchingPassword,
//                               validator: (input) => _validateMatchingPassword(context, input),
//                               obscured: true,
//                             );
//                           }
//                         }),
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           TextButton(
//                             onPressed: _currentPageIndex > 0 ? () => _onBackPressed(context) : null,
//                             child: Text(
//                               AppLocalizations.of(context)!.backButton,
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: (_currentPageIndex > 0) ? Styles.redShade : null,
//                               ),
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () => _onNextPressed(context),
//                             child: Text(
//                               (_currentPageIndex < ForgotPasswordProcessPage.pagesCount - 1)
//                                   ? AppLocalizations.of(context)!.nextButton
//                                   : AppLocalizations.of(context)!.registerButton,
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                                 color: Styles.redShade,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   if (_processing)
//                     BackdropFilter(
//                       filter: ImageFilter.blur(
//                         sigmaX: 5,
//                         sigmaY: 5,
//                       ),
//                       child: const Center(
//                         child: LoadingAnimation(),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
