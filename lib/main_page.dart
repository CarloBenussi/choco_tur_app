import 'package:choco_tur/models/tour_description_model.dart';
import 'package:choco_tur/utils/hero_tags.dart';
import 'package:choco_tur/utils/placeholder.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/main_page_tour.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final List<MainPageTour> _tours = [
    MainPageTour(
        tourDescription: TourDescriptionModel(
            imageUrl: 'assets/piazzaSanCarlo.jpg',
            text: ChocoTurPlaceholder.loremIpsum,
            title: "Choco Tour 1",
            heroTag: HeroTags.tourOneTag)),
    MainPageTour(
        tourDescription: TourDescriptionModel(
            imageUrl: 'assets/caffeSanCarlo.jpg',
            text: ChocoTurPlaceholder.loremIpsum,
            title: "Choco Tour 2",
            heroTag: HeroTags.tourTwoTag)),
    MainPageTour(
        tourDescription: TourDescriptionModel(
            imageUrl: 'assets/piazzaSanCarlo.jpg',
            text: ChocoTurPlaceholder.loremIpsum,
            title: "Choco Tour 3",
            heroTag: HeroTags.tourThreeTag)),
    MainPageTour(
        tourDescription: TourDescriptionModel(
            imageUrl: 'assets/piazzaSanCarlo.jpg',
            text: ChocoTurPlaceholder.loremIpsum,
            title: "Choco Tour 4",
            heroTag: HeroTags.tourFourTag))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      drawer: const ChocoTurDrawer(),
      body: ListView.separated(
          itemCount: _tours.length,
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 10);
          },
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
          itemBuilder: (BuildContext context, int index) {
            return _tours[index];
          }),
      bottomNavigationBar: const ChocoTurNavigationBar(
        selectedIndex: 0,
      ),
    );
  }
}
