import 'package:flutter/material.dart';
import 'package:panacea/views/login_page/shared/login_page_content.dart';

/// Desktop entry point for LoginPage.
/// The shared page retains its existing responsive behavior and state handling.
class LoginPageDesktop extends StatelessWidget {
  const LoginPageDesktop({super.key});

  @override
  Widget build(BuildContext context) => const LoginPageContent();
}
