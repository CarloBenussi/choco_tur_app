import 'package:choco_tur/language_selection_page.dart';
import 'package:choco_tur/models/choco_tur_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await ChocoTurModel.init();
  FlutterNativeSplash.remove();

  runApp(ChangeNotifierProvider(
    create: (BuildContext context) => ChocoTurModel(),
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
        locale: Provider.of<ChocoTurModel>(context).locale,
        routes: {'/login': (context) => const LoginPage()});
  }
}
