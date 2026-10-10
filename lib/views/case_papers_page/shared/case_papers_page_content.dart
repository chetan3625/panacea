import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panacea/controller/auth_session.dart';
import 'package:panacea/constants/app_routes.dart';
import 'package:panacea/services/api_service.dart';
import 'package:panacea/services/case_paper_pdf_service.dart';
import 'package:panacea/controller/case_paper_controller.dart';
import 'package:panacea/components/case_paper_components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:panacea/theme/app_theme.dart';
import 'package:panacea/theme/app_widgets.dart';

class CasePapersPageContent extends StatefulWidget {
  const CasePapersPageContent({super.key});

  @override
  State<CasePapersPageContent> createState() => _CasePapersPageContentState();
}

class _CasePapersPageContentState extends State<CasePapersPageContent> {
  static const _frames = [
    'Demographics & core registry',
    'Chief complaints & causation journey',
    'Past history & chronic disease timeline',
    'Family history & diathesis',
    'Physical generals & dreams',
    'Female / menstrual / hormonal lifecycle',
    'Physical & objective examination',
    'Mind, rubrics & doctor conclusions',
  ];

  static const _completionKeys = [
    ['name', 'age', 'occupation', 'maritalStatus', 'mobile', 'address'],
    [
      'chiefComplaint',
      'complaintLocation',
      'complaintSensation',
      'onsetAndJourney',
    ],
    ['pastDiseases', 'timeline', 'pastHistoryNotes'],
    ['familyDiseases', 'relatives', 'similarFamilyTrouble'],
    ['foodDesires', 'foodAversions', 'thermal', 'thirst', 'dreamTypes'],
    ['menarcheAge', 'cycle', 'flowCharacter', 'pregnancyHistory'],
    [
      'respiratory',
      'cvs',
      'git',
      'bloodPressure',
      'pulse',
      'objectiveFindings',
    ],
    ['mentalNarrative', 'mindThemes', 'rubrics', 'caseAnalysis'],
  ];

  static const _pastDiseases = [
    'Typhoid',
    'Cholera',
    'Food poisoning',
    'Worms',
    'Diarrhoea',
    'Malnutrition',
    'Rickets',
    'Rheumatism',
    'Backache',
    'Malaria',
    'Jaundice',
    'Liver / spleen / gallbladder disease',
    'Abortion',
    'Pregnancy sickness',
    'Uterine prolapse',
    'Heart trouble',
    'High blood pressure',
    'Operation',
    'Diphtheria',
    'Tonsillitis',
    'Sinusitis',
    'Bronchitis',
    'Asthma',
    'Pleurisy / TB',
    'Nephritis',
    'Diabetes',
    'Prostate trouble',
    'Depression / nervous breakdown',
    'Chronic headache',
    'Numbness',
    'Cramps',
    'Fits / convulsions',
    'Polio',
    'Paralysis',
    'Major accident',
    'Unconsciousness',
    'Major bleeding',
    'Psoriasis / eczema',
    'Allergy / ulcers',
    'Chickenpox / smallpox',
    'Measles',
    'Mumps',
  ];

  static const _familyDiseases = [
    'Anaemia',
    'Cancer',
    'Diabetes',
    'Insanity',
    'Rheumatoid arthritis',
    'TB / pleurisy',
    'Leprosy',
    'Epilepsy',
    'Bleeding tendency',
    'Urticaria',
    'Eczema',
    'Asthma',
    'Paralysis',
    'Hypertension',
    'Heart trouble',
    'Kidney disease',
    'Liver disease',
  ];

  static const _relatives = [
    'Paternal grandfather',
    'Paternal grandmother',
    'Maternal grandfather',
    'Maternal grandmother',
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Paternal uncle',
    'Paternal aunt',
    'Maternal uncle',
    'Maternal aunt',
    'Paternal cousins',
    'Maternal cousins',
  ];

  static const _dreams = [
    'Animals',
    'Cats / dogs',
    'Horses',
    'Wild animals',
    'Snakes',
    'Robbers',
    'Anxious',
    'Fearful',
    'Ghosts',
    'Travelling',
    'Riding',
    'Flying',
    'Swimming',
    'Drowning',
    'Houses',
    'Fruits / trees',
    'Water',
    'Snow',
    'Death',
    'Dead bodies',
    'Dead persons',
    'Fire',
    'Storm / rain',
    'Accidents',
    'Falling',
    'Shooting / wars',
    'Talking / singing',
    'Pleasant',
    'Business / money',
    'Forgotten work',
    'Vomiting',
    'Passing stool / urinating',
    'Blood / bleeding',
    'Romantic / sexual',
    'Nakedness',
    'Pain / illness',
    'Praying / religious',
    'Temple / church',
    'Failures / exams',
    'Missing a train',
    'Grief / weeping',
    'Quarrels / jealousy',
    'Police / imprisonment',
    'Being chased',
    'Danger / insecurity',
    'Parties / marriage',
    'Prophetic',
    'Physical exertion',
    'Mental exertion',
    'Fatigue',
    'Coloured',
    'Multi-coloured',
  ];

  static const _modalities = [
    'Hot weather',
    'Cold weather',
    'Rain',
    'Cloudy weather',
    'Thunderstorm',
    'Covering',
    'Warm bath',
    'Sun',
    'Fanning / air conditioning',
    'Cold bathing',
    'Sea shore',
    'Riding in a vehicle',
    'Lying with head low',
    'Lying on back',
    'Lying on right side',
    'Lying on left side',
    'Lying on abdomen',
  ];

  static const _rubricSuggestions = [
    'Ailments from anticipation',
    'Anxiety about health',
    'Company, aversion to',
    'Consolation, aggravates',
    'Contradiction, intolerant of',
    'Fear of dark',
    'Fear of death',
    'Grief, ailments from',
    'Industrious',
    'Indifference',
    'Irritability before menses',
    'Jealousy',
    'Mind, restlessness',
    'Offended easily',
    'Aversion to being alone',
    'Weeping, consolation ameliorates',
  ];

  late Map<String, dynamic> _patient;
  String? _token;
  String? _editingId;
  final Map<String, dynamic> _draft = {};
  int _openFrame = 0;
  bool _isSaving = false;
  final bool _isNewDraft = false;
  String _draftSaveStatus = 'Draft not saved';
  Timer? _draftAutosaveTimer;

  String get _newDraftStorageKey =>
      'panacea.casePaperDraft.${_patient['_id'] ?? 'unknown'}.new';

  String _existingDraftStorageKey(String caseId) =>
      'panacea.casePaperDraft.${_patient['_id'] ?? 'unknown'}.$caseId';

  List<Map<String, dynamic>> _fetchedPapers = [];
  List<Map<String, dynamic>> _fetchedFollowUps = [];
  bool _isLoadingPapers = false;

  @override
  void initState() {
    super.initState();
    _patient = <String, dynamic>{};
    final arguments = Get.arguments;
    if (arguments is Map) {
      _token = arguments['token']?.toString();
      final patient = arguments['patient'];
      if (patient is Map) _patient = Map<String, dynamic>.from(patient);
      if (arguments['startNew'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startNewPaper();
        });
      }
    }
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    await Future.wait([_fetchCasePapers(), _fetchFollowUps()]);
  }

  Future<void> _fetchCasePapers() async {
    final patientId = _patient['_id']?.toString();
    if (patientId == null || patientId.isEmpty) return;
    if (mounted) setState(() => _isLoadingPapers = true);
    try {
      final response = await ApiService.get(
        '/case-papers/patient/$patientId',
        token: _token,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['casePapers'] is List) {
        final list = (data['casePapers'] as List)
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
        if (mounted) {
          setState(() {
            _fetchedPapers = list;
            // Do NOT overwrite _patient['casePapers'] here — the _papers getter
            // deduplicates both sources, and overwriting risks cross-source mixing.
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingPapers = false);
    }
  }

  Future<void> _fetchFollowUps() async {
    final patientId = _patient['_id']?.toString();
    if (patientId == null || patientId.isEmpty) return;
    try {
      final response = await ApiService.get(
        '/follow-ups/patient/$patientId',
        token: _token,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['followUps'] is List) {
        final list = (data['followUps'] as List)
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
        if (mounted) setState(() => _fetchedFollowUps = list);
      }
    } catch (_) {}
  }

  List<Map<String, dynamic>> get _papers {
    List<Map<String, dynamic>> raw;

    if (_fetchedPapers.isNotEmpty) {
      // Standalone CasePaper collection docs are authoritative — use only these.
      raw = _fetchedPapers;
    } else if (_isLoadingPapers) {
      // Still loading — show nothing to avoid flash of embedded snapshots
      return [];
    } else {
      // Nothing fetched yet (e.g. patient has no _id) — fall back to embedded
      final papers = _patient['casePapers'];
      if (papers is! List) return [];
      raw = papers
          .whereType<Map>()
          .map(Map<String, dynamic>.from)
          .toList();
    }

    // Deduplicate by the canonical CasePaper _id.
    // caseId is the authoritative link (server sets snapshot.caseId = casePaper._id).
    // Fall back to _id only when caseId is absent (e.g. very old records).
    final seen = <String>{};
    final deduped = <Map<String, dynamic>>[];
    for (final paper in raw) {
      final id = (paper['caseId'] ?? paper['_id'] ?? '').toString();
      if (id.isNotEmpty && seen.contains(id)) continue;
      if (id.isNotEmpty) seen.add(id);
      deduped.add(paper);
    }

    // Sort newest-first by createdAt, falling back to date string.
    deduped.sort((a, b) {
      final dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '');
      final dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '');
      if (dateA != null && dateB != null) return dateB.compareTo(dateA);
      final dataA = a['data'] is Map ? a['data'] as Map : a;
      final dataB = b['data'] is Map ? b['data'] as Map : b;
      return (dataB['date']?.toString() ?? '')
          .compareTo(dataA['date']?.toString() ?? '');
    });

    return deduped;
  }

  Future<void> _startNewPaper([String? paperType]) async {
    final patientId = _patient['_id']?.toString() ?? '';
    final result = await Get.toNamed(
      AppRoutes.casePaperForm,
      arguments: {
        'token': _token,
        'patient': _patient,
        'patientId': patientId,
        'paperType':
            paperType ?? 'Case Paper 1:(Constitutional)',
      },
    );
    if (result == true) {
      await _fetchAll();
      _showMessage('Saved');
    }
  }

  Future<void> _editPaper(Map<String, dynamic> paper) async {
    final patientId = _patient['_id']?.toString() ?? '';
    final caseId =
        paper['_id']?.toString() ?? paper['caseId']?.toString() ?? '';
    final result = await Get.toNamed(
      AppRoutes.casePaperForm,
      arguments: {
        'token': _token,
        'patient': _patient,
        'patientId': patientId,
        'casePaperId': caseId,
        'paper': paper,
      },
    );
    if (result == true) {
      await _fetchAll();
      _showMessage('Saved');
    }
  }

  void _queueDraftAutosave() {
    _draftAutosaveTimer?.cancel();
    if (_editingId == null) return;
    setState(() => _draftSaveStatus = 'Saving draft…');
    _draftAutosaveTimer = Timer(const Duration(milliseconds: 700), () {
      _persistDraftLocally();
    });
  }

  Future<void> _persistDraftLocally() async {
    final caseId = _editingId;
    if (caseId == null) return;
    final key = _isNewDraft
        ? _newDraftStorageKey
        : _existingDraftStorageKey(caseId);
    final payload = jsonEncode({'caseId': caseId, 'data': _draft});
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, payload);
      if (mounted) setState(() => _draftSaveStatus = 'Draft Auto-saved');
    } catch (_) {
      if (mounted) setState(() => _draftSaveStatus = 'Draft save failed');
    }
  }

  bool _isFrameComplete(int index) {
    if (index == 5 &&
        (_draft['gender']?.toString().toLowerCase() ?? '') != 'female') {
      return true;
    }
    for (final key in _completionKeys[index]) {
      final value = _draft[key];
      if (value is String && value.trim().isNotEmpty) return true;
      if (value is List && value.isNotEmpty) return true;
      if (value is Map && value.isNotEmpty) return true;
    }
    return false;
  }

  int get _completedFrameCount => List.generate(
    _frames.length,
    _isFrameComplete,
  ).where((done) => done).length;

  List<Map<String, dynamic>> _timelineEntries() {
    final entries = _draft['timeline'];
    if (entries is! List) return [];
    return entries.whereType<Map<String, dynamic>>().toList();
  }

  Map<String, dynamic> _relativeData(String relationship) {
    final relatives = _draft['relatives'];
    if (relatives is Map && relatives[relationship] is Map) {
      return Map<String, dynamic>.from(relatives[relationship] as Map);
    }
    return {};
  }

  void _setRelative(String relationship, String key, String value) {
    final relatives = Map<String, dynamic>.from(
      (_draft['relatives'] as Map?) ?? {},
    );
    final data = Map<String, dynamic>.from(
      (relatives[relationship] as Map?) ?? {},
    );
    data[key] = value;
    relatives[relationship] = data;
    _draft['relatives'] = relatives;
    _queueDraftAutosave();
  }

  Set<String> _selected(String key) {
    final value = _draft[key];
    return value is List ? value.map((item) => item.toString()).toSet() : {};
  }

  Widget _textField(
    String key,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      key: ValueKey('$_editingId-$key'),
      initialValue: _draft[key]?.toString() ?? '',
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) {
        _draft[key] = value;
        _queueDraftAutosave();
      },
    );
  }

  Widget _fieldWrap(BuildContext context, List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 600
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields
              .map((field) => SizedBox(width: width, child: field))
              .toList(),
        );
      },
    );
  }

  Widget _choiceChips(String key, List<String> choices, {String? label}) {
    final selected = _selected(key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 2,
          children: choices.map((choice) {
            return FilterChip(
              label: Text(choice),
              selected: selected.contains(choice),
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    selected.add(choice);
                  } else {
                    selected.remove(choice);
                  }
                  _draft[key] = selected.toList();
                });
                _queueDraftAutosave();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _diseasePicker(
    String key,
    List<String> choices, {
    required String label,
  }) {
    if (MediaQuery.sizeOf(context).width >= 600) {
      return _choiceChips(key, choices, label: label);
    }
    final selected = _selected(key).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _openDiseasePicker(key, choices, label),
          icon: const Icon(Icons.filter_list),
          label: Text(
            selected.isEmpty
                ? 'Choose from ${choices.length} diseases'
                : '${selected.length} selected',
          ),
        ),
        if (selected.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: selected
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(label: Text(item)),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _openDiseasePicker(
    String key,
    List<String> choices,
    String label,
  ) async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _DiseasePickerSheet(
        label: label,
        choices: choices,
        initiallySelected: _selected(key),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _draft[key] = result.toList());
    _queueDraftAutosave();
  }

  Widget _segmented(String key, String label, List<String> options) {
    final value = _draft[key]?.toString();
    final selected = options.contains(value) ? value! : options.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<String>(
            segments: options
                .map(
                  (option) =>
                      ButtonSegment<String>(value: option, label: Text(option)),
                )
                .toList(),
            selected: {selected},
            onSelectionChanged: (values) {
              setState(() => _draft[key] = values.first);
              _queueDraftAutosave();
            },
          ),
        ),
      ],
    );
  }

  Widget _modalityMatrix() {
    final values = Map<String, dynamic>.from(
      (_draft['modalities'] as Map?) ?? {},
    );
    return Column(
      children: _modalities.map((stimulus) {
        final selected = values[stimulus]?.toString() ?? '0';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(flex: 4, child: Text(stimulus)),
              Expanded(
                flex: 7,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: '+',
                        label: Text('+ Amel.'),
                        tooltip: 'Ameliorates',
                      ),
                      ButtonSegment(value: '0', label: Text('0 Neutral')),
                      ButtonSegment(
                        value: '-',
                        label: Text('- Aggr.'),
                        tooltip: 'Aggravates',
                      ),
                    ],
                    selected: {selected},
                    onSelectionChanged: (selection) {
                      values[stimulus] = selection.first;
                      setState(() => _draft['modalities'] = values);
                      _queueDraftAutosave();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _frameBody(int index) {
    switch (index) {
      case 0:
        return _buildRegistryFrame();
      case 1:
        return _buildComplaintFrame();
      case 2:
        return _buildPastHistoryFrame();
      case 3:
        return _buildFamilyFrame();
      case 4:
        return _buildGeneralsFrame();
      case 5:
        return _buildFemaleFrame();
      case 6:
        return _buildExaminationFrame();
      default:
        return _buildMindFrame();
    }
  }

  Widget _buildRegistryFrame() {
    return _fieldWrap(context, [
      _textField('date', 'Date'),
      _textField('caseId', 'Case ID'),
      _textField('name', 'Patient name'),
      _textField('age', 'Age'),
      _textField('occupation', 'Occupation'),
      _textField('maritalStatus', 'Marital status'),
      _textField('mobile', 'Mobile number', keyboardType: TextInputType.phone),
      _textField('address', 'Address'),
      _textField('referredBy', 'Referred to us by'),
      _textField('gender', 'Gender'),
    ]);
  }

  Widget _buildComplaintFrame() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _textField(
          'chiefComplaint',
          'Chief complaints and associated trouble',
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        Text('LSMC', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        _fieldWrap(context, [
          _textField('complaintLocation', 'Location'),
          _textField('complaintSensation', 'Sensation'),
          _textField('complaintModalities', 'Modalities'),
          _textField('complaintConcomitants', 'Concomitants'),
          _textField(
            'onsetAndJourney',
            'Onset, course and journey to present illness',
            maxLines: 3,
          ),
          _textField(
            'causation',
            'Possible cause: emotional / intrinsic / external',
            maxLines: 2,
          ),
          _textField(
            'pathologyJourney',
            'Inflammation, degeneration, discharges and pathology',
            maxLines: 2,
          ),
          _textField(
            'endocrineHistory',
            'Developmental, puberty, pregnancy or menopause interventions',
            maxLines: 2,
          ),
          _textField(
            'medicineHistory',
            'Medicines taken and their effects',
            maxLines: 2,
          ),
          _textField('complaintDiagnosis', 'Diagnosis and since when'),
          _textField(
            'conclusion1',
            'Doctor conclusion 1: peculiar findings',
            maxLines: 3,
          ),
        ]),
      ],
    );
  }

  Widget _buildPastHistoryFrame() {
    final entries = _timelineEntries();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _diseasePicker(
          'pastDiseases',
          _pastDiseases,
          label: 'Past disease history',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'CPS timeline',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Add timeline entry',
              onPressed: () {
                setState(() {
                  entries.add({
                    'disease': '',
                    'year': '',
                    'cause': '',
                    'symptoms': '',
                  });
                  _draft['timeline'] = entries;
                });
                _queueDraftAutosave();
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        ...entries.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'History ${index + 1}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove timeline entry',
                        onPressed: () {
                          setState(() {
                            entries.removeAt(index);
                            _draft['timeline'] = entries;
                          });
                          _queueDraftAutosave();
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  _fieldWrap(context, [
                    _entryField(item, 'disease', 'Disease'),
                    _entryField(item, 'year', 'Year'),
                    _entryField(item, 'cause', 'Cause'),
                    _entryField(item, 'symptoms', 'Symptoms and effects'),
                  ]),
                ],
              ),
            ),
          );
        }),
        _textField(
          'pastHistoryNotes',
          'Additional notes and chronological effects',
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        _textField(
          'conclusion2',
          'Doctor conclusion 2: CPS timeline',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _entryField(Map<String, dynamic> item, String key, String label) {
    return TextFormField(
      key: ValueKey('$_editingId-timeline-${item.hashCode}-$key'),
      initialValue: item[key]?.toString() ?? '',
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) {
        item[key] = value;
        _queueDraftAutosave();
      },
    );
  }

  Widget _buildFamilyFrame() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _diseasePicker(
          'familyDiseases',
          _familyDiseases,
          label: 'Family disease history',
        ),
        const SizedBox(height: 12),
        _textField(
          'similarFamilyTrouble',
          'Relatives with similar trouble to yours',
        ),
        const SizedBox(height: 12),
        Text(
          'Relative details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildRelativeDetails(),
        const SizedBox(height: 8),
        _textField(
          'conclusion3',
          'Doctor conclusion 3: miasmatic background',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRelativeDetails() {
    if (MediaQuery.sizeOf(context).width >= 1100) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 14,
          columns: const [
            DataColumn(label: Text('Relationship')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Age')),
            DataColumn(label: Text('Disease suffered')),
            DataColumn(label: Text('Cause of death')),
          ],
          rows: _relatives.map((relationship) {
            return DataRow(
              cells: [
                DataCell(SizedBox(width: 150, child: Text(relationship))),
                DataCell(
                  SizedBox(width: 135, child: _relativeStatus(relationship)),
                ),
                DataCell(
                  SizedBox(
                    width: 75,
                    child: _relativeField(relationship, 'age', 'Age'),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 180,
                    child: _relativeField(relationship, 'disease', 'Disease'),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 180,
                    child: _relativeField(
                      relationship,
                      'causeOfDeath',
                      'Cause of death',
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
    }
    return Column(
      children: _relatives.map((relationship) {
        final data = _relativeData(relationship);
        final active = data.values.any((value) => value.toString().isNotEmpty);
        return ExpansionTile(
          key: ValueKey('$_editingId-relative-$relationship'),
          title: Text(relationship),
          subtitle: active ? Text(data['disease']?.toString() ?? '') : null,
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: [
            _fieldWrap(context, [
              _relativeField(relationship, 'status', 'Alive / deceased'),
              _relativeField(relationship, 'age', 'Age'),
              _relativeField(relationship, 'disease', 'Disease suffered'),
              _relativeField(relationship, 'causeOfDeath', 'Cause of death'),
            ]),
          ],
        );
      }).toList(),
    );
  }

  Widget _relativeStatus(String relationship) {
    const statuses = ['Alive', 'Deceased', 'Unknown'];
    final current = _relativeData(relationship)['status']?.toString();
    return DropdownButtonFormField<String>(
      key: ValueKey('$_editingId-$relationship-status'),
      initialValue: statuses.contains(current) ? current : null,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: statuses
          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
          .toList(),
      onChanged: (value) {
        if (value != null) _setRelative(relationship, 'status', value);
      },
    );
  }

  Widget _relativeField(String relationship, String key, String label) {
    final value = _relativeData(relationship)[key]?.toString() ?? '';
    return TextFormField(
      key: ValueKey('$_editingId-$relationship-$key'),
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) => _setRelative(relationship, key, value),
    );
  }

  Widget _buildGeneralsFrame() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldWrap(context, [
          _textField('foodDesires', 'Food desires / cravings'),
          _textField('foodAversions', 'Food aversions'),
          _textField('foodAggravations', 'Food aggravations'),
          _textField('foodAmeliorations', 'Food ameliorations'),
          _textField('appetiteTime', 'Appetite: time and hunger'),
          _textField('appetiteTolerance', 'Appetite and diet tolerance'),
          _textField(
            'sweat',
            'Sweat: intensity, smell, staining, location, triggers',
            maxLines: 2,
          ),
          _textField(
            'stools',
            'Stools: consistency, constipation, diarrhoea, bleeding',
            maxLines: 2,
          ),
          _textField('urine', 'Urine: smell and burning'),
          _textField(
            'sleepAndOther',
            'Sleep position, saliva, moaning, walking, talking, teeth grinding',
            maxLines: 2,
          ),
          _textField(
            'seasonalAggravation',
            'Seasonal aggravations / ameliorations',
          ),
          _textField('coveringsAndBathing', 'Coverings, tolerance and bathing'),
        ]),
        const SizedBox(height: 16),
        _segmented('thermal', 'Thermals', const [
          'Chilly',
          'Hot',
          'Ambi-thermal',
        ]),
        const SizedBox(height: 14),
        _segmented('thirst', 'Thirst preference', const [
          'Cold',
          'Warm',
          'Thirstless',
        ]),
        const SizedBox(height: 14),
        _segmented('foodTemperature', 'Food preference', const [
          'Hot',
          'Cold',
          'No preference',
        ]),
        const SizedBox(height: 14),
        _segmented('appetiteTiming', 'Appetite timing', const [
          'Morning',
          'Afternoon',
          'Evening',
          'Variable',
        ]),
        const SizedBox(height: 14),
        _segmented('sweatIntensity', 'Sweat intensity', const [
          'Scanty',
          'Normal',
          'Excessive',
        ]),
        const SizedBox(height: 20),
        Text('Modality matrix', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _modalityMatrix(),
        const SizedBox(height: 12),
        _choiceChips('dreamTypes', _dreams, label: 'Dream types'),
        const SizedBox(height: 16),
        _textField(
          'conclusion4',
          'Doctor conclusion 4: all generals and tendencies',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildFemaleFrame() {
    final isFemale =
        (_draft['gender']?.toString().toLowerCase() ?? '') == 'female';
    if (!isFemale) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'This frame is shown for female patients. Set gender in Frame 1 to Female to enter lifecycle details.',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldWrap(context, [
          _textField('menarcheAge', 'Age at first menstrual period'),
          _textField('lastMenstrualPeriod', 'Last menstrual period'),
          _textField(
            'menarcheComplaints',
            'Complaints during menarche',
            maxLines: 2,
          ),
          _textField('cycle', 'Cycle: regular / irregular'),
          _textField('periodDays', 'Number of days'),
          _textField('flowCharacter', 'Flow and character'),
          _textField('staining', 'Staining'),
          _textField('menstrualSmell', 'Smell'),
          _textField(
            'cycleInterventions',
            'Medicinal, emotional, hormonal, abortion, D&C or OCP history',
            maxLines: 2,
          ),
          _textField(
            'leucorrhoea',
            'Leucorrhoea: colour, character, stains and odour',
            maxLines: 2,
          ),
          _textField(
            'leucorrhoeaFactors',
            'Leucorrhoea aggravating and ameliorating factors',
          ),
          _textField(
            'pregnancyHistory',
            'Pregnancy and abortion history',
            maxLines: 2,
          ),
          _textField('ocPills', 'Oral contraceptive pills: name and duration'),
          _textField(
            'lactation',
            'Breastfeeding, complaints and return of menses',
            maxLines: 2,
          ),
          _textField(
            'hormonalPhases',
            'Puberty, menopause, lactation or other hormonal phases',
            maxLines: 2,
          ),
        ]),
        const SizedBox(height: 16),
        _choiceChips('flowTraits', const [
          'Profuse',
          'Scanty',
          'Clotted',
          'Dark',
          'Bright red',
          'Stringy',
          'Spotting',
          'Offensive',
        ], label: 'Flow characteristics'),
        const SizedBox(height: 12),
        _choiceChips('menstrualConcomitants', const [
          'Breast complaints',
          'Cravings',
          'Mood swings',
          'Pain',
          'Thirst',
          'Sleep changes',
          'Perspiration',
          'GI',
          'CNS',
          'Mind',
          'CVS',
          'Respiratory',
          'Skin',
        ], label: 'Common concomitants'),
        const SizedBox(height: 16),
        Text(
          'Concomitants by cycle timing',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...[
          'Breast complaints',
          'Cravings',
          'Mood swings',
          'Pain',
          'Thirst',
          'Sleep',
          'Perspiration',
          'GI / CNS / mind / CVS / RS / skin',
        ].map(_timingSelector),
        const SizedBox(height: 12),
        _textField(
          'peculiarDuringMenses',
          'Peculiar symptoms during menses',
          maxLines: 3,
        ),
        _textField(
          'conclusion5',
          'Doctor conclusion 5: female / hormonal',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _timingSelector(String symptom) {
    final timings = Map<String, dynamic>.from(
      (_draft['menstrualTiming'] as Map?) ?? {},
    );
    final selected = timings[symptom]?.toString() ?? '';
    final choices = Wrap(
      spacing: 4,
      children: ['Before', 'During', 'After'].map((timing) {
        return ChoiceChip(
          label: Text(timing),
          selected: selected == timing,
          onSelected: (active) {
            timings[symptom] = active ? timing : '';
            setState(() => _draft['menstrualTiming'] = timings);
            _queueDraftAutosave();
          },
        );
      }).toList(),
    );
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: constraints.maxWidth < 520
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(symptom), choices],
              )
            : Row(
                children: [
                  Expanded(child: Text(symptom)),
                  choices,
                ],
              ),
      ),
    );
  }

  Widget _buildExaminationFrame() {
    return _fieldWrap(context, [
      _textField('respiratory', 'Respiratory'),
      _textField('cvs', 'CVS'),
      _textField('git', 'GIT'),
      _textField('bloodPressure', 'Blood pressure'),
      _textField('pulse', 'Pulse'),
      _textField('build', 'Build'),
      _textField('weight', 'Weight'),
      _textField('height', 'Height'),
      _textField('eyes', 'Eyes'),
      _textField('ears', 'Ears'),
      _textField('nose', 'Nose'),
      _textField('tongue', 'Tongue'),
      _textField('nails', 'Nails'),
      _textField('hair', 'Hair'),
      _textField('throat', 'Throat'),
      _textField('lymphNodes', 'Lymph nodes'),
      _textField('joints', 'Joints'),
      _textField(
        'objectiveFindings',
        'Objective findings: skin, teeth, discolouration, local heat / sweat / coldness, discharges',
        maxLines: 3,
      ),
      _textField(
        'conclusion6',
        'Doctor conclusion 6: objective findings',
        maxLines: 3,
      ),
    ]);
  }

  Widget _buildMindFrame() {
    final rubrics = _selected('rubrics').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _textField(
          'mentalNarrative',
          'Mental symptoms: triggers, expression and reaction',
          maxLines: 4,
        ),
        const SizedBox(height: 14),
        _choiceChips('mindThemes', const [
          'Irritability',
          'Anger',
          'Anxiety',
          'Suspicion',
          'Fear',
          'Doubt',
          'Jealousy',
          'Impatience',
          'Hurried',
          'Revengeful',
          'Hurt',
          'Pride',
          'Depression',
          'Brooding',
          'Weeping',
          'Grief',
          'Conscientious',
          'Stress',
          'Sympathy / consolation',
        ], label: 'Mind and disposition'),
        const SizedBox(height: 16),
        Text(
          'Homeopathic rubrics',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (value) {
            final query = value.text.trim().toLowerCase();
            if (query.isEmpty) return _rubricSuggestions;
            return _rubricSuggestions.where(
              (rubric) => rubric.toLowerCase().contains(query),
            );
          },
          onSelected: (rubric) {
            setState(() {
              rubrics.add(rubric);
              _draft['rubrics'] = rubrics.toSet().toList();
            });
            _queueDraftAutosave();
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
              TextField(
                controller: controller,
                focusNode: focusNode,
                onSubmitted: (value) {
                  final rubric = value.trim();
                  if (rubric.isNotEmpty) {
                    setState(() {
                      rubrics.add(rubric);
                      _draft['rubrics'] = rubrics.toSet().toList();
                    });
                    _queueDraftAutosave();
                    controller.clear();
                  }
                  onSubmitted();
                },
                decoration: const InputDecoration(
                  hintText: 'Search or enter a rubric',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: rubrics
              .map(
                (rubric) => InputChip(
                  label: Text(rubric),
                  onDeleted: () {
                    setState(() {
                      rubrics.remove(rubric);
                      _draft['rubrics'] = rubrics;
                    });
                    _queueDraftAutosave();
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        _fieldWrap(context, [
          _textField(
            'relationshipAndHobbies',
            'Relationships, effects and hobbies',
            maxLines: 2,
          ),
          _textField(
            'memoryAndAmbitions',
            'Memory, childhood, ambitions and enjoyed activities',
            maxLines: 2,
          ),
          _textField(
            'symptomOrder',
            'Symptoms arranged by peculiarity',
            maxLines: 2,
          ),
          _textField('caseAnalysis', 'Case analysis', maxLines: 3),
          _textField('remedyGiven', 'Remedy given'),
          _textField('followUp', 'Follow-up plan', maxLines: 2),
          _textField('doctorConclusion8', 'Doctor conclusions', maxLines: 3),
        ]),
      ],
    );
  }

  Widget _buildPaperList() {
    final patientSummary = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _patient['name']?.toString() ?? 'Patient',
            style: Theme.of(context).textTheme.headlineSmall,
            overflow: TextOverflow.ellipsis,
          ),
          Text('${_papers.length} case paper${_papers.length == 1 ? '' : 's'}'),
        ],
      ),
    );

    // Build timeline: merge case papers and follow-ups, sorted newest first
    final List<Map<String, dynamic>> timelineVisits = [];

    // Add case papers
    for (final paper in _papers) {
      final data = paper['data'] is Map ? paper['data'] as Map : paper;
      final date = data['date']?.toString() ?? '';
      final complaint = data['chiefComplaint']?.toString() ?? data['chiefComplaints']?.toString() ?? '';
      final title = data['paperType']?.toString() ??
          paper['paperType']?.toString() ??
          'Case Paper';
      // Build remedy string from prescription if available
      String remedy = '';
      if (data['remedy'] != null && data['remedy'].toString().isNotEmpty) {
        remedy = data['remedy'].toString();
      } else if (paper['prescription'] is List && (paper['prescription'] as List).isNotEmpty) {
        final first = (paper['prescription'] as List).first;
        if (first is Map) {
          remedy = '${first['name'] ?? ''} ${first['potency'] ?? ''}'.trim();
        }
      }
      final isFollowUp = data['isFollowUp'] == true ||
          title == 'Follow-Up Visit' ||
          paper['paperType'] == 'Follow-Up Visit';
      final status = data['status']?.toString().isNotEmpty == true
          ? data['status'].toString()
          : (isFollowUp ? 'Ameliorated (+30%)' : 'Baseline Intake');

      timelineVisits.add({
        'date': date,
        'time': data['time']?.toString() ?? '',
        'title': title,
        'status': status,
        'remedy': remedy,
        'isFollowUp': isFollowUp,
        'paperData': paper,
        'chiefComplaint': complaint,
      });
    }

    // Add real follow-ups from backend (newest first from server already, but sort defensively)
    final sortedFollowUps = [..._fetchedFollowUps];
    sortedFollowUps.sort((a, b) {
      final dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '');
      final dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '');
      if (dateA != null && dateB != null) return dateB.compareTo(dateA);
      return (b['date']?.toString() ?? '').compareTo(a['date']?.toString() ?? '');
    });

    for (final fu in sortedFollowUps) {
      final date = fu['date']?.toString() ?? '';
      final status = fu['progressionStatus']?.toString() ?? fu['status']?.toString() ?? '';
      final remedy = fu['remedyPrescribed']?.toString() ?? '';
      final notes = fu['clinicalNotes']?.toString() ?? '';
      timelineVisits.add({
        'date': date,
        'time': fu['time']?.toString() ?? '',
        'title': 'Follow-Up Visit',
        'status': status,
        'remedy': remedy,
        'isFollowUp': true,
        'followUpData': fu,
        'chiefComplaint': notes,
        'createdAt': fu['createdAt']?.toString() ?? '',
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isLoadingPapers) const LinearProgressIndicator(),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            patientSummary,
            PopupMenuButton<String>(
              tooltip: 'Select Case Paper Type',
              onSelected: (type) {
                String selectedType =
                    'Case Paper 1: Original Case Paper (Constitutional)';
                if (type == 'cp2') {
                  selectedType = 'Case Paper 2: Acute Case Paper';
                } else if (type == 'cp3') {
                  selectedType = 'Case Paper 3: Thyroid Case Paper';
                }
                _startNewPaper(selectedType);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'cp1',
                  child: ListTile(
                    leading: Icon(Icons.note_alt_outlined, color: AppColors.primary),
                    title: Text('Case Paper 1: Original Case Paper'),
                    subtitle: Text('Constitutional Comprehensive Intake'),
                  ),
                ),
                PopupMenuItem(
                  value: 'cp2',
                  child: ListTile(
                    leading: Icon(Icons.flash_on_rounded, color: Colors.orange),
                    title: Text('Case Paper 2: Acute Case Paper'),
                    subtitle: Text('Quick Intake for Acute Conditions'),
                  ),
                ),
                PopupMenuItem(
                  value: 'cp3',
                  child: ListTile(
                    leading: Icon(Icons.flutter_dash_rounded, color: Colors.purple),
                    title: Text('Case Paper 3: Thyroid Case Paper'),
                    subtitle: Text('Specialized Endocrinology Intake'),
                  ),
                ),
              ],
                child: FilledButton(
                  onPressed: null,
                  style: FilledButton.styleFrom(disabledBackgroundColor: AppColors.primary, disabledForegroundColor: Colors.white),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 4),
                    Text('New Case Paper'),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _showLogFollowUpDialog(context),
              icon: const Icon(Icons.track_changes_rounded, color: AppColors.primary),
              label: const Text('Log Follow-Up Visit'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildOverallProgressCard(),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.directions_railway_filled, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Patient Visit & Follow-Up Timeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tap any station node on the vertical train track to view that day\'s complete Case Paper / Follow-Up.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondary,
              ),
        ),
        const SizedBox(height: 16),
        WhereIsMyTrainTimeline(
          visits: timelineVisits..sort((a, b) {
            DateTime parseDate(Map<String, dynamic> m) {
              final ca = m['createdAt'] ?? (m['paperData'] is Map ? m['paperData']['createdAt'] : null);
              if (ca != null) {
                final p = DateTime.tryParse(ca.toString());
                if (p != null) return p;
              }
              final d = m['date']?.toString().trim() ?? '';
              final parts = d.split('/');
              if (parts.length == 3) {
                final day = int.tryParse(parts[0]);
                final month = int.tryParse(parts[1]);
                final year = int.tryParse(parts[2]);
                if (day != null && month != null && year != null) {
                  return DateTime(year, month, day);
                }
              }
              return DateTime.tryParse(d) ?? DateTime(2000);
            }
            return parseDate(b).compareTo(parseDate(a));
          }),
          onTapVisit: (visit) {
            _showVisitDetailsModal(context, visit);
          },
        ),
      ],
    );
  }

  Widget _buildOverallProgressCard() {
    final latest = _fetchedFollowUps.isEmpty ? null : _fetchedFollowUps.first;
    final status = latest?['progressionStatus']?.toString() ?? latest?['status']?.toString() ?? 'No follow-up recorded';
    final percentMatch = RegExp(r'([+-]?\d+)\s*%').firstMatch(status);
    final percent = int.tryParse(percentMatch?.group(1) ?? '') ?? 0;
    const color = AppColors.success;
    const tint = AppColors.successLight;
    return AppCard(
      color: tint,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text('Overall progress', style: Theme.of(context).textTheme.titleMedium)),
          Text(percent == 0 ? status : '${percent > 0 ? '+' : ''}$percent%', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: (0.5 + percent / 200).clamp(0.0, 1.0), color: color, backgroundColor: AppColors.card),
        const SizedBox(height: 8),
        Text(latest == null ? 'Progress will appear after the first follow-up.' : 'Based on the latest follow-up visit.', style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }

  Widget _buildEditor() {
    // Determine the title from the currently editing paper's type
    final currentPaperTitle = () {
      if (_editingId == null) return 'Case Paper';
      final match = _papers.where((p) =>
          (p['caseId'] ?? p['_id'])?.toString() == _editingId).toList();
      if (match.isNotEmpty) {
        final data = match.first['data'] is Map ? match.first['data'] as Map : match.first;
        return data['paperType']?.toString() ?? match.first['paperType']?.toString() ?? 'Case Paper';
      }
      return _draft['paperType']?.toString() ?? 'Case Paper';
    }();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Back to case papers',
              onPressed: () => setState(() => _editingId = null),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Text(
                currentPaperTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('Frame ${_openFrame + 1} of ${_frames.length}'),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: List.generate(_frames.length, (index) {
            return ChoiceChip(
              label: Text('${index + 1}'),
              tooltip: _frames[index],
              selected: _openFrame == index,
              onSelected: (_) => setState(() => _openFrame = index),
            );
          }),
        ),
        const SizedBox(height: 12),
        ...List.generate(_frames.length, (index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              key: ValueKey('$_editingId-frame-$index-${_openFrame == index}'),
              initiallyExpanded: _openFrame == index,
              onExpansionChanged: (expanded) {
                if (expanded) setState(() => _openFrame = index);
              },
              title: Text('Frame ${index + 1}: ${_frames[index]}'),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              children: [_frameBody(index)],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDesktopEditor() {
    final completed = _completedFrameCount;

    // Determine title from currently editing paper
    final currentPaperTitle = () {
      if (_editingId == null) return 'Case Paper';
      final match = _papers.where((p) =>
          (p['caseId'] ?? p['_id'])?.toString() == _editingId).toList();
      if (match.isNotEmpty) {
        final data = match.first['data'] is Map ? match.first['data'] as Map : match.first;
        return data['paperType']?.toString() ?? match.first['paperType']?.toString() ?? 'Case Paper';
      }
      return _draft['paperType']?.toString() ?? 'Case Paper';
    }();

    return Row(
      children: [
        SizedBox(
          width: 264,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            padding: const EdgeInsets.fromLTRB(14, 20, 10, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  currentPaperTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text('$completed/8 completed'),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: completed / _frames.length),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _frames.length,
                    itemBuilder: (context, index) {
                      final complete = _isFrameComplete(index);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            dense: true,
                            selected: _openFrame == index,
                            leading: SizedBox(
                              width: 28,
                              child: Center(
                                child: complete
                                    ? Icon(
                                        Icons.check_circle,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      )
                                    : Text('${index + 1}'),
                              ),
                            ),
                            title: Text(_frames[index], maxLines: 2),
                            onTap: () => setState(() => _openFrame = index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
                child: Text(
                  'Frame ${_openFrame + 1} of 8  ·  ${_frames[_openFrame]}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                  child: _frameBody(_openFrame),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _savePaper({
    bool closeAfterSave = true,
    bool showFeedback = true,
  }) async {
    final patientId = _patient['_id']?.toString();
    if (patientId == null || patientId.isEmpty) {
      if (showFeedback) {
        _showMessage('Save the patient profile before adding case papers.');
      }
      return false;
    }
    if (_token == null || _token!.isEmpty) {
      if (showFeedback) {
        _showMessage('Please sign in again to save case papers.');
      }
      return false;
    }
    _draftAutosaveTimer?.cancel();
    setState(() => _isSaving = true);
    try {
      final papers = _papers;
      final index = papers.indexWhere(
        (paper) => paper['caseId']?.toString() == _editingId,
      );
      final record = <String, dynamic>{
        if (index >= 0) ...papers[index],
        'paperType': '1',
        'caseId': _editingId,
        'data': Map<String, dynamic>.from(_draft),
      };
      if (index >= 0) {
        papers[index] = record;
      } else {
        papers.add(record);
      }
      await _persistPapers(papers);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(
          _isNewDraft
              ? _newDraftStorageKey
              : _existingDraftStorageKey(_editingId!),
        );
      } catch (_) {
        // The server record is saved even if local cleanup fails.
      }
      if (mounted) {
        setState(() {
          _draftSaveStatus = 'Saved to patient record';
          if (closeAfterSave) _editingId = null;
        });
      }
      final paperType = _draft['paperType']?.toString() ?? 'Case Paper';
      if (showFeedback) _showMessage('$paperType saved.');
      return true;
    } catch (error) {
      if (mounted) setState(() => _draftSaveStatus = 'Save failed');
      if (showFeedback) {
        _showMessage(
          'Could not save case paper: ${error.toString().replaceFirst('Exception: ', '')}',
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAndGenerateMasterPdf() async {
    final saved = await _savePaper(closeAfterSave: false, showFeedback: false);
    if (!saved) return;
    try {
      await CasePaperPdfService.generateAndPrint(
        patientName:
            _patient['name']?.toString() ??
            _draft['name']?.toString() ??
            'Patient',
        caseData: Map<String, dynamic>.from(_draft),
      );
      _showMessage('Case Paper 1 saved and PDF generated.');
    } catch (error) {
      _showMessage('Paper saved, but PDF generation failed: $error');
    }
  }

  Future<void> _switchCasePaper(String value) async {
    _draftAutosaveTimer?.cancel();
    await _persistDraftLocally();
    if (value == '__new__') {
      await _startNewPaper();
      return;
    }
    final matches = _papers.where(
      (paper) => (paper['caseId'] ?? paper['_id'])?.toString() == value,
    );
    if (matches.isNotEmpty) await _editPaper(matches.first);
  }

  Widget _buildSwitchCaseButton() {
    return PopupMenuButton<String>(
      tooltip: 'Switch Case Paper',
      onSelected: _switchCasePaper,
      itemBuilder: (context) => [
        const PopupMenuItem(value: '__new__', child: Text('New Case Paper')),
        if (_papers.isNotEmpty) const PopupMenuDivider(),
        ..._papers.map((paper) {
          final caseId = (paper['caseId'] ?? paper['_id']).toString();
          final data = paper['data'] is Map ? paper['data'] as Map : paper;
          final date = data['date']?.toString() ?? 'Undated';
          final type = data['paperType']?.toString() ??
              paper['paperType']?.toString() ??
              'Case Paper';
          return PopupMenuItem(
            value: caseId,
            child: Text('$type · $date'),
          );
        }),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_horiz),
            SizedBox(width: 8),
            Text('Switch Case Paper'),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopActionFooter() {
    final isAutosaved = _draftSaveStatus == 'Draft Auto-saved';
    final switchButton = _buildSwitchCaseButton();
    final pdfButton = FilledButton.icon(
      onPressed: _isSaving ? null : _saveAndGenerateMasterPdf,
      icon: const Icon(Icons.picture_as_pdf_outlined),
      label: const Text('Save & Generate Master PDF'),
    );
    final saveStatus = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isAutosaved ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(_draftSaveStatus),
      ],
    );
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  saveStatus,
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [switchButton, pdfButton],
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                saveStatus,
                const Spacer(),
                switchButton,
                const SizedBox(width: 12),
                pdfButton,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _deletePaper(Map<String, dynamic> paper) async {
    final caseId = paper['_id']?.toString() ?? paper['caseId']?.toString();
    if (caseId == null || caseId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete case paper?'),
        content: const Text(
          'This case paper will be permanently removed from the patient record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final controller = Get.isRegistered<CasePaperController>()
        ? Get.find<CasePaperController>()
        : Get.put(CasePaperController());

    final success = await controller.deleteCasePaper(caseId);
    if (success) {
      await _fetchAll();
    }
  }

  Future<void> _persistPapers(List<Map<String, dynamic>> papers) async {
    final response = await ApiService.put('/patients/${_patient['_id']}', {
      'casePapers': papers,
    }, token: _token);
    if (response.statusCode == 401 || response.statusCode == 403) {
      await Get.find<AuthSession>().signOut();
      throw Exception('Your session has expired.');
    }
    final result = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        result is Map ? result['message'] ?? 'Save failed.' : 'Save failed.',
      );
    }
    if (result is Map && result['patient'] is Map && mounted) {
      setState(
        () => _patient = Map<String, dynamic>.from(result['patient'] as Map),
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingId != null;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = viewportWidth >= 900;
    final isCompact = viewportWidth < 600;
    final contentWidth = viewportWidth < 1120 ? viewportWidth : 1120.0;
    final footerWidth = (contentWidth - 264).clamp(0.0, 920.0).toDouble();
    final footerRightInset = (viewportWidth - contentWidth) / 2 + 12;
    return Scaffold(
      appBar: AppBar(title: const Text('Patient case papers')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final contentWidth = availableWidth < 1120 ? availableWidth : 1120.0;
          return Center(
            child: SizedBox(
              width: contentWidth,
              height: constraints.maxHeight,
              child: isEditing && availableWidth >= 1100
                  ? _buildDesktopEditor()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      children: [
                        isEditing ? _buildEditor() : _buildPaperList(),
                      ],
                    ),
            ),
          );
        },
      ),
      bottomNavigationBar: isEditing
          ? isDesktop
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: footerRightInset,
                        bottom: 8,
                      ),
                      child: SizedBox(
                        width: footerWidth,
                        child: _buildDesktopActionFooter(),
                      ),
                    ),
                  )
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        children: [
                          if (isCompact)
                            IconButton(
                              tooltip: 'Previous frame',
                              onPressed: _openFrame == 0
                                  ? null
                                  : () => setState(() => _openFrame--),
                              icon: const Icon(Icons.chevron_left),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: _openFrame == 0
                                  ? null
                                  : () => setState(() => _openFrame--),
                              icon: const Icon(Icons.chevron_left),
                              label: const Text('Previous'),
                            ),
                          const Spacer(),
                          Text('${_openFrame + 1} / ${_frames.length}'),
                          const Spacer(),
                          if (isCompact)
                            IconButton(
                              tooltip: 'Next frame',
                              onPressed: _openFrame == _frames.length - 1
                                  ? null
                                  : () => setState(() => _openFrame++),
                              icon: const Icon(Icons.chevron_right),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: _openFrame == _frames.length - 1
                                  ? null
                                  : () => setState(() => _openFrame++),
                              icon: const Icon(Icons.chevron_right),
                              label: const Text('Next'),
                            ),
                          const SizedBox(width: 10),
                          FilledButton.icon(
                            onPressed: _isSaving ? null : _savePaper,
                            icon: _isSaving
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(_isSaving ? 'Saving' : 'Save'),
                          ),
                        ],
                      ),
                    ),
                  )
          : null,
    );
  }

  void _showLogFollowUpDialog(BuildContext context) {
    final statusController = TextEditingController(text: 'Better (+40% Ameliorated)');
    final remedyController = TextEditingController(text: 'Continue Current Remedy');
    final notesController = TextEditingController();
    String selectedStatus = 'Better +40%';
    final activePapers = _papers.map((paper) {
      final data = paper['data'] is Map ? paper['data'] as Map : paper;
      return data['paperType']?.toString() ?? paper['paperType']?.toString() ?? 'Case Paper';
    }).toSet().toList();
    const statuses = <String, String>{
      'Better +70%': 'Better (+70% Ameliorated)',
      'Better +40%': 'Better (+40% Ameliorated)',
      'Unchanged 0%': 'Unchanged (Status Quo 0%)',
      'Worse -20%': 'Worse (-20% Aggravated)',
    };

    if (MediaQuery.sizeOf(context).width >= 900) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: _followUpTitle(context),
            content: SizedBox(
              width: 480,
              child: _followUpForm(
                activePapers, statuses, selectedStatus,
                (value) => setState(() {
                  selectedStatus = value;
                  statusController.text = statuses[value]!;
                }),
                remedyController, notesController,
              ),
            ),
            actions: _followUpActions(dialogContext, statusController, remedyController, notesController),
          ),
        ),
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setState) => SafeArea(
            top: false,
            child: Container(
              height: MediaQuery.sizeOf(sheetContext).height * .88,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.all(Radius.circular(4)))),
                const SizedBox(height: 12),
                _followUpTitle(context),
                const SizedBox(height: 14),
                Expanded(child: _followUpForm(
                  activePapers, statuses, selectedStatus,
                  (value) => setState(() {
                    selectedStatus = value;
                    statusController.text = statuses[value]!;
                  }),
                  remedyController, notesController,
                )),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: _followUpActions(sheetContext, statusController, remedyController, notesController)),
              ]),
            ),
          ),
        ),
      );
    }
  }

  Widget _followUpTitle(BuildContext context) => Row(children: [
    const Icon(Icons.track_changes_rounded, color: AppColors.primary),
    const SizedBox(width: 8),
    Expanded(child: Text('Log follow-up', maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge)),
  ]);

  Widget _followUpForm(
    List<String> activePapers,
    Map<String, String> statuses,
    String selectedStatus,
    ValueChanged<String> onStatusSelected,
    TextEditingController remedyController,
    TextEditingController notesController,
  ) => SingleChildScrollView(child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
        child: Text(
          activePapers.isEmpty ? 'Using data from: No case papers yet.' : 'Using data from: ${activePapers.join(' and ')}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.primary),
        ),
      ),
      const SizedBox(height: 16),
      const Text('How is the patient doing overall?'),
      const SizedBox(height: 8),
      ...statuses.keys.map((label) {
        final isSelected = selectedStatus == label;
        final isWorse = label.startsWith('Worse');
        final color = isWorse ? AppColors.danger : AppColors.success;
        final light = isWorse ? AppColors.dangerLight : AppColors.successLight;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: isSelected ? light : Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onStatusSelected(label),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? color : AppColors.border)),
                child: Row(children: [
                  Expanded(child: Text(label.split(' ').first == 'Better' ? 'Better' : label.split(' ').first, overflow: TextOverflow.ellipsis, style: TextStyle(color: isSelected ? color : null))),
                  Text(label.split(' ').last, style: TextStyle(color: isSelected ? color : null)),
                ]),
              ),
            ),
          ),
        );
      }),
      const SizedBox(height: 10),
      TextField(controller: remedyController, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Remedy and posology')),
      const SizedBox(height: 12),
      TextField(controller: notesController, maxLines: 3, textInputAction: TextInputAction.newline, decoration: const InputDecoration(labelText: 'Clinical notes and symptoms')),
    ],
  ));

  List<Widget> _followUpActions(
    BuildContext dialogContext,
    TextEditingController statusController,
    TextEditingController remedyController,
    TextEditingController notesController,
  ) => [
    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
    FilledButton.icon(
      onPressed: () => _saveFollowUp(dialogContext, statusController, remedyController, notesController),
      icon: const Icon(Icons.check),
      label: const Text('Save follow-up'),
    ),
  ];

  Future<void> _saveFollowUp(
    BuildContext dialogContext,
    TextEditingController statusController,
    TextEditingController remedyController,
    TextEditingController notesController,
  ) async {
    final patientId = _patient['_id']?.toString();
    if (patientId == null || patientId.isEmpty) {
      Navigator.pop(dialogContext);
      _showMessage('Cannot log follow-up: patient ID is missing.');
      return;
    }
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    Navigator.pop(dialogContext);
    try {
      final response = await ApiService.post('/follow-ups', {
        'patientId': patientId,
        'progressionStatus': statusController.text,
        'remedyPrescribed': remedyController.text,
        'clinicalNotes': notesController.text,
        'date': dateStr,
        'time': timeStr,
      }, token: _token);
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _fetchFollowUps();
        if (mounted) _showMessage('Follow-Up logged successfully!');
      } else if (mounted) {
        _showMessage('Failed to save follow-up: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (_) {
      final localFu = {
        '_id': 'followup-${now.millisecondsSinceEpoch}',
        'patientId': patientId,
        'progressionStatus': statusController.text,
        'remedyPrescribed': remedyController.text,
        'clinicalNotes': notesController.text,
        'date': dateStr,
        'time': timeStr,
        'createdAt': now.toIso8601String(),
      };
      if (mounted) setState(() => _fetchedFollowUps.insert(0, localFu));
    }
  }

  void _showVisitDetailsModal(
    BuildContext context,
    Map<String, dynamic> visit,
  ) {
    int activeSegment = 0; // 0 = Segment 1: Graph, 1 = Segment 2: Details

    // Build chronological timeline visits array for chart plotting — only real data
    final List<Map<String, dynamic>> timelineVisits = [];
    for (final paper in _papers) {
      final data = paper['data'] is Map ? paper['data'] as Map : paper;
      final date = data['date']?.toString() ?? '';
      final complaint = data['chiefComplaint']?.toString() ?? data['chiefComplaints']?.toString() ?? '';
      final title = data['paperType']?.toString() ?? paper['paperType']?.toString() ?? 'Case Paper';
      String remedy = '';
      if (data['remedy'] != null && data['remedy'].toString().isNotEmpty) {
        remedy = data['remedy'].toString();
      } else if (paper['prescription'] is List && (paper['prescription'] as List).isNotEmpty) {
        final first = (paper['prescription'] as List).first;
        if (first is Map) remedy = '${first['name'] ?? ''} ${first['potency'] ?? ''}'.trim();
      }
      timelineVisits.add({
        'date': date,
        'time': data['time']?.toString() ?? '',
        'title': title,
        'status': 'Baseline Intake',
        'remedy': remedy,
        'isFollowUp': false,
        'chiefComplaint': complaint,
      });
    }
    for (final fu in _fetchedFollowUps) {
      timelineVisits.add({
        'date': fu['date']?.toString() ?? '',
        'time': fu['time']?.toString() ?? '',
        'title': 'Follow-Up Visit',
        'status': fu['progressionStatus']?.toString() ?? '',
        'remedy': fu['remedyPrescribed']?.toString() ?? '',
        'isFollowUp': true,
      });
    }

    // Build gathered case papers list from real data
    final gatheredPapersBullets = _papers.isEmpty
        ? 'No case papers recorded yet.'
        : _papers.map((p) {
            final data = p['data'] is Map ? p['data'] as Map : p;
            final type = data['paperType']?.toString() ?? p['paperType']?.toString() ?? 'Case Paper';
            return '• $type';
          }).join('\n');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final title = visit['title']?.toString() ?? 'Visit Record';
        final date = visit['date']?.toString() ?? '';
        final time = visit['time']?.toString() ?? '';
        final status = visit['status']?.toString() ?? '';
        final remedy = visit['remedy']?.toString() ?? '';

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.directions_railway_filled,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (visit['paperData'] != null)
                            IconButton(
                              tooltip: 'Delete Case Paper',
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                                _deletePaper(visit['paperData'] as Map<String, dynamic>);
                              },
                            ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (date.isNotEmpty)
                    Text(
                      'Recorded on $date${time.isNotEmpty ? " at $time" : ""}',
                      style: TextStyle(color: AppColors.secondary, fontSize: 13),
                    ),
                  const SizedBox(height: 16),

                  // --- Segmented Control Switcher ---
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment<int>(
                        value: 0,
                        icon: Icon(Icons.show_chart_rounded),
                        label: Text('Growth & Recovery Graph'),
                      ),
                      ButtonSegment<int>(
                        value: 1,
                        icon: Icon(Icons.receipt_long_rounded),
                        label: Text('Gathered Details & Notes'),
                      ),
                    ],
                    selected: {activeSegment},
                    onSelectionChanged: (Set<int> newSelection) {
                      setModalState(() {
                        activeSegment = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Segment Page Body ---
                  Expanded(
                    child: SingleChildScrollView(
                      child: activeSegment == 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FollowUpGrowthChart(visits: timelineVisits),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '📊 Progression & Growth Summary:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '• Total visits recorded: ${timelineVisits.length}\n'
                                        '• Current Visit Status: ${status.isNotEmpty ? status : "Recorded"}\n'
                                        '${remedy.isNotEmpty ? "• Prescribed Remedy: $remedy\n" : ""}'
                                        '• Follow-ups logged: ${_fetchedFollowUps.length}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.text,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  elevation: 0,
                                  color: AppColors.primaryLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Gathered Patient Case Papers:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          gatheredPapersBullets,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor: AppColors.primaryLight,
                                    child: Icon(
                                      Icons.trending_up,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  title: const Text('Progression & Growth'),
                                  subtitle: Text(
                                    status.isEmpty ? 'Recorded' : status,
                                  ),
                                ),
                                if (remedy.isNotEmpty) ...[
                                  const Divider(height: 24),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const CircleAvatar(
                                      backgroundColor: AppColors.primaryLight,
                                      child: Icon(
                                        Icons.medication_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    title: const Text('Remedy & Posology Plan'),
                                    subtitle: Text(remedy),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close Follow-Up Record'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _draftAutosaveTimer?.cancel();
    super.dispose();
  }
}

class _DiseasePickerSheet extends StatefulWidget {
  const _DiseasePickerSheet({
    required this.label,
    required this.choices,
    required this.initiallySelected,
  });

  final String label;
  final List<String> choices;
  final Set<String> initiallySelected;

  @override
  State<_DiseasePickerSheet> createState() => _DiseasePickerSheetState();
}

class _DiseasePickerSheetState extends State<_DiseasePickerSheet> {
  final _searchController = TextEditingController();
  late final Set<String> _selected = {...widget.initiallySelected};
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.choices
        .where((item) => item.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final availableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: SizedBox(
        height: availableHeight * 0.82,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    child: const Text('Done'),
                  ),
                ],
              ),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Filter diseases',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return CheckboxListTile(
                      value: _selected.contains(item),
                      title: Text(item),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (checked) => setState(() {
                        if (checked == true) {
                          _selected.add(item);
                        } else {
                          _selected.remove(item);
                        }
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
