import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/widgets/app_bar.dart';
import 'package:choco_tur/widgets/navigation_bar.dart';
import 'package:choco_tur/widgets/purchaseTourButton.dart';
import 'package:choco_tur/widgets/startTourButton.dart';
import 'package:choco_tur/widgets/title_and_description.dart';
import 'package:choco_tur/widgets/tour_stops_info_animation.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';

class TourInfoPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  TourInfoPage({super.key});

  @override
  State<TourInfoPage> createState() => _TourInfoPageState();
}

class _TourInfoPageState extends State<TourInfoPage> {
  late ChocoTurTour chocoTurTour;

  bool _purchased = false;

  void onPurchasePressed() {
    setState(() {
      _purchased = true;
    });
  }

  @override
  void initState() async {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    chocoTurTour = ModalRoute.of(context)!.settings.arguments as ChocoTurTour;
    return SafeArea(
      child: Scaffold(
        appBar: const ChocoTurAppBar(),
        backgroundColor: Colors.white,
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          children: [
            Hero(
              tag: chocoTurTour.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(chocoTurTour.mainImageUrl),
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
                    available: (_purchased || chocoTurTour.isFree()),
                    chocoTurTour: chocoTurTour,
                  ),
                  if (!chocoTurTour.isFree())
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
                title: chocoTurTour.name,
                subTitle: "${chocoTurTour.numStops} stops | "
                    "${chocoTurTour.numTastings} tastings | "
                    "${chocoTurTour.lengthInKms}km | "
                    "${printDuration(chocoTurTour.avgDuration, abbreviated: true)}",
                description: chocoTurTour.description,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Divider(
                        color: Colors.black54,
                        thickness: 0.7,
                      ),
                    ),
                  ),
                  Text(
                    "Tour stops",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
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
              child: TourStopsInfoAnimation(
                tourId: chocoTurTour.id,
              ),
            ),
          ],
        ),
        bottomNavigationBar: const ChocoTurNavigationBar(),
      ),
    );
  }
}
