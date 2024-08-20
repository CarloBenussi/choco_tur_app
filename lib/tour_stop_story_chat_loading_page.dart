import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/webapp_service.dart';
import 'package:choco_tur/tour_stop_story_chat_page.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/loading_animation.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TourStopStoryChatLoadingPage extends StatelessWidget {
  TourStopStoryChatLoadingPage({super.key, required this.stop});

  final ChocoTurStop stop;
  List<ChocoTurStopStory>? _stopStories;

  Future<List<ChocoTurStopStory>> _getStopStories(BuildContext context) async {
    _stopStories ??= await WebappService.getTourStopStories(
        context, stop.id, Provider.of<ChocoTurUser>(context, listen: false).loginAccessToken);

    return _stopStories!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _getStopStories(context),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
            return TourStopStoryChatPage(
              stopStories: snapshot.data!,
              audioId: stop.audioId,
              tastingId: stop.tastingId,
            );
          } else {
            return const Center(
              child: LoadingAnimation(),
            );
          }
        },
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(),
    );
  }
}
