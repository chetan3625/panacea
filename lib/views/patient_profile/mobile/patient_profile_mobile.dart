import 'package:flutter/material.dart';
import 'package:panacea/views/patient_profile/shared/patient_profile_content.dart';

/// Mobile entry point for PatientProfilePage.
class PatientProfilePageMobile extends StatelessWidget {
  final String patientName;
  final String mobileNumber;
  final Map<String, dynamic> patient;

  const PatientProfilePageMobile({
    super.key,
    required this.patientName,
    required this.mobileNumber,
    this.patient = const {},
  });

  @override
  Widget build(BuildContext context) => PatientProfilePageContent(
    patientName: patientName,
    mobileNumber: mobileNumber,
    patient: patient,
  );
}
