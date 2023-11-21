import 'package:choco_tur/language_selection_page.dart';
import 'package:choco_tur/main_page.dart';
import 'package:choco_tur/map_page.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/tour_description_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // var chocoUser = await ChocoTurUser.init();
  FlutterNativeSplash.remove();

  runApp(ChangeNotifierProvider(
    create: (BuildContext context) => ChocoTurUser(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Choco Tur App',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
          useMaterial3: true,
        ),
        home: const LanguageSelection(),
        locale: Provider.of<ChocoTurUser>(context).locale,
        routes: {
          '/login': (context) => const LoginPage(),
          '/tour_description': (context) => TourDescriptionPage(),
          '/main': (context) => MainPage(),
          '/map': (context) => const MapPage(),
        });
  }
}
