import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_routes.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();

    if (mobile.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter mobile number and password',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await ApiService.post('/auth/login', {
        'mobile': mobile,
        'password': password,
      }).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final otp = _generateOtp();
        Get.snackbar(
          'OTP Generated',
          'Your OTP is: $otp',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 8),
        );
        Get.toNamed(
          AppRoutes.otp,
          arguments: {'mobile': mobile, 'otp': otp, 'token': data['token']},
        );
      } else {
        Get.snackbar(
          'Login Failed',
          data['message'] ?? 'Something went wrong',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Connection Error',
        'Could not reach ${ApiService.baseUrl}. Check that the backend is running. $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _generateOtp() {
    final random = Random();
    final otp = List.generate(4, (_) => random.nextInt(10)).join();
    return otp;
  }

  @override
  void onClose() {
    mobileController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
