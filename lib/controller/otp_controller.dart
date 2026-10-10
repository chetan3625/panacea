import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_routes.dart';
import 'auth_session.dart';

class OtpController extends GetxController {
  final Map<String, dynamic> authData = Get.arguments as Map<String, dynamic>;
  final String mobileNumber = Get.arguments['mobile'] as String;
  final String generatedOtp = Get.arguments['otp'] as String;

  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  var isLoading = false.obs;

  Future<void> verifyCode() async {
    if (otpControllers.any((controller) => controller.text.isEmpty)) {
      Get.snackbar(
        'Error',
        'Enter the complete 4-digit code',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final enteredOtp = otpControllers.map((c) => c.text).join();

    if (enteredOtp == generatedOtp) {
      final token = authData['token']?.toString() ?? '';
      if (token.isEmpty) {
        Get.snackbar(
          'Sign-in failed',
          'The server did not provide a session token. Please sign in again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      await Get.find<AuthSession>().signIn(token);
      Get.offAllNamed(AppRoutes.home, arguments: {'token': token});
      return;
    }

    Get.snackbar(
      'Invalid OTP',
      'The entered code does not match the generated OTP: $generatedOtp',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 8),
    );
  }

  @override
  void onClose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
