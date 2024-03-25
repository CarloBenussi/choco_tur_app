import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  DashedLine({super.key, required double length, required this.direction}) {
    width = (direction == Axis.vertical) ? thickness : length / (2 * dashCount);
    height = (direction == Axis.vertical) ? length / (2 * dashCount) : thickness;
  }

  static const double thickness = 3.0;
  static const int dashCount = 3;
  late final double width;
  late final double height;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: direction,
      alignment: WrapAlignment.spaceBetween,
      children: [
        for (var i = 0; i < dashCount; ++i) ...[
          SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Styles.redShade),
            ),
          ),
          if (i < dashCount - 1)
            SizedBox(
              width: width,
              height: height / 2,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.white),
              ),
            ),
        ],
      ],
    );
  }
}
