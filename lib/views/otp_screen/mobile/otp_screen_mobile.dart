import 'package:flutter/material.dart';
import 'package:panacea/views/otp_screen/shared/otp_screen_content.dart';

/// Mobile entry point for OtpPage.
/// The shared page retains its existing responsive behavior and state handling.
class OtpPageMobile extends StatelessWidget {
  const OtpPageMobile({super.key});

  @override
  Widget build(BuildContext context) => const OtpPageContent();
}
