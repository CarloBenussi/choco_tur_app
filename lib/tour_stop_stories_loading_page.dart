import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/tour_stop_stories_page.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TourStopStoriesLoadingPage extends StatelessWidget {
  TourStopStoriesLoadingPage({super.key, required this.stopId});

  final String stopId;
  List<ChocoTurStopStory>? stopStories;

  Future<List<ChocoTurStopStory>> _getOrReturnStopStories(BuildContext context) async {
    stopStories ??= await WebappService.getTourStopStories(
        context, stopId, Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken);

    return stopStories!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const ChocoTurAppBar(),
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: _getOrReturnStopStories(context),
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
