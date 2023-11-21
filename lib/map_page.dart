import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: ChocoTurAppBar(),
      drawer: ChocoTurDrawer(),
      body: SizedBox(
        // TODO: Add map widget.
        width: 200,
        height: 200,
      ),
      bottomNavigationBar: ChocoTurNavigationBar(
        selectedIndex: 1,
      ),
    );
  }
}
