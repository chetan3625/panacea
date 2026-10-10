import 'package:flutter/material.dart';
import 'package:panacea/views/patient_form_page/shared/patient_form_page_content.dart';

/// Desktop entry point for PatientFormPage.
/// The shared page retains its existing responsive behavior and state handling.
class PatientFormPageDesktop extends StatelessWidget {
  const PatientFormPageDesktop({super.key});

  @override
  Widget build(BuildContext context) => const PatientFormPageContent();
}
