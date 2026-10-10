import 'package:flutter/material.dart';
import 'desktop/otp_screen_desktop.dart';
import 'mobile/otp_screen_mobile.dart';

/// Chooses the page entry point from the available viewport width.
class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 1100
        ? const OtpPageDesktop()
        : const OtpPageMobile(),
  );
}
