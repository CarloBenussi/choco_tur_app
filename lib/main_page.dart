import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/mock_data.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/main_page_tour.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final List<ChocoTurTour> _tours = MockData.mockTours();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const ChocoTurAppBar(),
      drawer: const ChocoTurDrawer(),
      body: ListView.separated(
          itemCount: _tours.length,
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 10);
          },
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          itemBuilder: (BuildContext context, int index) {
            return MainPageTour(chocoTurTour: _tours[index]);
          }),
      bottomNavigationBar: const ChocoTurNavigationBar(
        selectedIndex: 0,
      ),
    );
  }
}
