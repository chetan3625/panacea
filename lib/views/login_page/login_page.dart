import 'package:flutter/material.dart';
import 'desktop/login_page_desktop.dart';
import 'mobile/login_page_mobile.dart';

/// Chooses the page entry point from the available viewport width.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 1100
        ? const LoginPageDesktop()
        : const LoginPageMobile(),
  );
}
