import 'package:flutter/material.dart';
import 'desktop/case_papers_page_desktop.dart';
import 'mobile/case_papers_page_mobile.dart';

/// Chooses the page entry point from the available viewport width.
class CasePapersPage extends StatelessWidget {
  const CasePapersPage({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 1100
        ? const CasePapersPageDesktop()
        : const CasePapersPageMobile(),
  );
}
