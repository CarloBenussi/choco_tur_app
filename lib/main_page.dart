import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/mock_data.dart';
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
      drawer: const ChocoTurDrawer(),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _tours.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return MainPageTour(chocoTurTour: _tours[index]);
            },
          ),
          const Positioned(
            left: 20,
            top: 20,
            child: DrawerButton(
              style: ButtonStyle(
                iconColor: MaterialStatePropertyAll(Colors.white),
                backgroundColor: MaterialStatePropertyAll(Colors.red),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(
        selectedIndex: 0,
      ),
    );
  }
}
