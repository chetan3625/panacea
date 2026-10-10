import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.4, 1.0],
          colors: [Color(0xFFEAF2FF), Color(0xFFF8F9FE), Color(0xFFD3E4FF)],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
