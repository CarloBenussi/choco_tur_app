import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/tour_stop_story_pages_page.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TourStopStoryPagesLoadingPage extends StatelessWidget {
  TourStopStoryPagesLoadingPage({super.key, required this.stopId});

  final int stopId;
  Future<List<ChocoTurStopPage>>? stopPages;

  Future<List<ChocoTurStopPage>> _getOrReturnStopStoryPages() async {
    if (stopPages == null) {
      SqliteCache cache = await SqliteCache.getInstance();
      stopPages = cache.getStopStoryPages(stopId);
    }

    return stopPages!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const ChocoTurAppBar(),
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: _getOrReturnStopStoryPages(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              return TourStopStoryPagesPage(
                tourStopStoryPages: snapshot.data!,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        bottomNavigationBar: const ChocoTurNavigationBar(),
      ),
    );
  }
}
