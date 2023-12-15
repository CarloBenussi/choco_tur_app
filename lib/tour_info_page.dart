import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/services/sqlite_cache.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:choco_tur/widgets/purchase_tour_button.dart';
import 'package:choco_tur/widgets/start_tour_button.dart';
import 'package:choco_tur/widgets/title_and_description.dart';
import 'package:choco_tur/widgets/tour_stops_info_animation.dart';
import 'package:duration/duration.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TourInfoPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  TourInfoPage({super.key});

  @override
  State<TourInfoPage> createState() => _TourInfoPageState();
}

class _TourInfoPageState extends State<TourInfoPage> {
  late ChocoTurTour tour;

  bool _purchased = false;
  bool _active = false;

  Future<List<ChocoTurTourStop>>? _tourStops;
  List<Chocolate?>? _tourStopTastings;

  Future<List<ChocoTurTourStop>> _getOrReturnTourStops() async {
    if (_tourStops == null) {
      SqliteCache cache = await SqliteCache.getInstance();
      _tourStops = cache.getTourStops(tour.id);

      _tourStopTastings = [];
      var tourStops = await _getOrReturnTourStops();
      for (var i = 0; i < tourStops.length; ++i) {
        _tourStopTastings!.add(await cache.getStopchocolate(tourStops[i].id));
      }
    }

    return _tourStops!;
  }

  void onPurchasePressed() {
    setState(() {
      _purchased = true;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    tour = ModalRoute.of(context)!.settings.arguments as ChocoTurTour;
    _active = (tour.id == Provider.of<ChocoTurUser>(context).activeTourId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const ChocoTurAppBar(),
        backgroundColor: Colors.white,
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          children: [
            Hero(
              tag: tour.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(tour.mainImageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.spaceAround,
                spacing: 10,
                children: [
                  StartTourButton(
                    available: !_active && (_purchased || tour.isFree()),
                    tourId: tour.id,
                  ),
                  if (!tour.isFree())
                    PurchaseTourButton(
                      onPressedFunction: onPurchasePressed,
                      purchased: _purchased,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TitleAndDescription(
                title: tour.name,
                subTitle:
                    "${tour.numStops} ${AppLocalizations.of(context)!.stops} | "
                    "${tour.numTastings} ${AppLocalizations.of(context)!.tastings} | "
                    "${tour.lengthInKms}km | "
                    "${printDuration(tour.avgDuration, abbreviated: true)}",
                description: tour.description,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Divider(
                        color: Colors.black54,
                        thickness: 0.7,
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.tourStopsTitle,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Divider(
                        color: Colors.black54,
                        thickness: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: FutureBuilder(
                future: _getOrReturnTourStops(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return TourStopsInfoAnimation(
                      tourId: tour.id,
                      tourStops: snapshot.data!,
                      tourStopTastings: _tourStopTastings!,
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const ChocoTurNavigationBar(),
      ),
    );
  }
}
