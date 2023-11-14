import 'package:flutter/material.dart';

class ChocoTurNavigationBar extends StatelessWidget {
  const ChocoTurNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.map_rounded),
          icon: Icon(Icons.map_outlined),
          label: 'Map',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.tour_rounded),
          icon: Icon(Icons.tour_outlined),
          label: 'MyTour',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.account_circle_rounded),
          icon: Icon(Icons.account_circle_outlined),
          label: 'Account',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.settings_rounded),
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}
