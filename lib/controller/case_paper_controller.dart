import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import 'auth_session.dart';

class CasePaperController extends GetxController {
  static const List<String> frames = [
    'Frame 1: Demographics & Registry',
    'Frame 2: Chief Complaints & Causation',
    'Frame 3: Past History',
    'Frame 4: Family History & Miasm',
    'Frame 5: Physical Generals & Modalities',
    'Frame 6: Female History',
    'Frame 7: Examination Findings',
    'Frame 8: Mentals & Prescription',
  ];

  final List<String> casePaperTypes = const [
    'Case Paper 1: Original Case Paper (Constitutional)',
    'Case Paper 2: Acute Case Paper',
    'Case Paper 3: Thyroid Case Paper',
  ];
  var selectedCasePaperType =
      'Case Paper 1: Original Case Paper (Constitutional)'.obs;

  // Backend tracking state
  var currentPatientId = ''.obs;
  var editingCasePaperId = ''.obs;
  var isSaving = false.obs;
  var isLoading = false.obs;

  // ==========================================
  // FRAME 1: Demographics & Registry
  // ==========================================
  final occupationController = TextEditingController();
  final maritalStatusController = TextEditingController();
  final referredByController = TextEditingController();

  var selectedMaritalStatus = 'Single'.obs;
  var selectedOccupation = 'Desk Job / Corporate'.obs;
  var selectedReferredBy = 'Self / Direct'.obs;

  // ==========================================
  // FRAME 2: Chief Complaints & Causation (LSMC)
  // ==========================================
  final chiefComplaintsController = TextEditingController();
  final causationJourneyController = TextEditingController();

  // Triggers & Transitions
  var selectedEmotions = <String>[].obs;
  var selectedEndocrinalInterventions = <String>[].obs;
  var selectedCausationTags = <String>[].obs;
  final historyOfMedicinesController = TextEditingController();
  var medicineHistoryTags = <String>[].obs;

  // ==========================================
  // CASE PAPER 2 & 3 SPECIFIC STATES (Acute, Thyroid & Follow-up)
  // ==========================================
  var acuteOnset = 'Sudden (Hours)'.obs;
  var acuteCause = 'Cold Weather / Draught'.obs;
  final acuteNotesController = TextEditingController();

  var followUpStatus = 'Better (Ameliorated)'.obs;
  var remedyReaction = 'Good Action - Continue Remedy'.obs;
  final followUpNotesController = TextEditingController();

  // THYROID CASE PAPER (Case Paper 3)
  var thyroidDiagnosis = 'Hypothyroidism'.obs;
  var thyroidOnsetTrigger = 'Puberty / Hormonal Phase'.obs;
  var goitreLocation = 'Neck Swelling (Diffuse)'.obs;
  var goitreSensation = 'Constriction / Air Passing'.obs;
  var goitreModality = 'Swallowing Aggravation'.obs;
  var physiqueEmaciation = 'Myxoedema / Puffy Physique'.obs;

  final t3Controller = TextEditingController();
  final t4Controller = TextEditingController();
  final tshController = TextEditingController();
  final antiTpoController = TextEditingController();

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

  // ==========================================
  // BACKEND SERIALIZATION & DESERIALIZATION
  // ==========================================
  Map<String, dynamic> toJson() {
    return {
      'patientId': currentPatientId.value,
      'paperType': selectedCasePaperType.value,
      'caseId': editingCasePaperId.value,
      'demographics': {
        'maritalStatus': selectedMaritalStatus.value,
        'occupation': occupationController.text,
        'referredBy': selectedReferredBy.value,
      },
      'chiefComplaints': chiefComplaintsController.text,
      'causation': causationJourneyController.text,
      'historyOfMedicines': historyOfMedicinesController.text,
      'endocrinalInterventions': selectedEndocrinalInterventions.toList(),
      'pastDiseases': pastDiseases.toList(),
      'familyHistoryMatrix': familyHistoryMatrix.map(
        (key, rxList) => MapEntry(key, rxList.toList()),
      ),
      'miasm': selectedMiasm.value,
      'physicalGenerals': {
        'thermals': selectedThermals.value,
        'thirst': selectedThirst.value,
        'thirstTemp': selectedThirstTemp.value,
        'sweatIntensity': sweatIntensity.value,
        'bowelUrineTraits': bowelUrineTraits.toList(),
        'dreamCategories': dreamCategories.toList(),
        'modalities': modalities.map((key, rxInt) => MapEntry(key, rxInt.value)),
      },
      'femaleHistory': {
        'menarcheAge': menarcheAgeController.text,
        'isCycleRegular': isCycleRegular.value,
        'menstrualFlow': menstrualFlow.value,
        'mensesConcomitants': mensesConcomitants.toList(),
        'leucorrhoeaTags': leucorrhoeaTags.toList(),
      },
      'examination': {
        'bp': bpController.text,
        'pulse': pulseController.text,
        'weight': weightController.text,
        'height': heightController.text,
        'inspectionTags': objectiveInspectionTags.toList(),
      },
      'mentals': mentalRubrics.toList(),
      'prescription': prescribedMedicines.map((m) => {
        'name': m['name'] ?? '',
        'potency': m['potency'] ?? '30C',
        'dosage': m['dosage'] ?? '',
      }).toList(),
      'prescriptionNotes': prescriptionNotesController.text,
      'acuteDetails': {
        'onsetSpeed': acuteOnset.value,
        'excitingCause': acuteCause.value,
        'notes': acuteNotesController.text,
      },
      'thyroidDetails': {
        'diagnosis': thyroidDiagnosis.value,
        'onsetTrigger': thyroidOnsetTrigger.value,
        'goitreLocation': goitreLocation.value,
        'goitreSensation': goitreSensation.value,
        'goitreModality': goitreModality.value,
        'physiqueEmaciation': physiqueEmaciation.value,
        't3': t3Controller.text,
        't4': t4Controller.text,
        'tsh': tshController.text,
        'antiTpo': antiTpoController.text,
      },
    };
  }

  void loadCasePaper(Map<String, dynamic> data, String patientId) {
    currentPatientId.value = patientId;
    editingCasePaperId.value =
        data['_id']?.toString() ?? data['caseId']?.toString() ?? '';
    if (data['paperType']?.toString().isNotEmpty == true) {
      selectedCasePaperType.value = data['paperType'].toString();
    }

    final demographics = data['demographics'] is Map
        ? data['demographics'] as Map
        : {};
    selectedMaritalStatus.value =
        demographics['maritalStatus']?.toString() ?? 'Single';
    occupationController.text = demographics['occupation']?.toString() ?? '';
    selectedReferredBy.value =
        demographics['referredBy']?.toString() ?? 'Self / Direct';

    chiefComplaintsController.text = data['chiefComplaints']?.toString() ?? '';
    causationJourneyController.text = data['causation']?.toString() ?? '';
    historyOfMedicinesController.text =
        data['historyOfMedicines']?.toString() ?? '';

    if (data['endocrinalInterventions'] is List) {
      selectedEndocrinalInterventions.assignAll(
        (data['endocrinalInterventions'] as List).cast<String>(),
      );
    }
    if (data['pastDiseases'] is List) {
      pastDiseases.assignAll((data['pastDiseases'] as List).cast<String>());
    }

    if (data['familyHistoryMatrix'] is Map) {
      final matrix = data['familyHistoryMatrix'] as Map;
      matrix.forEach((key, val) {
        if (familyHistoryMatrix.containsKey(key) && val is List) {
          familyHistoryMatrix[key]!.assignAll(val.cast<String>());
        }
      });
    }
    selectedMiasm.value = data['miasm']?.toString() ?? 'Psora';

    final phys = data['physicalGenerals'] is Map
        ? data['physicalGenerals'] as Map
        : {};
    selectedThermals.value = phys['thermals']?.toString() ?? 'Ambi-thermal';
    selectedThirst.value = phys['thirst']?.toString() ?? 'Normal';
    selectedThirstTemp.value = phys['thirstTemp']?.toString() ?? 'Normal';
    sweatIntensity.value = phys['sweatIntensity']?.toString() ?? 'Moderate';
    if (phys['bowelUrineTraits'] is List) {
      bowelUrineTraits.assignAll(
        (phys['bowelUrineTraits'] as List).cast<String>(),
      );
    }
    if (phys['dreamCategories'] is List) {
      dreamCategories.assignAll(
        (phys['dreamCategories'] as List).cast<String>(),
      );
    }
    if (phys['modalities'] is Map) {
      (phys['modalities'] as Map).forEach((k, v) {
        if (modalities.containsKey(k)) {
          modalities[k]!.value =
              (v is int) ? v : (int.tryParse(v.toString()) ?? 0);
        }
      });
    }

    final fem = data['femaleHistory'] is Map
        ? data['femaleHistory'] as Map
        : {};
    menarcheAgeController.text = fem['menarcheAge']?.toString() ?? '';
    isCycleRegular.value = fem['isCycleRegular']?.toString() ?? 'Regular';
    menstrualFlow.value = fem['menstrualFlow']?.toString() ?? 'Normal';
    if (fem['mensesConcomitants'] is List) {
      mensesConcomitants.assignAll(
        (fem['mensesConcomitants'] as List).cast<String>(),
      );
    }
    if (fem['leucorrhoeaTags'] is List) {
      leucorrhoeaTags.assignAll(
        (fem['leucorrhoeaTags'] as List).cast<String>(),
      );
    }

    final exam = data['examination'] is Map
        ? data['examination'] as Map
        : {};
    bpController.text = exam['bp']?.toString() ?? '';
    pulseController.text = exam['pulse']?.toString() ?? '';
    weightController.text = exam['weight']?.toString() ?? '';
    heightController.text = exam['height']?.toString() ?? '';
    if (exam['inspectionTags'] is List) {
      objectiveInspectionTags.assignAll(
        (exam['inspectionTags'] as List).cast<String>(),
      );
    }

    if (data['mentals'] is List) {
      mentalRubrics.assignAll((data['mentals'] as List).cast<String>());
    }

    if (data['prescription'] is List) {
      prescribedMedicines.assignAll(
        (data['prescription'] as List).map((m) {
          final map = m is Map ? m : {};
          return {
            'id': '${_nextMedicineId++}',
            'name': map['name']?.toString() ?? '',
            'potency': map['potency']?.toString() ?? '30C',
            'dosage': map['dosage']?.toString() ?? '',
          };
        }).toList(),
      );
    }
    prescriptionNotesController.text =
        data['prescriptionNotes']?.toString() ?? '';

    final acute = data['acuteDetails'] is Map
        ? data['acuteDetails'] as Map
        : {};
    acuteOnset.value = acute['onsetSpeed']?.toString() ?? 'Sudden (Hours)';
    acuteCause.value =
        acute['excitingCause']?.toString() ?? 'Cold Draught / Wind';
    acuteNotesController.text = acute['notes']?.toString() ?? '';

    final thyroid = data['thyroidDetails'] is Map
        ? data['thyroidDetails'] as Map
        : {};
    thyroidDiagnosis.value =
        thyroid['diagnosis']?.toString() ?? 'Hypothyroidism';
    thyroidOnsetTrigger.value =
        thyroid['onsetTrigger']?.toString() ?? 'Puberty / Hormonal Phase';
    goitreLocation.value =
        thyroid['goitreLocation']?.toString() ?? 'Neck Swelling (Diffuse)';
    goitreSensation.value =
        thyroid['goitreSensation']?.toString() ?? 'Constriction / Air Passing';
    goitreModality.value =
        thyroid['goitreModality']?.toString() ?? 'Swallowing Aggravation';
    physiqueEmaciation.value =
        thyroid['physiqueEmaciation']?.toString() ?? 'Myxoedema / Puffy Physique';
    t3Controller.text = thyroid['t3']?.toString() ?? '';
    t4Controller.text = thyroid['t4']?.toString() ?? '';
    tshController.text = thyroid['tsh']?.toString() ?? '';
    antiTpoController.text = thyroid['antiTpo']?.toString() ?? '';
  }

  void resetForm(String patientId, {String? paperType}) {
    currentPatientId.value = patientId;
    editingCasePaperId.value = '';
    if (paperType != null && paperType.isNotEmpty) {
      selectedCasePaperType.value = paperType;
    } else {
      selectedCasePaperType.value = casePaperTypes[0];
    }
    selectedMaritalStatus.value = 'Single';
    occupationController.clear();
    maritalStatusController.clear();
    referredByController.clear();
    selectedReferredBy.value = 'Self / Direct';
    chiefComplaintsController.clear();
    causationJourneyController.clear();
    historyOfMedicinesController.clear();
    selectedEmotions.clear();
    selectedEndocrinalInterventions.clear();
    selectedCausationTags.clear();
    medicineHistoryTags.clear();
    pastDiseases.clear();
    familyHistoryMatrix.forEach((key, val) => val.clear());
    selectedMiasm.value = 'Psora';
    selectedThermals.value = 'Ambi-thermal';
    selectedThirst.value = 'Normal';
    selectedThirstTemp.value = 'Normal';
    sweatIntensity.value = 'Moderate';
    foodDesires.clear();
    foodAversions.clear();
    bowelUrineTraits.clear();
    dreamCategories.clear();
    modalities.forEach((key, val) => val.value = 0);
    menarcheAgeController.clear();
    isCycleRegular.value = 'Regular';
    menstrualFlow.value = 'Normal';
    leucorrhoeaTags.clear();
    mensesConcomitants.clear();
    weightController.clear();
    heightController.clear();
    bpController.clear();
    pulseController.clear();
    objectiveInspectionTags.clear();
    mentalRubrics.clear();
    prescribedMedicines.clear();
    prescriptionNotesController.clear();
    acuteOnset.value = 'Sudden (Hours)';
    acuteCause.value = 'Cold Weather / Draught';
    acuteNotesController.clear();
    followUpStatus.value = 'Better (Ameliorated)';
    remedyReaction.value = 'Good Action - Continue Remedy';
    followUpNotesController.clear();
    thyroidDiagnosis.value = 'Hypothyroidism';
    thyroidOnsetTrigger.value = 'Puberty / Hormonal Phase';
    goitreLocation.value = 'Neck Swelling (Diffuse)';
    goitreSensation.value = 'Constriction / Air Passing';
    goitreModality.value = 'Swallowing Aggravation';
    physiqueEmaciation.value = 'Myxoedema / Puffy Physique';
    t3Controller.clear();
    t4Controller.clear();
    tshController.clear();
    antiTpoController.clear();
  }

  // ==========================================
  // BACKEND API METHODS (CRUD)
  // ==========================================
  Future<bool> saveCasePaper() async {
    if (currentPatientId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Patient ID is required to save a Case Paper',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    isSaving.value = true;
    try {
      final token = Get.isRegistered<AuthSession>()
          ? Get.find<AuthSession>().token.value
          : null;
      final payload = toJson();
      final isEditing = editingCasePaperId.value.isNotEmpty;
      final endpoint = isEditing
          ? '/case-papers/${editingCasePaperId.value}'
          : '/case-papers';

      final response = isEditing
          ? await ApiService.put(endpoint, payload, token: token)
          : await ApiService.post(endpoint, payload, token: token);

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar(
          'Success',
          isEditing
              ? 'Case Paper updated successfully'
              : 'Case Paper created successfully',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Save Failed',
          data['message'] ?? 'Failed to save Case Paper',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to connect to backend server: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<Map<String, dynamic>?> fetchCasePaperById(String casePaperId) async {
    isLoading.value = true;
    try {
      final token = Get.isRegistered<AuthSession>()
          ? Get.find<AuthSession>().token.value
          : null;
      final response =
          await ApiService.get('/case-papers/$casePaperId', token: token);
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final paper = data['casePaper'] is Map
            ? Map<String, dynamic>.from(data['casePaper'] as Map)
            : null;
        if (paper != null && currentPatientId.value.isNotEmpty) {
          loadCasePaper(paper, currentPatientId.value);
        }
        return paper;
      } else {
        Get.snackbar(
          'Fetch Failed',
          data['message'] ?? 'Could not load Case Paper details',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch Case Paper: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteCasePaper(String casePaperId) async {
    try {
      final token = Get.isRegistered<AuthSession>()
          ? Get.find<AuthSession>().token.value
          : null;
      final response =
          await ApiService.delete('/case-papers/$casePaperId', token: token);
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar(
          'Deleted',
          'Case Paper deleted successfully',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Delete Failed',
          data['message'] ?? 'Could not delete Case Paper',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete Case Paper: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
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
    acuteNotesController.dispose();
    followUpNotesController.dispose();
    t3Controller.dispose();
    t4Controller.dispose();
    tshController.dispose();
    antiTpoController.dispose();
    super.onClose();
  }
}
