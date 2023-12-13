import 'package:choco_tur/utils/route_names.dart';
import 'package:flutter/material.dart';

class ChocoTurNavigationBar extends StatelessWidget {
  const ChocoTurNavigationBar({super.key, this.selectedIndex = 0});

  static final Map<int, String> indexToRouteNames = {
    0: RouteNames.home,
    1: RouteNames.map,
    2: RouteNames.myTours,
  };
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
        ],
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) {
          String? routeName = indexToRouteNames[index];
          if (routeName != null) Navigator.pushNamed(context, routeName);
        });
  }
}
