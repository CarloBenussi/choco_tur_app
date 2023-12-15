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
      backgroundColor: Colors.red.shade300,
      icon: const Icon(Icons.warning_rounded),
      iconColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      content: Text(content, style: const TextStyle(color: Colors.white)),
      elevation: 24.0,
    );
  }
}
