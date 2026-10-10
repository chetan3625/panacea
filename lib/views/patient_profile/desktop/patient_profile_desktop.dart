import 'package:flutter/material.dart';
import 'package:panacea/views/patient_profile/shared/patient_profile_content.dart';

/// Desktop entry point for PatientProfilePage.
/// The shared page retains its existing responsive behavior and state handling.
class PatientProfilePageDesktop extends StatelessWidget {
  final String patientName;
  final String mobileNumber;

  const PatientProfilePageDesktop({
    super.key,
    required this.patientName,
    required this.mobileNumber,
  });

  @override
  Widget build(BuildContext context) => PatientProfilePageContent(
    patientName: patientName,
    mobileNumber: mobileNumber,
  );
}
