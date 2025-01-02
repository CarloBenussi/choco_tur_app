import 'package:choco_tur/utils/global_keys.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:choco_tur/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ChocoTurNavigationBar extends StatelessWidget {
  const ChocoTurNavigationBar({super.key, this.selectedIndex = 0});

  static final Map<int, String> indexToRouteNames = {
    0: RouteNames.home,
    1: RouteNames.map,
    2: RouteNames.myChocoTur,
  };
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    // Reassign global keys on every rebuild: they need to be unique.
    GlobalKeys.globalKeysMap[GlobalKeys.NAVIGATOR_HOME_BUTTON_KEY] = GlobalKey();
    GlobalKeys.globalKeysMap[GlobalKeys.NAVIGATOR_MAP_BUTTON_KEY] = GlobalKey();
    GlobalKeys.globalKeysMap[GlobalKeys.NAVIGATOR_MYCHOCOTUR_BUTTON_KEY] = GlobalKey();
    return NavigationBarTheme(
      data: const NavigationBarThemeData(
        labelTextStyle: MaterialStatePropertyAll(TextStyle(color: Styles.onRedShade)),
      ),
      child: NavigationBar(
          backgroundColor: Styles.redShade,
          indicatorColor: Styles.onRedShade,
          destinations: <Widget>[
            NavigationDestination(
              key: GlobalKeys.globalKeysMap[GlobalKeys.NAVIGATOR_HOME_BUTTON_KEY],
              selectedIcon: Icon(
                Icons.home_rounded,
                color: Styles.redShade,
              ),
              icon: const Icon(
                Icons.home_outlined,
                color: Styles.onRedShade,
              ),
              label: AppLocalizations.of(context)!.homeButton,
            ),
            NavigationDestination(
              key: GlobalKeys.globalKeysMap[GlobalKeys.NAVIGATOR_MAP_BUTTON_KEY],
              selectedIcon: Icon(
                Icons.map_rounded,
                color: Styles.redShade,
              ),
              icon: const Icon(
                Icons.map_outlined,
                color: Styles.onRedShade,
              ),
              label: AppLocalizations.of(context)!.mapButton,
            ),
            NavigationDestination(
              key: GlobalKeys.globalKeysMap[GlobalKeys.NAVIGATOR_MYCHOCOTUR_BUTTON_KEY],
              selectedIcon: Icon(
                Icons.person_2_rounded,
                color: Styles.redShade,
              ),
              icon: const Icon(
                Icons.person_2_outlined,
                color: Styles.onRedShade,
              ),
              label: AppLocalizations.of(context)!.myChocoTurButton,
            ),
          ],
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            String? routeName = indexToRouteNames[index];
            if (routeName != null) Navigator.pushNamed(context, routeName);
          }),
    );
  }
}
