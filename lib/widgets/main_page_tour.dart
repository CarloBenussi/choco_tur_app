import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/sizes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainPageTour extends StatelessWidget {
  const MainPageTour({super.key, required this.chocoTurTour});

  final ChocoTurTour chocoTurTour;

  void onTapped(BuildContext context) {
    Navigator.pushNamed(context, '/tour_info', arguments: chocoTurTour);
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
            child: Image.asset(chocoTurTour.imageUrl),
          ),
          Positioned(
            bottom: 5,
            left: 5,
            child: Text(
              chocoTurTour.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.white),
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
                          text: chocoTurTour.costInEuros.toString(),
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
                        text: chocoTurTour.getChocolatesCount().toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const WidgetSpan(
                        child: Image(
                            image: AssetImage('assets/chocolateIcon.png'),
                            width: Sizes.iconWidth,
                            height: Sizes.iconHeight,
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
