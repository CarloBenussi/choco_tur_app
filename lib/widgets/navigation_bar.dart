import 'package:flutter/material.dart';

class ChocoTurNavigationBar extends StatelessWidget {
  const ChocoTurNavigationBar({super.key, this.selectedIndex = 0});

  static final Map<int, String> indexToRouteNames = {0: "/main", 1: "/map"};
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home_rounded),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.map_rounded),
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.tour_rounded),
            icon: Icon(Icons.tour_outlined),
            label: 'MyTours',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle_rounded),
            icon: Icon(Icons.account_circle_outlined),
            label: 'Account',
          ),
        ],
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) {
          String? routeName = indexToRouteNames[index];
          if (routeName != null) Navigator.pushNamed(context, routeName);
        });
  }
}
