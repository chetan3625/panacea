import 'package:flutter/material.dart';
import 'package:panacea/views/case_paper_form_page/shared/case_paper_form_page_content.dart';

/// Desktop entry point for CasePaperFormPage.
/// The shared page retains its existing responsive behavior and state handling.
class CasePaperFormPageDesktop extends StatelessWidget {
  const CasePaperFormPageDesktop({super.key});

  @override
  Widget build(BuildContext context) => const CasePaperFormPageContent();
}
