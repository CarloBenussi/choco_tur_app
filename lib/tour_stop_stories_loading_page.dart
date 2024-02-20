import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/tour_stop_stories_page.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TourStopStoriesLoadingPage extends StatelessWidget {
  TourStopStoriesLoadingPage({super.key, required this.stopId});

  final int stopId;
  Future<List<ChocoTurStopStory>>? stopStories;

  Future<List<ChocoTurStopStory>> _getOrReturnStopStories() async {
    if (stopStories == null) {
      // TODO: Get from cache or webapp the stop stories.
    }

    return stopStories!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const ChocoTurAppBar(),
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: _getOrReturnStopStories(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              return TourStopStoriesPage(
                tourStopStories: snapshot.data!,
              );
            } else {
              return const Center(child: LoadingAnimation());
            }
          },
        ),
        bottomNavigationBar: const ChocoTurNavigationBar(),
      ),
    );
  }
}
