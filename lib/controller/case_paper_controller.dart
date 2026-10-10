import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:panacea/controller/auth_session.dart';
import 'package:panacea/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CasePaperController extends GetxController {
  // ─── Frame metadata ─────────────────────────────────────────────────────────
  static const frames = [
    'Demographics & Registry',
    'Chief Complaints & Causation',
    'Past History & CPS Timeline',
    'Family History & Miasmatic Diathesis',
    'Physical Generals & Dream Analysis',
    'Female Lifecycle & Hormonal Transitions',
    'Objective Examination & Findings',
    'Mentals, Synthesis & Prescription',
  ];

  // ─── Clinical pick-lists ────────────────────────────────────────────────────
  static const locations = [
    'Head', 'Eyes', 'Ears', 'Nose', 'Face', 'Throat', 'Neck',
    'Chest / lungs', 'Heart / CVS', 'Abdomen', 'Liver / spleen',
    'Kidney / bladder', 'Back / spine', 'Shoulders', 'Arms / elbows',
    'Wrists / hands', 'Hips / thighs', 'Knees', 'Legs / ankles',
    'Feet / toes', 'Skin', 'Nerves', 'Glands / lymph',
  ];

  static const sensations = [
    'Burning', 'Stitching', 'Throbbing / pulsating', 'Pressing / heavy',
    'Cramping / spasmodic', 'Tearing / rending', 'Shooting / lightning',
    'Numbness / tingling', 'Itching', 'Soreness / bruised', 'Constricting',
    'Raw / excoriated', 'Fullness / bloating', 'Weakness / empty',
  ];

  static const complaintModalities = [
    'Motion >', 'Motion <', 'Rest >', 'Rest <',
    'Pressure >', 'Pressure <', 'Heat >', 'Heat <',
    'Cold >', 'Cold <', 'Morning <', 'Evening <', 'Night <',
    'Eating >', 'Eating <', 'Lying down >', 'Lying down <',
  ];

  static const concomitants = [
    'Nausea', 'Vomiting', 'Headache', 'Chill', 'Sweating', 'Palpitation',
    'Weakness / fatigue', 'Anxiety', 'Thirst', 'Appetite loss', 'Diarrhoea',
    'Constipation', 'Urinary urgency', 'Salivation', 'Lachrymation',
  ];

  static const causationTags = [
    'Grief', 'Fright', 'Shock', 'Mortification / humiliation', 'Anger',
    'Suppressed emotions', 'Disappointed love', 'Financial losses',
    'Overwork / mental strain', 'Intrinsic pathology', 'Extrinsic pathology',
    'Puberty', 'Menarche', 'Pregnancy', 'Post-partum', 'Menopause',
    'Vaccination', 'Suppressed eruptions', 'Suppressed discharge',
  ];

  static const pastMedicines = [
    'Allopathic – long term', 'Allopathic – short course',
    'Homeopathic', 'Ayurvedic', 'Steroids', 'Antibiotics – prolonged',
    'Hormonal treatment (OCP / HRT)', 'Analgesics / NSAIDs',
    'Immunosuppressants', 'Chemotherapy', 'Herbal / naturopathy',
  ];

  static const pastDiseases = [
    'Typhoid', 'Cholera', 'Food poisoning', 'Worms / parasites',
    'Diarrhoea / dysentery', 'Malnutrition', 'Rickets', 'Rheumatism',
    'Malaria', 'Jaundice / hepatitis', 'Liver / gallbladder disease',
    'Abortion / miscarriage', 'Hypertension', 'Giddiness / vertigo',
    'Recurrent sinusitis', 'Tonsillitis', 'Bronchitis', 'Asthma / COPD',
    'Nephritis / renal disease', 'Diabetes mellitus', 'Thyroid disorder',
    'Major accident / trauma', 'Major surgery', 'Skin / eczema / fungus',
    'Venereal / STI', 'Epilepsy / seizures', 'Psychiatric illness',
  ];

  static const familyDiseases = [
    'Cancer', 'Diabetes mellitus', 'Rheumatoid arthritis', 'Tuberculosis',
    'Leprosy', 'Epilepsy', 'Bleeding tendencies', 'Asthma', 'Hypertension',
    'Heart disease / IHD', 'Kidney / renal disease', 'Liver disease',
    'Psychiatric illness', 'Autoimmune disease', 'Thyroid disorder',
  ];

  static const relatives = [
    'Paternal grandfather', 'Paternal grandmother',
    'Maternal grandfather', 'Maternal grandmother',
    'Father', 'Mother', 'Siblings', 'Paternal uncle', 'Paternal aunt',
    'Maternal uncle', 'Maternal aunt', 'Cousins',
  ];

  static const miasms = ['Psora', 'Sycosis', 'Tubercular', 'Syphilitic', 'Mixed'];

  static const foodItems = [
    'Sweet', 'Salt', 'Spicy', 'Sour', 'Bitter', 'Meat / non-veg',
    'Milk / dairy', 'Eggs', 'Fish / seafood', 'Warm food', 'Cold food',
    'Ice-cream', 'Bread / starch', 'Fruits', 'Vegetables', 'Fats / oily food',
  ];

  static const sweatTraits = [
    'Staining yellow', 'Staining blue / green', 'Offensive odor',
    'Sour odor', 'Profuse on palms / soles', 'Profuse on scalp',
    'Cold sweat', 'Night sweats', 'One-sided sweat',
  ];

  static const stoolUrineTags = [
    'Constipation – hard', 'Constipation – no urge', 'Loose stools',
    'Mucus in stool', 'Blood in stool', 'Piles / haemorrhoids',
    'Fissure', 'Incomplete evacuation', 'Offensive stool',
    'Urinary urgency', 'Frequent urination', 'Scanty urine', 'Dark urine',
    'Burning micturition', 'Involuntary urination',
  ];

  static const modalityStimuli = [
    'Hot weather', 'Cold weather', 'Rainy / cloudy',
    'Thunderstorm / lightning', 'Sun exposure', 'Sea shore / open air',
    'Fanning / open window', 'Cold bathing', 'Warm bathing',
    'Before eating', 'After eating', 'Eating', 'Lying down',
    'Standing', 'Exercise / motion',
  ];

  static const Map<String, List<String>> dreamGroups = {
    'Animals': ['Dogs', 'Cats', 'Snakes', 'Wild beasts / lions', 'Insects / worms', 'Birds'],
    'Calamities': ['Robbers / thieves', 'Murder / violence', 'Falling from heights', 'Drowning', 'Ghost / supernatural', 'Fire / conflagration', 'War / battles'],
    'Somatic / Physiological': ['Flying / floating', 'Swimming', 'Riding / racing', 'Water / rivers', 'Snow / cold', 'Death', 'Dead bodies', 'Urinating', 'Blood', 'Starving / hungry'],
    'Psychological': ['Failures / disgrace', 'Missing train / bus', 'Being chased / pursued', 'Exams / tests', 'Nakedness / embarrassment', 'Parties / festivities', 'Accidents'],
  };

  static const inspectionTags = [
    'Tongue: coated white', 'Tongue: yellowish coat', 'Tongue: mapped / geographic',
    'Tongue: flabby / teeth-imprinted', 'Tongue: dry cracked', 'Tongue: clean / red',
    'Tongue: trembling', 'Teeth: carious / decayed', 'Teeth: sensitive',
    'Nails: brittle / ridged', 'Nails: clubbing', 'Nails: white spots',
    'Hair: thinning / falling', 'Hair: premature graying', 'Hair: dry / lusterless',
    'Skin: dry / rough', 'Skin: oily', 'Skin: jaundiced tint', 'Skin: pallor',
    'Lymph nodes: cervical enlarged', 'Lymph nodes: axillary enlarged', 'Lymph nodes: inguinal enlarged',
    'Joints: swelling', 'Joints: crepitus', 'Joints: restricted motion',
  ];

  static const mentalRubrics = [
    'Irritable / easily offended', 'Consolation aggravates',
    'Fear of dark', 'Fear of death', 'Fear of disease', 'Fear of poverty',
    'Weeping easily', 'Weeping without cause',
    'Hurried / restless', 'Conscientious about trifles',
    'Suspicious / mistrustful', 'Jealousy', 'Brooding / dwelling on past',
    'Haughtiness / contemptuous', 'Sympathetic / empathetic',
    'Indifferent / apathetic', 'Anxiety about health', 'Anxiety before events',
    'Company desires', 'Company aversion', 'Aversion to family / husband',
    'Religious / scrupulous', 'Alternating moods',
  ];

  static const repertorialRubrics = [
    'Ailments from grief', 'Ailments from fright',
    'Ailments from suppressed anger', 'Ailments from disappointed love',
    'Fear of dark', 'Fear of death', 'Consolation aggravates',
    'Company aversion to', 'Anticipation – complaints from',
    'Irritability before menses', 'Weeping tendency',
    'Hurried feeling', 'Indifference to everything',
    'Censorious / critical', 'Delusion – persecuted',
  ];

  static const potencies = ['3X', '6C', '30C', '200C', '1M', '10M', 'CM', 'LM1', 'LM2', 'LM3'];
  static const doseTypes = ['Pills (4)', 'Pills (6)', 'Drops (5)', 'Drops (10)', 'Liquid (teaspoon)', 'Powder'];
  static const frequencies = [
    'Once daily', 'Twice daily', 'Three times daily', 'Four times daily',
    'Every alternate day', 'Once weekly', 'Twice weekly', 'As needed (SOS)',
    'Single dose', 'Ascending doses',
  ];

  // ─── Homeopathic remedy list ─────────────────────────────────────────────
  static const remedies = [
    'Aconite napellus', 'Aethusa', 'Agnus castus', 'Allium cepa',
    'Aloe socotrina', 'Alumina', 'Ambra grisea', 'Ammonium carb',
    'Anacardium', 'Antimonium crud', 'Antimonium tart', 'Apis mellifica',
    'Argentum nit', 'Arnica montana', 'Arsenicum album', 'Aurum met',
    'Baptisia', 'Baryta carb', 'Belladonna', 'Borax',
    'Bryonia alba', 'Calcarea carb', 'Calcarea fluor', 'Calcarea phos',
    'Cantharis', 'Carbo animalis', 'Carbo veg', 'Causticum',
    'Chamomilla', 'China officinalis', 'Cimicifuga', 'Colocynthis',
    'Conium mac', 'Cuprum met', 'Drosera', 'Dulcamara',
    'Ferrum met', 'Ferrum phos', 'Gelsemium', 'Graphites',
    'Hepar sulph', 'Hyoscyamus', 'Ignatia', 'Iodium',
    'Ipecacuanha', 'Kali bich', 'Kali carb', 'Kali mur',
    'Kali phos', 'Lachesis', 'Ledum pal', 'Lilium tig',
    'Lycopodium', 'Magnesia carb', 'Magnesia mur', 'Medorrhinum',
    'Mercurius sol', 'Mezereum', 'Murex', 'Natrum carb',
    'Natrum mur', 'Natrum sulph', 'Nitric acid', 'Nux moschata',
    'Nux vomica', 'Opium', 'Phosphoric acid', 'Phosphorus',
    'Phytolacca', 'Platina', 'Plumbum met', 'Podophyllum',
    'Psorinum', 'Pulsatilla', 'Rhus tox', 'Rumex',
    'Ruta grav', 'Sabadilla', 'Secale cor', 'Sepia',
    'Silicea', 'Spongia', 'Staphysagria', 'Stramonium',
    'Sulphur', 'Syphilinum', 'Tarentula hisp', 'Thuja',
    'Tuberculinum', 'Veratrum alb', 'Zincum met',
  ];

  // ─── Observable state ────────────────────────────────────────────────────────
  final patient   = <String, dynamic>{}.obs;
  final papers    = <Map<String, dynamic>>[].obs;
  final draft     = <String, dynamic>{}.obs;
  final medicineEntries = <Map<String, dynamic>>[].obs;
  final currentFrame    = 0.obs;
  final isSaving        = false.obs;
  final autosaveStatus  = 'Draft not saved'.obs;
  final isFemale        = false.obs;

  String? token;
  String? editingId;
  bool isNewPaper = true;
  Timer? _autosaveTimer;

  // ─── Draft persistence keys ───────────────────────────────────────────────
  String get _newDraftKey =>
      'panacea.casePaperDraft.${patient['_id'] ?? 'unknown'}.new';
  String _existingDraftKey(String id) =>
      'panacea.casePaperDraft.${patient['_id'] ?? 'unknown'}.$id';

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      token = args['token']?.toString();
      final patArg = args['patient'];
      if (patArg is Map) patient.assignAll(Map<String, dynamic>.from(patArg));
      final paperArg = args['paper'];
      if (paperArg is Map) {
        final paper = Map<String, dynamic>.from(paperArg);
        editingId = (paper['caseId'] ?? paper['_id'])?.toString();
        isNewPaper = false;
        final data = paper['data'];
        if (data is Map) draft.assignAll(Map<String, dynamic>.from(data));
      }
      final pp = patient['casePapers'];
      if (pp is List) {
        papers.assignAll(pp.whereType<Map>().map(Map<String, dynamic>.from));
      }
    }
    if (token == null && Get.isRegistered<AuthSession>()) {
      token = Get.find<AuthSession>().token.value;
    }
    if (draft.isEmpty) _initializeNewDraft();
    isFemale.value = _genderIsFemale;
    _loadMedicineEntries();
    unawaited(_restoreLocalDraft());
  }

  // ─── Computed helpers ─────────────────────────────────────────────────────
  bool get _genderIsFemale =>
      (draft['gender']?.toString().toLowerCase() ?? '') == 'female';

  int get completedFrameCount =>
      List.generate(frames.length, isFrameComplete).where((d) => d).length;

  double? get bmi {
    final w = double.tryParse(draft['weight']?.toString() ?? '');
    final h = double.tryParse(draft['height']?.toString() ?? '');
    if (w == null || h == null || h <= 0) return null;
    final hm = h / 100;
    return w / (hm * hm);
  }

  bool isFrameComplete(int index) {
    if (index == 5 && !isFemale.value) return true;
    const keys = [
      ['date', 'name', 'age', 'gender'],
      ['chiefComplaint', 'causationTags'],
      ['cpsTimeline'],
      ['familyDiseases', 'miasm'],
      ['thermal', 'dreamTags'],
      ['menarcheAge', 'cycleRhythm'],
      ['pulse', 'weight'],
      ['mentalTags', 'prescriptionMedicines'],
    ];
    for (final key in keys[index]) {
      final value = draft[key];
      if (value is String && value.trim().isNotEmpty) return true;
      if (value is List && value.isNotEmpty) return true;
      if (value is Map && value.isNotEmpty) return true;
    }
    return false;
  }

  // ─── Draft initialisation ─────────────────────────────────────────────────
  void _initializeNewDraft() {
    editingId ??= DateTime.now().microsecondsSinceEpoch.toString();
    isNewPaper = true;
    draft.assignAll({
      // Frame 1 – Demographics
      'date': DateTime.now().toIso8601String().split('T').first,
      'caseId': '',
      'name': patient['name']?.toString() ?? '',
      'age': patient['age']?.toString() ?? '',
      'gender': patient['gender']?.toString() ?? '',
      'mobile': patient['mobile']?.toString() ?? '',
      'address': patient['address']?.toString() ?? '',
      'occupation': '',
      'maritalStatus': '',
      'referredBy': '',
      // Frame 2 – Complaints
      'chiefComplaint': '',
      'onsetDate': '',
      'onsetDuration': '',
      'locations': <String>[],
      'sensations': <String>[],
      'complaintModalities': <String>[],
      'concomitants': <String>[],
      'causationTags': <String>[],
      'pastMedicines': <String>[],
      'primaryKeynote': '',
      'causationJourneyNotes': '',
      // Frame 3 – Past history
      'pastDiseasesTags': <String>[],
      'cpsTimeline': <Map<String, dynamic>>[],
      'surgicalHistory': '',
      'pastHistoryNotes': '',
      // Frame 4 – Family / miasm
      'familyDiseases': <String>[],
      'relativeHistory': <String, dynamic>{},
      'miasm': '',
      'miasmNotes': '',
      // Frame 5 – Generals
      'foodDesires': <String>[],
      'foodAversions': <String>[],
      'foodAggravations': <String>[],
      'thermal': '',
      'thirst': '',
      'waterTemperature': '',
      'sweatIntensity': 1,
      'sweatTraits': <String>[],
      'stoolUrineTags': <String>[],
      'modalities': <String, String>{},
      'dreamTags': <String>[],
      'generalsNotes': '',
      // Frame 6 – Female
      'menarcheAge': '',
      'cycleDays': '',
      'cyclePeriodDays': '',
      'cycleRhythm': '',
      'flowCharacter': <String>[],
      'menstrualTiming': <String, String>{},
      'leucorrhoeaColor': <String>[],
      'leucorrhoeaTraits': <String>[],
      'pregnancies': 0,
      'liveChildren': 0,
      'abortions': 0,
      'dnc': 0,
      'lactationMonths': 0,
      'ocpUse': '',
      'obstetricNotes': '',
      // Frame 7 – Examination
      'pulse': '',
      'bloodPressure': '',
      'respiratoryRate': '',
      'temperature': '',
      'weight': '',
      'height': '',
      'inspectionTags': <String>[],
      'eyes': '',
      'ears': '',
      'nose': '',
      'throat': '',
      'respiratory': '',
      'cvs': '',
      'git': '',
      'cns': '',
      'objectiveFindings': '',
      // Frame 8 – Mentals + prescription
      'mentalTags': <String>[],
      'mentalNotes': '',
      'rubrics': <String>[],
      'repertorizationNotes': '',
      'remedyDifferential': '',
      'prescriptionMedicines': <Map<String, dynamic>>[],
      'followUpDate': '',
      'followUpNotes': '',
      'doctorConclusion': '',
    });
    isFemale.value = _genderIsFemale;
  }

  Future<void> _restoreLocalDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = isNewPaper ? _newDraftKey : _existingDraftKey(editingId ?? '');
      final encoded = prefs.getString(key);
      if (encoded == null) return;
      final decoded = jsonDecode(encoded);
      if (decoded is! Map || decoded['data'] is! Map) return;
      draft.assignAll(Map<String, dynamic>.from(decoded['data'] as Map));
      isFemale.value = _genderIsFemale;
      _loadMedicineEntries();
      autosaveStatus.value = 'Draft Auto-saved';
    } catch (_) {
      autosaveStatus.value = 'Draft not saved';
    }
  }

  // ─── Field mutations ──────────────────────────────────────────────────────
  void updateField(String key, dynamic value) {
    draft[key] = value;
    if (key == 'gender') isFemale.value = _genderIsFemale;
    _queueAutosave();
  }

  void toggleSelection(String key, String value) {
    final s = _strings(draft[key]);
    if (!s.add(value)) s.remove(value);
    draft[key] = s.toList();
    _queueAutosave();
  }

  Set<String> selectedValues(String key) => _strings(draft[key]);

  void assignSelection(String key, Iterable<String> values) {
    draft[key] = values.toSet().toList();
    _queueAutosave();
  }

  void setSingleValue(String key, String value) {
    draft[key] = value;
    _queueAutosave();
  }

  void setModality(String stimulus, String value) {
    final m = Map<String, String>.from(
      (draft['modalities'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {},
    );
    m[stimulus] = value;
    draft['modalities'] = m;
    _queueAutosave();
  }

  String modalityFor(String stimulus) =>
      ((draft['modalities'] as Map?)?[stimulus] ?? '0').toString();

  void setMenstrualTiming(String symptom, String timing) {
    final m = Map<String, String>.from(
      (draft['menstrualTiming'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {},
    );
    m[symptom] = timing;
    draft['menstrualTiming'] = m;
    _queueAutosave();
  }

  String menstrualTimingFor(String symptom) =>
      ((draft['menstrualTiming'] as Map?)?[symptom] ?? '').toString();

  void updateRelative(String relationship, String field, dynamic value) {
    final h = Map<String, dynamic>.from((draft['relativeHistory'] as Map?) ?? {});
    final r = Map<String, dynamic>.from((h[relationship] as Map?) ?? {});
    r[field] = value;
    h[relationship] = r;
    draft['relativeHistory'] = h;
    _queueAutosave();
  }

  // ─── CPS timeline ─────────────────────────────────────────────────────────
  void addCpsEntry({
    required String disease,
    required int year,
    required String etiology,
    required String severity,
    required String symptomStatus,
  }) {
    final entries = _mapList(draft['cpsTimeline']);
    entries.add({
      'disease': disease,
      'year': year,
      'etiology': etiology,
      'severity': severity,
      'symptomStatus': symptomStatus,
    });
    draft['cpsTimeline'] = entries;
    toggleSelection('pastDiseasesTags', disease);
    _queueAutosave();
  }

  void removeCpsEntry(int index) {
    final entries = _mapList(draft['cpsTimeline']);
    if (index < 0 || index >= entries.length) return;
    entries.removeAt(index);
    draft['cpsTimeline'] = entries;
    _queueAutosave();
  }

  // ─── Medicine entries ─────────────────────────────────────────────────────
  void addMedicine() {
    medicineEntries.add({
      'name': '',
      'potency': '30C',
      'dose': 'Pills (4)',
      'frequency': 'Once daily',
      'duration': '',
      'notes': '',
    });
    _syncMedicines();
  }

  void updateMedicine(int index, String key, dynamic value) {
    if (index < 0 || index >= medicineEntries.length) return;
    medicineEntries[index][key] = value;
    medicineEntries.refresh();
    _syncMedicines();
  }

  void removeMedicine(int index) {
    if (index < 0 || index >= medicineEntries.length) return;
    medicineEntries.removeAt(index);
    _syncMedicines();
  }

  void _loadMedicineEntries() {
    medicineEntries.assignAll(_mapList(draft['prescriptionMedicines']));
  }

  void _syncMedicines() {
    draft['prescriptionMedicines'] = medicineEntries
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
    _queueAutosave();
  }

  // ─── Auto-save ────────────────────────────────────────────────────────────
  void _queueAutosave() {
    autosaveStatus.value = 'Saving draft…';
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 700), saveLocally);
  }

  Future<void> saveLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = isNewPaper ? _newDraftKey : _existingDraftKey(editingId ?? '');
      await prefs.setString(key, jsonEncode({
        'caseId': editingId,
        'data': Map<String, dynamic>.from(draft),
      }));
      autosaveStatus.value = 'Draft Auto-saved';
    } catch (_) {
      autosaveStatus.value = 'Draft save failed';
    }
  }

  // ─── Remote save ──────────────────────────────────────────────────────────
  Future<bool> saveToPatient({bool showFeedback = true}) async {
    final patientId = patient['_id']?.toString();
    if (patientId == null || patientId.isEmpty) {
      if (showFeedback) Get.snackbar('Save blocked', 'Save the patient profile first.');
      return false;
    }
    if (token == null || token!.isEmpty) {
      if (showFeedback) Get.snackbar('Session expired', 'Please sign in again.');
      return false;
    }
    isSaving.value = true;
    _autosaveTimer?.cancel();
    try {
      final nextPapers = papers.map(Map<String, dynamic>.from).toList();
      final idx = nextPapers.indexWhere(
        (p) => (p['caseId'] ?? p['_id'])?.toString() == editingId,
      );
      final record = <String, dynamic>{
        if (idx >= 0) ...nextPapers[idx],
        'paperType': '1',
        'caseId': editingId,
        'data': Map<String, dynamic>.from(draft),
      };
      if (idx >= 0) nextPapers[idx] = record; else nextPapers.add(record);

      final response = await ApiService.put('/patients/$patientId', {
        'casePapers': nextPapers,
      }, token: token);
      if (response.statusCode == 401 || response.statusCode == 403) {
        await Get.find<AuthSession>().signOut();
        return false;
      }
      final result = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(result['message'] ?? 'Could not save case paper.');
      }
      if (result is Map && result['patient'] is Map) {
        patient.assignAll(Map<String, dynamic>.from(result['patient'] as Map));
        final sp = patient['casePapers'];
        if (sp is List) papers.assignAll(sp.whereType<Map>().map(Map<String, dynamic>.from));
      } else {
        papers.assignAll(nextPapers);
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(isNewPaper ? _newDraftKey : _existingDraftKey(editingId ?? ''));
      } catch (_) {}
      autosaveStatus.value = 'Saved to patient record';
      if (showFeedback) Get.snackbar('Saved', 'Case Paper 1 saved.');
      return true;
    } catch (e) {
      autosaveStatus.value = 'Save failed';
      if (showFeedback) Get.snackbar('Save failed', e.toString());
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> switchToPaper(Map<String, dynamic>? paper) async {
    await saveLocally();
    if (paper == null) {
      editingId = DateTime.now().microsecondsSinceEpoch.toString();
      isNewPaper = true;
      currentFrame.value = 0;
      draft.clear();
      medicineEntries.clear();
      _initializeNewDraft();
      autosaveStatus.value = 'Draft not saved';
      return;
    }
    final data = paper['data'];
    editingId = (paper['caseId'] ?? paper['_id'])?.toString();
    isNewPaper = false;
    currentFrame.value = 0;
    draft.assignAll(data is Map ? Map<String, dynamic>.from(data) : {});
    isFemale.value = _genderIsFemale;
    _loadMedicineEntries();
    autosaveStatus.value = 'Saved to patient record';
    await _restoreLocalDraft();
  }

  // ─── Utilities ────────────────────────────────────────────────────────────
  Set<String> _strings(dynamic value) => value is Iterable
      ? value.map((e) => e.toString()).toSet()
      : <String>{};

  List<Map<String, dynamic>> _mapList(dynamic value) => value is Iterable
      ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
      : <Map<String, dynamic>>[];

  @override
  void onClose() {
    _autosaveTimer?.cancel();
    super.onClose();
  }
}
