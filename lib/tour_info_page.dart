import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:choco_tur/widgets/purchase_tour_button.dart';
import 'package:choco_tur/widgets/start_tour_button.dart';
import 'package:choco_tur/widgets/tour_stop_infos.dart';
import 'package:choco_tur/widgets/tour_tasting_infos.dart';
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
  String? _langCode;

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
    _active = (tour.id == Provider.of<ChocoTurUser>(context, listen: true).activeTour?.id);
    _langCode = Provider.of<ChocoTurUser>(context, listen: true).language;
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
            Text(
              tour.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Hero(
                tag: tour.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(tour.imageData!),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  tour.descriptions[_langCode]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.black54,
                  ),
                )),
            Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  AppLocalizations.of(context)!.tourInfosTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.euro_outlined),
              title: Text("${AppLocalizations.of(context)!.cost} ${tour.costEuros} €"),
              subtitle: Text(AppLocalizations.of(context)!.costExplanation),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.timer_outlined),
              title: Text(
                  "${AppLocalizations.of(context)!.duration} ${printDuration(tour.avgDuration, abbreviated: true)}"),
              subtitle: Text(AppLocalizations.of(context)!.durationExplanation),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.directions_walk_outlined),
              title: Text("${AppLocalizations.of(context)!.tourLength} ${tour.lengthKm}km"),
              subtitle: Text(AppLocalizations.of(context)!.tourLengthDescription),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.tour_outlined),
              title: Text("${AppLocalizations.of(context)!.stops}: ${tour.stopInfos.length}"),
              subtitle: Text(AppLocalizations.of(context)!.stopsDescription),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.restaurant_outlined),
              title: Text("${AppLocalizations.of(context)!.tastings}: ${tour.tastingInfos.length}"),
              subtitle: Text(AppLocalizations.of(context)!.tastingDescriptions),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                AppLocalizations.of(context)!.tourStopsTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TourStopInfos(
                langCode: _langCode!,
                tourStopInfos: tour.stopInfos,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                AppLocalizations.of(context)!.tourTastingsTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TourTastingInfos(
                langCode: _langCode!,
                tourTastingInfos: tour.tastingInfos,
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
                    tour: tour,
                  ),
                  if (!tour.isFree())
                    PurchaseTourButton(
                      onPressedFunction: onPurchasePressed,
                      purchased: _purchased,
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const ChocoTurNavigationBar(),
      ),
    );
  }
}
