import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_routes.dart';
import 'auth_session.dart';
import '../services/api_service.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final recentPatients = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final loadError = ''.obs;
  final searchQuery = ''.obs;
  String? token;

  List<Map<String, dynamic>> get visiblePatients {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return recentPatients.toList();
    return recentPatients.where((patient) {
      final name = patient['name']?.toString().toLowerCase() ?? '';
      final mobile = patient['mobile']?.toString() ?? '';
      return name.contains(query) || mobile.contains(query);
    }).toList();
  }

  int get patientsAddedThisMonth {
    final now = DateTime.now();
    return recentPatients.where((patient) {
      final createdAt = DateTime.tryParse(
        patient['createdAt']?.toString() ?? '',
      );
      return createdAt != null &&
          createdAt.year == now.year &&
          createdAt.month == now.month;
    }).length;
  }

  void updateSearch(String value) => searchQuery.value = value;

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map) token = arguments['token']?.toString();
    token ??= Get.find<AuthSession>().token.value;
    if (token?.isNotEmpty == true) {
      Get.find<AuthSession>().signIn(token!);
    } else {
      Get.find<AuthSession>().signOut();
      return;
    }
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    if (token == null || token!.isEmpty) {
      loadError.value = 'Your session has expired. Please sign in again.';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    loadError.value = '';
    try {
      final response = await ApiService.get('/patients', token: token);
      final data = jsonDecode(response.body);
      if (response.statusCode == 401 || response.statusCode == 403) {
        await Get.find<AuthSession>().signOut();
        return;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(data['message'] ?? 'Could not load patients.');
      }
      recentPatients.assignAll(
        (data['patients'] as List).map(
          (patient) => Map<String, dynamic>.from(patient as Map),
        ),
      );
    } catch (error) {
      loadError.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> navigateToPatientForm() async {
    final saved = await Get.toNamed(
      AppRoutes.patientForm,
      arguments: {'token': token},
    );
    if (saved == true) fetchPatients();
  }

  Future<void> editPatient(Map<String, dynamic> patient) async {
    final saved = await Get.toNamed(
      AppRoutes.patientForm,
      arguments: {'token': token, 'patient': patient},
    );
    if (saved == true) fetchPatients();
  }

  Future<void> deletePatient(Map<String, dynamic> patient) async {
    try {
      final response = await ApiService.delete(
        '/patients/${patient['_id']}',
        token: token,
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        await Get.find<AuthSession>().signOut();
        return;
      }
      final data = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(data['message'] ?? 'Could not delete patient.');
      }
      recentPatients.removeWhere((item) => item['_id'] == patient['_id']);
      Get.snackbar('Deleted', 'Patient record deleted.');
    } catch (error) {
      Get.snackbar(
        'Delete failed',
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
