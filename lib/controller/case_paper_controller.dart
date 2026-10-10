import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CasePaperController extends GetxController {
  // ==========================================
  // FRAME 1: Demographics & Registry
  // ==========================================
  final occupationController = TextEditingController();
  final maritalStatusController = TextEditingController();
  final referredByController = TextEditingController();

  // ==========================================
  // FRAME 2: Chief Complaints & Causation (LSMC)
  // ==========================================
  final chiefComplaintsController = TextEditingController();
  final causationJourneyController = TextEditingController();

  // Triggers & Transitions
  var selectedEmotions = <String>[].obs;
  var selectedEndocrinalInterventions = <String>[].obs;
  final historyOfMedicinesController = TextEditingController();

  // ==========================================
  // FRAME 3: Past History (CPS Timeline)
  // ==========================================
  var pastDiseases = <String>[].obs;

  // ==========================================
  // FRAME 4: Family History & Miasm
  // ==========================================
  // Represents rows in the Family Matrix: { 'Father': ['HTN', 'Asthma'], 'Mother': ['DM'] }
  var familyHistoryMatrix = <String, RxList<String>>{
    'Paternal Grandfather': <String>[].obs,
    'Paternal Grandmother': <String>[].obs,
    'Maternal Grandfather': <String>[].obs,
    'Maternal Grandmother': <String>[].obs,
    'Father': <String>[].obs,
    'Mother': <String>[].obs,
    'Siblings': <String>[].obs,
  }.obs;

  var selectedMiasm = 'Psora'.obs;

  // ==========================================
  // FRAME 5: Physical Generals & Dreams
  // ==========================================
  var selectedThermals = 'Ambi-thermal'.obs;
  var selectedThirst = 'Normal'.obs;
  var selectedThirstTemp = 'Normal'.obs;
  var sweatIntensity = 'Moderate'.obs;

  // Quick Chips
  var foodDesires = <String>[].obs;
  var foodAversions = <String>[].obs;
  var bowelUrineTraits = <String>[].obs;
  var dreamCategories = <String>[].obs;

  // Modality Matrix (+1 Amel, 0 Neutral, -1 Agg)
  var modalities = <String, RxInt>{
    'Hot Weather': 0.obs,
    'Cold Weather': 0.obs,
    'Rainy Weather': 0.obs,
    'Cloudy Weather': 0.obs,
    'Warm Bath': 0.obs,
    'Cold Bath': 0.obs,
    'Fanning': 0.obs,
    'Sun Exposure': 0.obs,
  };

  // ==========================================
  // FRAME 6: Female History & Hormonal Cycles
  // ==========================================
  final menarcheAgeController = TextEditingController();
  var isCycleRegular = 'Regular'.obs;
  var menstrualFlow = 'Normal'.obs;
  var leucorrhoeaTags = <String>[].obs;
  var mensesConcomitants = <String>[].obs;

  // ==========================================
  // FRAME 7: Examination Findings
  // ==========================================
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final bpController = TextEditingController();
  final pulseController = TextEditingController();
  var objectiveInspectionTags = <String>[].obs;

  // ==========================================
  // FRAME 8: Mentals, Rubrics & Prescription
  // ==========================================
  var mentalRubrics = <String>[].obs;
  final prescriptionNotesController = TextEditingController();

  // Dynamic Prescription List
  var prescribedMedicines = <Map<String, dynamic>>[].obs;
  int _nextMedicineId = 0;

  // ==========================================
  // REFERENCE DICTIONARIES (For Zero-Typing UI)
  // ==========================================
  final List<String> pastDiseaseOptions = [
    'Typhoid',
    'Cholera',
    'Malaria',
    'Jaundice',
    'Chicken Pox',
    'Mumps',
    'Food Poisoning',
    'Worms',
    'Diarrhoea',
    'Asthma',
    'Pleurisy/TB',
    'Nephritis',
    'Diabetes',
    'Rheumatism',
    'Polio',
    'Epilepsy',
    'Eczema/Fungus',
  ];

  final List<String> dreamOptions = [
    'Animals/Dogs/Snakes',
    'Robbers/Thieves',
    'Ghosts/Fearful',
    'Travelling/Flying',
    'Houses/Water',
    'Death/Dead Bodies',
    'Accident/Falling',
    'Business/Money',
    'Weeping/Grief',
    'Police/Murder',
    'Missing Train/Exams',
    'Romantic/Sexual',
  ];

  final List<String> mentalOptions = [
    'Irritable',
    'Anger',
    'Anxious',
    'Suspicious',
    'Fearful',
    'Jealousy',
    'Impatient',
    'Hurried',
    'Revengeful',
    'Brooding',
    'Weeping',
    'Sympathetic',
    'Diligent',
    'Depression',
  ];

  final List<String> miasmOptions = [
    'Psora',
    'Sycosis',
    'Tubercular',
    'Syphilis',
    'Mixed',
  ];

  // ==========================================
  // ACTIONS
  // ==========================================
  void addMedicine() {
    prescribedMedicines.add({
      'id': '${_nextMedicineId++}',
      'name': '',
      'potency': '30C',
      'dosage': '',
    });
  }

  void removeMedicine(int index) {
    prescribedMedicines.removeAt(index);
  }

  void updateMedicine(int index, String key, String value) {
    prescribedMedicines[index][key] = value;
    prescribedMedicines.refresh();
  }

  void saveCasePaper() {
    // API serialization logic will go here
    Get.snackbar(
      'Draft Saved',
      'Case Paper 1 securely stored in memory.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    occupationController.dispose();
    maritalStatusController.dispose();
    referredByController.dispose();
    chiefComplaintsController.dispose();
    causationJourneyController.dispose();
    historyOfMedicinesController.dispose();
    menarcheAgeController.dispose();
    weightController.dispose();
    heightController.dispose();
    bpController.dispose();
    pulseController.dispose();
    prescriptionNotesController.dispose();
    super.onClose();
  }
}
