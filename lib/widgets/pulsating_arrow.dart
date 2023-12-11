import 'package:flutter/material.dart';

class PulsatingArrow extends StatefulWidget {
  const PulsatingArrow({super.key});

  @override
  State<PulsatingArrow> createState() => _PulsatingArrowState();
}

class _PulsatingArrowState extends State<PulsatingArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: Axis.horizontal,
      axisAlignment: 0.5,
      sizeFactor: _animationController,
      child: const Icon(Icons.arrow_forward_outlined),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
