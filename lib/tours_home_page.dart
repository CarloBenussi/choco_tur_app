import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/services/SqliteCache.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/drawer.dart';
import 'package:choco_tur/widgets/main_page_tour.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';

class ToursHomePage extends StatefulWidget {
  ToursHomePage({super.key});

  @override
  State<ToursHomePage> createState() => _ToursHomePageState();
}

class _ToursHomePageState extends State<ToursHomePage> {
  late final Future<List<ChocoTurTour>> _tours;

  @override
  void initState() async {
    super.initState();

    SqliteCache cache = await SqliteCache.getInstance();

    _tours = cache.getAllTours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChocoTurAppBar(),
      backgroundColor: Colors.white,
      drawer: const ChocoTurDrawer(),
      body: Stack(
        children: [
          FutureBuilder(
              future: _tours,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(5),
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 5);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return MainPageTour(chocoTurTour: snapshot.data![index]);
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              })
        ],
      ),
      bottomNavigationBar: const ChocoTurNavigationBar(
        selectedIndex: 0,
      ),
    );
  }
}
