import 'package:choco_tur/account_page.dart';
import 'package:choco_tur/language_selection_page.dart';
import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user_answers.dart';
import 'package:choco_tur/models/choco_tur_user_wallet.dart';
import 'package:choco_tur/my_chocotur_page.dart';
import 'package:choco_tur/password_recovery_process_page.dart';
import 'package:choco_tur/quiz_page.dart';
import 'package:choco_tur/registration_process_page.dart';
import 'package:choco_tur/services/firebase_service.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/settings_page.dart';
import 'package:choco_tur/tour_start_page.dart';
import 'package:choco_tur/tour_stop_story_chat_loading_page.dart';
import 'package:choco_tur/tours_home_page.dart';
import 'package:choco_tur/map_page.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/tour_info_page.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/timer.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Future<void> splashTimer = startTimer(2);
  await SqliteCache.init();
  await WebappService.init();
  await FirebaseService.init();
  var chocoUser = await ChocoTurUser.init();
  var chocoUserAnswers = await ChocoTurUserAnswers.init(chocoUser);
  var chocoUserWallet = await ChocoTurUserWallet.init(chocoUser);
  await splashTimer;
  FlutterNativeSplash.remove();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => chocoUser,
      ),
      ChangeNotifierProvider(
        create: (_) => chocoUserAnswers,
      ),
      ChangeNotifierProvider(
        create: (_) => chocoUserWallet,
      ),
    ],
    child: ChocoTurApp(user: chocoUser),
  ));
}

class ChocoTurApp extends StatelessWidget {
  const ChocoTurApp({super.key, required this.user});

  final ChocoTurUser user;

  static final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.red);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.red, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Choco Tur App',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          useMaterial3: true,
        ),
        home: (user.language == null) ? const LanguageSelection() : const ToursHomePage(),
        locale: Provider.of<ChocoTurUser>(context).locale,
        routes: {
          RouteNames.languageSelection: (context) => const LanguageSelection(),
          RouteNames.login: (context) => const LoginPage(),
          RouteNames.tourInfo: (context) => TourInfoPage(),
          RouteNames.home: (context) => const ToursHomePage(),
          RouteNames.map: (context) => MapPage(),
          RouteNames.myChocoTur: (context) => MyChocoTurPage(
                initialIndex: ModalRoute.of(context)!.settings.arguments as int?,
              ),
          RouteNames.tourPlay: (context) => TourStartPage(
                tour: ModalRoute.of(context)!.settings.arguments as ChocoTurTour,
              ),
          RouteNames.tourStopStoryChat: (context) => TourStopStoryChatLoadingPage(
                stop: ModalRoute.of(context)!.settings.arguments as ChocoTurStop,
              ),
          RouteNames.settings: (context) => const SettingsPage(),
          RouteNames.registrationProcess: (context) => const RegistrationProcessPage(),
          RouteNames.passwordRecoveryProcess: (context) => const PasswordRecoveryProcessPage(),
          RouteNames.account: (context) => const AccountPage(),
          RouteNames.quiz: (context) => QuizPage(
                quiz: ModalRoute.of(context)!.settings.arguments as ChocoTurQuiz,
              ),
        },
      );
    });
  }
}
