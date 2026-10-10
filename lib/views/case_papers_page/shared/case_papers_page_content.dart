import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panacea/controller/auth_session.dart';
import 'package:panacea/constants/app_routes.dart';
import 'package:panacea/services/api_service.dart';
import 'package:panacea/services/case_paper_pdf_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Map<String, dynamic> _draft = {};
  int _openFrame = 0;
  bool _isSaving = false;
  bool _isNewDraft = false;
  String _draftSaveStatus = 'Draft not saved';
  Timer? _draftAutosaveTimer;

  String get _newDraftStorageKey =>
      'panacea.casePaperDraft.${_patient['_id'] ?? 'unknown'}.new';

  String _existingDraftStorageKey(String caseId) =>
      'panacea.casePaperDraft.${_patient['_id'] ?? 'unknown'}.$caseId';

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
  }

  List<Map<String, dynamic>> get _papers {
    final papers = _patient['casePapers'];
    if (papers is! List) return [];
    return papers.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  Future<void> _startNewPaper() async {
    final savedPatient = await Get.toNamed(
      AppRoutes.casePaperForm,
      arguments: {'token': _token, 'patient': _patient, 'startNew': true},
    );
    if (!mounted || savedPatient is! Map) return;
    setState(() => _patient = Map<String, dynamic>.from(savedPatient));
  }

  Future<void> _editPaper(Map<String, dynamic> paper) async {
    final savedPatient = await Get.toNamed(
      AppRoutes.casePaperForm,
      arguments: {'token': _token, 'patient': _patient, 'paper': paper},
    );
    if (!mounted || savedPatient is! Map) return;
    setState(() => _patient = Map<String, dynamic>.from(savedPatient));
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
    final patientSummary = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _patient['name']?.toString() ?? 'Patient',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text('${_papers.length} case paper${_papers.length == 1 ? '' : 's'}'),
      ],
    );
    final newPaperButton = FilledButton.icon(
      onPressed: _startNewPaper,
      icon: const Icon(Icons.add),
      label: const Text('New Case Paper 1'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [patientSummary, newPaperButton],
        ),
        const SizedBox(height: 20),
        if (_papers.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: Text('No case papers for this patient yet.')),
          ),
        ..._papers.map((paper) {
          final data = paper['data'] is Map ? paper['data'] as Map : const {};
          final date = data['date']?.toString() ?? 'Date not set';
          final caseId = data['caseId']?.toString();
          final complaint = data['chiefComplaint']?.toString() ?? '';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: Text('Case Paper 1  •  $date'),
              subtitle: Text(
                [
                  if (caseId?.isNotEmpty == true) 'ID: $caseId',
                  if (complaint.isNotEmpty) complaint,
                ].join('  •  '),
              ),
              isThreeLine: caseId?.isNotEmpty == true && complaint.isNotEmpty,
              onTap: () => _editPaper(paper),
              trailing: PopupMenuButton<String>(
                tooltip: 'Case paper actions',
                onSelected: (action) {
                  if (action == 'edit') _editPaper(paper);
                  if (action == 'delete') _deletePaper(paper);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit paper')),
                  PopupMenuItem(value: 'delete', child: Text('Delete paper')),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEditor() {
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
                'Case Paper 1',
                style: Theme.of(context).textTheme.headlineSmall,
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
                  'Case Paper 1',
                  style: Theme.of(context).textTheme.titleLarge,
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
      if (showFeedback) _showMessage('Case Paper 1 saved.');
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
        const PopupMenuItem(value: '__new__', child: Text('New Case Paper 1')),
        if (_papers.isNotEmpty) const PopupMenuDivider(),
        ..._papers.map((paper) {
          final caseId = (paper['caseId'] ?? paper['_id']).toString();
          final data = paper['data'] is Map ? paper['data'] as Map : const {};
          final date = data['date']?.toString() ?? 'Undated';
          return PopupMenuItem(
            value: caseId,
            child: Text('Case Paper 1 · $date'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete case paper?'),
        content: const Text(
          'This case paper will be removed from the patient record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final papers = _papers
      ..removeWhere(
        (item) => item['caseId']?.toString() == paper['caseId']?.toString(),
      );
    try {
      await _persistPapers(papers);
      _showMessage('Case paper deleted.');
    } catch (error) {
      _showMessage(
        'Could not delete case paper: ${error.toString().replaceFirst('Exception: ', '')}',
      );
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
    final isDesktop = viewportWidth >= 1100;
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
