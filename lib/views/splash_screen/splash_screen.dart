import 'package:flutter/material.dart';
import 'desktop/splash_screen_desktop.dart';
import 'mobile/splash_screen_mobile.dart';

/// Chooses the page entry point from the available viewport width.
class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 1100
        ? const SplashScreenPageDesktop()
        : const SplashScreenPageMobile(),
  );
}
