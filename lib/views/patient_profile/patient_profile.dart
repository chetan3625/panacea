import 'package:flutter/material.dart';
import 'desktop/patient_profile_desktop.dart';
import 'mobile/patient_profile_mobile.dart';

/// Chooses the page entry point from the available viewport width.
class PatientProfilePage extends StatelessWidget {
  final String patientName;
  final String mobileNumber;

  const PatientProfilePage({
    super.key,
    required this.patientName,
    required this.mobileNumber,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 1100
        ? PatientProfilePageDesktop(
            patientName: patientName,
            mobileNumber: mobileNumber,
          )
        : PatientProfilePageMobile(
            patientName: patientName,
            mobileNumber: mobileNumber,
          ),
  );
}
