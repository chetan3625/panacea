import 'package:flutter/material.dart';
import 'desktop/patient_form_page_desktop.dart';
import 'mobile/patient_form_page_mobile.dart';

/// Chooses the page entry point from the available viewport width.
class PatientFormPage extends StatelessWidget {
  const PatientFormPage({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 900
        ? const PatientFormPageDesktop()
        : const PatientFormPageMobile(),
  );
}
