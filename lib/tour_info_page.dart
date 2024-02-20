import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/models/choco_tur_user.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:choco_tur/widgets/purchase_tour_button.dart';
import 'package:choco_tur/widgets/start_tour_button.dart';
import 'package:choco_tur/widgets/title_and_description.dart';
import 'package:choco_tur/widgets/tour_stop_infos_animation.dart';
import 'package:choco_tur/widgets/tour_tasting_infos_animation.dart';
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
            Hero(
              tag: tour.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(tour.imageData!),
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
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TitleAndDescription(
                title: tour.title,
                subTitle: "${tour.stopInfos.length} ${AppLocalizations.of(context)!.stops} | "
                    "${tour.tastingInfos.length} ${AppLocalizations.of(context)!.tastings} | "
                    "${tour.lengthKm}km | "
                    "${printDuration(tour.avgDuration, abbreviated: true)}",
                description: tour.descriptions[_langCode]!,
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
              child: TourStopInfosAnimation(
                langCode: _langCode!,
                tourId: tour.id,
                tourStopInfos: tour.stopInfos,
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
                    AppLocalizations.of(context)!.tourTastingsTitle,
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
              child: TourTastingInfosAnimation(
                langCode: _langCode!,
                tourId: tour.id,
                tourTastingInfos: tour.tastingInfos,
              ),
            ),
          ],
        ),
        bottomNavigationBar: const ChocoTurNavigationBar(),
      ),
    );
  }
}
