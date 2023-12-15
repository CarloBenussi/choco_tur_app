import 'package:choco_tur/utils/styles.dart';
import 'package:flutter/material.dart';

class GenericAlertDialog extends StatelessWidget {
  const GenericAlertDialog({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Styles.redShade,
      icon: const Icon(Icons.warning_rounded),
      iconColor: Styles.onRedShade,
      title: Text(
        title,
        style: const TextStyle(color: Styles.onRedShade),
      ),
      content: Text(content, style: const TextStyle(color: Styles.onRedShade)),
      elevation: 24.0,
    );
  }
}
