import 'package:flutter/material.dart';
import 'desktop/home_page_desktop.dart';
import 'mobile/home_page_mobile.dart';

/// Chooses the page entry point from the available viewport width.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 1100
        ? const HomePageDesktop()
        : const HomePageMobile(),
  );
}
