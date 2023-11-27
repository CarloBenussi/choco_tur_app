import 'package:flutter/material.dart';

class ChocoTurStyles {
  static const Color textOnBackgroundColor = Colors.white;

  static const Decoration backgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color.fromRGBO(177, 78, 77, 100), Colors.white],
    ),
  );
}
