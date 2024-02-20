import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/route_names.dart';
import 'package:flutter/material.dart';

class HomePageTour extends StatelessWidget {
  const HomePageTour({super.key, required this.chocoTurTour});

  final ChocoTurTour chocoTurTour;

  void onTapped(BuildContext context) {
    Navigator.pushNamed(context, RouteNames.tourInfo, arguments: chocoTurTour);
  }

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 500,
      child: GestureDetector(
        onTap: () => onTapped(context),
        child: Stack(children: [
          Hero(
            tag: chocoTurTour.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(chocoTurTour.imageData!),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 5,
            child: Text(
              chocoTurTour.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: chocoTurTour.costEuros.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const WidgetSpan(
                          child: Icon(
                            Icons.euro,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: chocoTurTour.tastingInfos.length.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const WidgetSpan(
                        child: Image(
                            image: AssetImage('assets/chocolateIcon.png'),
                            width: 14,
                            height: 14,
                            fit: BoxFit.scaleDown,
                            alignment: FractionalOffset.center),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
