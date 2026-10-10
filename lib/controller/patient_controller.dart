import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/perscription_pdf_service.dart';

class PatientController extends GetxController {
  // Demographics
  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();

  var selectedGender = Rx<String?>(null);
  var selectedBloodGroup = Rx<String?>(null);

  // Consultation
  final complaintsController = TextEditingController();
  final diagnosisController = TextEditingController();
  final adviceController = TextEditingController();

  var followUpDate = DateTime.now().add(const Duration(days: 7)).obs;

  // Dynamic Reactive Medicines List
  var medicines = <Map<String, dynamic>>[].obs;
  int _nextMedicineId = 0;

  void addMedicine() {
    medicines.add({
      'id': '${_nextMedicineId++}',
      'name': '',
      'potency': '30C',
      'dosage': '',
    });
  }

  void removeMedicine(int index) {
    medicines.removeAt(index);
  }

  void updateMedicine(int index, String key, String value) {
    medicines[index][key] = value;
    medicines.refresh(); // Tells Obx to rebuild the list
  }

  Future<void> saveAndGeneratePdf() async {
    if (nameController.text.isEmpty || mobileController.text.isEmpty) {
      Get.snackbar('Validation', 'Name and Mobile Number are required.');
      return;
    }

    try {
      // Cast the dynamic map to String map for the PDF service
      List<Map<String, String>> formattedMedicines = medicines
          .map(
            (m) => {
              'name': m['name'].toString(),
              'potency': m['potency'].toString(),
              'dosage': m['dosage'].toString(),
            },
          )
          .toList();

      await PrescriptionPdfService.generateAndPrintPdf(
        patientName: nameController.text.trim(),
        age: ageController.text.trim(),
        gender: selectedGender.value ?? 'Not Specified',
        mobile: mobileController.text.trim(),
        complaints: complaintsController.text.trim(),
        diagnosis: diagnosisController.text.trim(),
        medicines: formattedMedicines,
        advice: adviceController.text.trim(),
        followUpDate: followUpDate.value,
      );

      Get.snackbar('Success', 'Prescription generated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate PDF: $e');
    }
  }

  @override
  void onClose() {
    mobileController.dispose();
    nameController.dispose();
    ageController.dispose();
    addressController.dispose();
    complaintsController.dispose();
    diagnosisController.dispose();
    adviceController.dispose();
    super.onClose();
  }
}
