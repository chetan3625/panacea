import 'package:flutter/material.dart';
import 'package:panacea/views/splash_screen/shared/splash_screen_content.dart';

/// Mobile entry point for SplashScreenPage.
/// The shared page retains its existing responsive behavior and state handling.
class SplashScreenPageMobile extends StatelessWidget {
  const SplashScreenPageMobile({super.key});

  @override
  Widget build(BuildContext context) => const SplashScreenPageContent();
}
