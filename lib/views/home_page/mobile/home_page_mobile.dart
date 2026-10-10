import 'package:flutter/material.dart';
import 'package:panacea/views/home_page/shared/home_page_content.dart';

/// Mobile entry point for HomePage.
/// The shared page retains its existing responsive behavior and state handling.
class HomePageMobile extends StatelessWidget {
  const HomePageMobile({super.key});

  @override
  Widget build(BuildContext context) => const HomePageContent();
}
