import 'package:flutter/material.dart';
import 'package:panacea/views/case_papers_page/shared/case_papers_page_content.dart';

/// Mobile entry point for CasePapersPage.
/// The shared page retains its existing responsive behavior and state handling.
class CasePapersPageMobile extends StatelessWidget {
  const CasePapersPageMobile({super.key});

  @override
  Widget build(BuildContext context) => const CasePapersPageContent();
}
