import 'package:flutter/material.dart';
import 'desktop/patient_profile_desktop.dart';
import 'mobile/patient_profile_mobile.dart';

/// Chooses the page entry point from the available viewport width.
class PatientProfilePage extends StatelessWidget {
  final String patientName;
  final String mobileNumber;
  final Map<String, dynamic> patient;

  const PatientProfilePage({
    super.key,
    required this.patientName,
    required this.mobileNumber,
    this.patient = const {},
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 900
        ? PatientProfilePageDesktop(
            patientName: patientName,
            mobileNumber: mobileNumber,
            patient: patient,
          )
        : PatientProfilePageMobile(
            patientName: patientName,
            mobileNumber: mobileNumber,
            patient: patient,
          ),
  );
}
