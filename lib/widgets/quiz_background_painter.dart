import 'dart:math' as math;

import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';

class QuizBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pinkPaint = Paint()
      ..color = Styles.pinkShade
      ..style = PaintingStyle.fill;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    double pinkOffsetRectangle = size.height / 5;
    double pinkOffsetArch = size.height / 3;
    canvas.drawRect(Rect.fromPoints(Offset.zero, Offset(size.width, pinkOffsetRectangle)), pinkPaint);
    canvas.drawRect(Rect.fromPoints(Offset(0, pinkOffsetRectangle), Offset(size.width, size.height)), whitePaint);
    canvas.drawArc(
        Rect.fromPoints(Offset(0, pinkOffsetRectangle - (pinkOffsetArch - pinkOffsetRectangle) / 2),
            Offset(size.width, pinkOffsetArch - (pinkOffsetArch - pinkOffsetRectangle) / 2)),
        0.0,
        math.pi,
        false,
        pinkPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
