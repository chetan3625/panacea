import 'package:flutter/material.dart';
import 'desktop/case_paper_form_page_desktop.dart';
import 'mobile/case_paper_form_page_mobile.dart';

/// Chooses the page entry point from the available viewport width.
class CasePaperFormPage extends StatelessWidget {
  const CasePaperFormPage({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 1100
        ? const CasePaperFormPageDesktop()
        : const CasePaperFormPageMobile(),
  );
}
