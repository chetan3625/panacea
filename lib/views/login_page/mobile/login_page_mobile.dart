import 'package:flutter/material.dart';
import 'package:panacea/views/login_page/shared/login_page_content.dart';

/// Mobile entry point for LoginPage.
/// The shared page retains its existing responsive behavior and state handling.
class LoginPageMobile extends StatelessWidget {
  const LoginPageMobile({super.key});

  @override
  Widget build(BuildContext context) => const LoginPageContent();
}
