import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panacea/components/case_paper_components.dart';
import 'package:panacea/controller/case_paper_controller.dart';
import 'package:panacea/services/case_paper_pdf_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
// CasePaperFormPageContent – entry point (StatelessWidget shell)
// ══════════════════════════════════════════════════════════════════════════════
class CasePaperFormPageContent extends StatelessWidget {
  const CasePaperFormPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CasePaperController>())
      Get.put(CasePaperController());
    final c = Get.find<CasePaperController>();
    final isDesktop = MediaQuery.sizeOf(context).width >= 1100;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Paper 1 – Deep Constitutional Intake'),
        leading: IconButton(
          tooltip: 'Back to case papers',
          onPressed: () =>
              Get.back(result: Map<String, dynamic>.from(c.patient)),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: isDesktop ? _DesktopWorkspace(c: c) : _MobileWorkspace(c: c),
        ),
      ),
      bottomNavigationBar: isDesktop
          ? _DesktopFooter(c: c)
          : _MobileFooter(c: c),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Desktop layout – rail + scrollable content
// ══════════════════════════════════════════════════════════════════════════════
class _DesktopWorkspace extends StatelessWidget {
  const _DesktopWorkspace({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 264, child: _FrameRail(c: c)),
        const VerticalDivider(width: 1),
        Expanded(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 10),
                  child: Text(
                    'Frame ${c.currentFrame.value + 1} of 8 · '
                    '${CasePaperController.frames[c.currentFrame.value]}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: ValueKey('desktop-frame-${c.currentFrame.value}'),
                    padding: const EdgeInsets.fromLTRB(28, 4, 28, 32),
                    child: _FrameBody(c: c, index: c.currentFrame.value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Desktop frame rail
// ──────────────────────────────────────────────────────────────────────────────
class _FrameRail extends StatelessWidget {
  const _FrameRail({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 6),
            child: Obx(
              () => Text(
                '${c.completedFrameCount}/8 frames completed',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Obx(
              () => LinearProgressIndicator(
                value: c.completedFrameCount / 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: CasePaperController.frames.length,
              itemBuilder: (context, i) => Obx(() {
                final done = c.isFrameComplete(i);
                final active = c.currentFrame.value == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 1,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      selected: active,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                      leading: SizedBox(
                        width: 28,
                        child: done
                            ? Icon(
                                Icons.check_circle,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : CircleAvatar(
                                radius: 11,
                                backgroundColor: active
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: active
                                        ? Colors.white
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                      ),
                      title: Text(
                        CasePaperController.frames[i],
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      onTap: () => c.currentFrame.value = i,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Mobile layout – accordion ExpansionTiles
// ══════════════════════════════════════════════════════════════════════════════
class _MobileWorkspace extends StatelessWidget {
  const _MobileWorkspace({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: CasePaperController.frames.length,
      itemBuilder: (context, i) => Obx(
        () => Card(
          key: ValueKey('mobile-frame-${c.editingId}-$i'),
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            key: ValueKey('tile-${c.editingId}-$i'),
            initiallyExpanded: c.currentFrame.value == i,
            onExpansionChanged: (exp) {
              if (exp) c.currentFrame.value = i;
            },
            leading: c.isFrameComplete(i)
                ? const Icon(Icons.check_circle_outline)
                : CircleAvatar(
                    radius: 13,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
            title: Text(
              CasePaperController.frames[i],
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: [_FrameBody(c: c, index: i)],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _FrameBody – routes each index to its frame widget
// ══════════════════════════════════════════════════════════════════════════════
class _FrameBody extends StatelessWidget {
  const _FrameBody({required this.c, required this.index});
  final CasePaperController c;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (index == 5 && !c.isFemale.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Frame 6 is available for female patients. '
                'Update the gender field in Frame 1 to unlock it.',
              ),
            ),
          ],
        ),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            switch (index) {
              0 => _Frame1Demographics(c: c),
              1 => _Frame2Complaints(c: c),
              2 => _Frame3PastHistory(c: c),
              3 => _Frame4Family(c: c),
              4 => _Frame5Generals(c: c),
              5 => _Frame6Female(c: c),
              6 => _Frame7Examination(c: c),
              _ => _Frame8Mentals(c: c),
            },
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared helper widgets
// ══════════════════════════════════════════════════════════════════════════════

/// Text field wired to controller draft via ValueKey – crash-proof
class _DraftField extends StatelessWidget {
  const _DraftField(
    this.c, {
    required this.fieldKey,
    required this.label,
    this.maxLines = 1,
    this.keyboard = TextInputType.text,
    this.hint,
  });

  final CasePaperController c;
  final String fieldKey;
  final String label;
  final int maxLines;
  final TextInputType keyboard;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('${c.editingId}-$fieldKey'),
      initialValue: c.draft[fieldKey]?.toString() ?? '',
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
      onChanged: (v) => c.updateField(fieldKey, v),
    );
  }
}

/// Dropdown wired to draft
class _DraftDropdown extends StatelessWidget {
  const _DraftDropdown(
    this.c, {
    required this.fieldKey,
    required this.label,
    required this.options,
  });

  final CasePaperController c;
  final String fieldKey;
  final String label;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    final val = c.draft[fieldKey]?.toString();
    return DropdownButtonFormField<String>(
      key: ValueKey('${c.editingId}-$fieldKey-dd'),
      isExpanded: true,
      initialValue: options.contains(val) ? val : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: (v) {
        if (v != null) c.updateField(fieldKey, v);
      },
    );
  }
}

/// Date picker field wired to draft
class _DraftDateField extends StatelessWidget {
  const _DraftDateField(this.c, {required this.fieldKey, required this.label});

  final CasePaperController c;
  final String fieldKey;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: () async {
          final initial =
              DateTime.tryParse(c.draft[fieldKey]?.toString() ?? '') ??
              DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            c.updateField(fieldKey, picked.toIso8601String().split('T').first);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_month_outlined),
          ),
          child: Text(
            c.draft[fieldKey]?.toString().isEmpty ?? true
                ? 'Select date'
                : c.draft[fieldKey].toString(),
          ),
        ),
      ),
    );
  }
}

/// Stepper wired to draft
class _DraftStepper extends StatelessWidget {
  const _DraftStepper(this.c, {required this.fieldKey, required this.label});
  final CasePaperController c;
  final String fieldKey;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final val = (c.draft[fieldKey] as num?)?.toInt() ?? 0;
      return InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => c.updateField(fieldKey, (val - 1).clamp(0, 50)),
              child: const Icon(Icons.remove_circle_outline),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '$val',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            InkWell(
              onTap: () => c.updateField(fieldKey, val + 1),
              child: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      );
    });
  }
}

/// Obx-wrapped SegmentedPillToggle wired to draft
class _DraftPillToggle extends StatelessWidget {
  const _DraftPillToggle(
    this.c, {
    required this.fieldKey,
    required this.label,
    required this.options,
  });
  final CasePaperController c;
  final String fieldKey;
  final String label;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SegmentedPillToggle(
        label: label,
        options: options,
        value: c.draft[fieldKey]?.toString() ?? options.first,
        onChanged: (v) => c.updateField(fieldKey, v),
      ),
    );
  }
}

/// Obx-wrapped ChoiceChipGroup wired to draft
class _DraftChipGroup extends StatelessWidget {
  const _DraftChipGroup(
    this.c, {
    required this.fieldKey,
    required this.label,
    required this.options,
    this.multiSelect = true,
    this.dense = false,
  });
  final CasePaperController c;
  final String fieldKey;
  final String label;
  final List<String> options;
  final bool multiSelect;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ChoiceChipGroup(
        label: label,
        options: options,
        selected: c.selectedValues(fieldKey),
        multiSelect: multiSelect,
        dense: dense,
        onChanged: (vals) => c.assignSelection(fieldKey, vals),
      ),
    );
  }
}

/// Obx-wrapped MultiSelectFilterCloud wired to draft
class _DraftFilterCloud extends StatelessWidget {
  const _DraftFilterCloud(
    this.c, {
    required this.fieldKey,
    required this.label,
    required this.options,
    this.icon,
  });
  final CasePaperController c;
  final String fieldKey;
  final String label;
  final List<String> options;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => MultiSelectFilterCloud(
        label: label,
        options: options,
        selected: c.selectedValues(fieldKey),
        icon: icon,
        onChanged: (vals) => c.assignSelection(fieldKey, vals),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FRAME 1 – Demographics & Registry
// ══════════════════════════════════════════════════════════════════════════════
class _Frame1Demographics extends StatelessWidget {
  const _Frame1Demographics({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Encounter Details',
          icon: Icons.event_note_outlined,
          child: ResponsiveGrid(
            minColumnWidth: 220,
            children: [
              _DraftDateField(c, fieldKey: 'date', label: 'Encounter date'),
              _DraftField(c, fieldKey: 'caseId', label: 'Case ID'),
              _DraftField(
                c,
                fieldKey: 'referredBy',
                label: 'Referred by / source',
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Patient Information',
          icon: Icons.person_outline,
          child: ResponsiveGrid(
            minColumnWidth: 220,
            children: [
              _DraftField(c, fieldKey: 'name', label: 'Patient full name'),
              _DraftField(
                c,
                fieldKey: 'age',
                label: 'Age',
                keyboard: TextInputType.number,
              ),
              _DraftDropdown(
                c,
                fieldKey: 'gender',
                label: 'Gender',
                options: const ['Female', 'Male', 'Other'],
              ),
              _DraftField(
                c,
                fieldKey: 'mobile',
                label: 'Mobile number',
                keyboard: TextInputType.phone,
              ),
              _DraftDropdown(
                c,
                fieldKey: 'maritalStatus',
                label: 'Marital status',
                options: const [
                  'Single',
                  'Married',
                  'Separated',
                  'Divorced',
                  'Widowed',
                ],
              ),
              _DraftField(c, fieldKey: 'occupation', label: 'Occupation'),
              _DraftField(
                c,
                fieldKey: 'address',
                label: 'Address',
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FRAME 2 – Chief Complaints & LSMC Causation Journey
// ══════════════════════════════════════════════════════════════════════════════
class _Frame2Complaints extends StatelessWidget {
  const _Frame2Complaints({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Chief Complaint',
          icon: Icons.sick_outlined,
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftField(
                c,
                fieldKey: 'chiefComplaint',
                label: 'Chief complaint and associated trouble',
                maxLines: 3,
                hint: 'Describe the primary complaint in patient\'s words…',
              ),
              const SizedBox(height: 12),
              ResponsiveGrid(
                minColumnWidth: 200,
                children: [
                  _DraftDateField(
                    c,
                    fieldKey: 'onsetDate',
                    label: 'Onset date',
                  ),
                  _DraftField(
                    c,
                    fieldKey: 'onsetDuration',
                    label: 'Duration / since',
                    hint: 'e.g. 3 months, 2 years',
                  ),
                ],
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'LSMC – Location, Sensation, Modality, Concomitant',
          icon: Icons.grid_view_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftFilterCloud(
                c,
                fieldKey: 'locations',
                label: 'Location of complaint',
                options: CasePaperController.locations,
                icon: Icons.place_outlined,
              ),
              const SizedBox(height: 14),
              _DraftChipGroup(
                c,
                fieldKey: 'sensations',
                label: 'Sensations',
                options: CasePaperController.sensations,
                dense: true,
              ),
              const SizedBox(height: 14),
              _DraftChipGroup(
                c,
                fieldKey: 'complaintModalities',
                label: 'Complaint modalities (> ameliorates  <  aggravates)',
                options: CasePaperController.complaintModalities,
                dense: true,
              ),
              const SizedBox(height: 14),
              _DraftChipGroup(
                c,
                fieldKey: 'concomitants',
                label: 'Concomitant symptoms',
                options: CasePaperController.concomitants,
                dense: true,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Causation Journey',
          icon: Icons.timeline_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftChipGroup(
                c,
                fieldKey: 'causationTags',
                label: 'Causation factors (tap all that apply)',
                options: CasePaperController.causationTags,
                dense: true,
              ),
              const SizedBox(height: 14),
              _DraftFilterCloud(
                c,
                fieldKey: 'pastMedicines',
                label: 'Past medication history',
                options: CasePaperController.pastMedicines,
                icon: Icons.medication_outlined,
              ),
              const SizedBox(height: 14),
              _DraftField(
                c,
                fieldKey: 'causationJourneyNotes',
                label: 'Causation journey narrative',
                maxLines: 3,
              ),
            ],
          ),
        ),
        KeynoteCard(
          child: _DraftField(
            c,
            fieldKey: 'primaryKeynote',
            label: 'Doctor peculiarity / keynote observation',
            maxLines: 3,
            hint:
                'Record the clinically striking / peculiar / individualising symptom…',
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FRAME 3 – Past History & CPS Timeline
// ══════════════════════════════════════════════════════════════════════════════
class _Frame3PastHistory extends StatefulWidget {
  const _Frame3PastHistory({required this.c});
  final CasePaperController c;

  @override
  State<_Frame3PastHistory> createState() => _Frame3PastHistoryState();
}

class _Frame3PastHistoryState extends State<_Frame3PastHistory> {
  CasePaperController get c => widget.c;

  Future<void> _addDisease(String disease) async {
    var year = DateTime.now().year;
    var etiology = '';
    var severity = 'Moderate';
    var symptomStatus = 'Recovered';

    final result = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSS) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(ctx).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(disease, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: year,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Year of occurrence',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(80, (i) => DateTime.now().year - i)
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setSS(() => year = v);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: etiology,
                decoration: const InputDecoration(
                  labelText: 'Etiology / cause (optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => etiology = v,
              ),
              const SizedBox(height: 12),
              ChoiceChipGroup(
                label: 'Severity',
                options: const ['Mild', 'Moderate', 'Severe'],
                selected: {severity},
                multiSelect: false,
                onChanged: (vals) {
                  if (vals.isNotEmpty) setSS(() => severity = vals.first);
                },
              ),
              const SizedBox(height: 8),
              ChoiceChipGroup(
                label: 'Current symptom status',
                options: const [
                  'Recovered',
                  'Recurring',
                  'Chronic / persistent',
                ],
                selected: {symptomStatus},
                multiSelect: false,
                onChanged: (vals) {
                  if (vals.isNotEmpty) setSS(() => symptomStatus = vals.first);
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.of(ctx).pop(true),
                icon: const Icon(Icons.add),
                label: const Text('Add to CPS timeline'),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      c.addCpsEntry(
        disease: disease,
        year: year,
        etiology: etiology,
        severity: severity,
        symptomStatus: symptomStatus,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Past Disease Cloud – tap to add to CPS Timeline',
          icon: Icons.history_edu_outlined,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: CasePaperController.pastDiseases.map((disease) {
              return Obx(() {
                final selected = c
                    .selectedValues('pastDiseasesTags')
                    .contains(disease);
                return FilterChip(
                  label: Text(disease),
                  selected: selected,
                  onSelected: (_) => _addDisease(disease),
                );
              });
            }).toList(),
          ),
        ),
        SectionCard(
          title: 'Chronological CPS Timeline',
          icon: Icons.linear_scale_outlined,
          child: Obx(() {
            final entries = c.draft['cpsTimeline'] is List
                ? (c.draft['cpsTimeline'] as List)
                : const [];
            if (entries.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Tap any disease chip above to add it to the timeline.',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              children: entries.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value as Map;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 18,
                      child: Text(
                        '${item['year']}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    title: Text(item['disease']?.toString() ?? ''),
                    subtitle: Text(
                      [
                        item['etiology']?.toString(),
                        item['severity']?.toString(),
                        item['symptomStatus']?.toString(),
                      ].where((s) => s != null && s.isNotEmpty).join(' · '),
                    ),
                    trailing: IconButton(
                      tooltip: 'Remove entry',
                      onPressed: () => c.removeCpsEntry(i),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
        SectionCard(
          title: 'Surgical History & Additional Notes',
          icon: Icons.medication_liquid_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftField(
                c,
                fieldKey: 'surgicalHistory',
                label: 'Surgical / procedural history',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _DraftField(
                c,
                fieldKey: 'pastHistoryNotes',
                label: 'Doctor conclusions & past history notes',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FRAME 4 – Family History & Miasmatic Diathesis
// ══════════════════════════════════════════════════════════════════════════════
class _Frame4Family extends StatelessWidget {
  const _Frame4Family({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Hereditary Disease Tags',
          icon: Icons.family_restroom_outlined,
          child: _DraftChipGroup(
            c,
            fieldKey: 'familyDiseases',
            label: 'Select hereditary conditions present in family',
            options: CasePaperController.familyDiseases,
          ),
        ),
        SectionCard(
          title: 'Family Pedigree',
          icon: Icons.account_tree_outlined,
          child: isDesktop ? _FamilyTable(c: c) : _FamilyList(c: c),
        ),
        SectionCard(
          title: 'Miasmatic Diathesis',
          icon: Icons.biotech_outlined,
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftChipGroup(
                c,
                fieldKey: 'miasm',
                label: 'Dominant miasm (select one or more)',
                options: CasePaperController.miasms,
                multiSelect: true,
              ),
              const SizedBox(height: 12),
              _DraftField(
                c,
                fieldKey: 'miasmNotes',
                label: 'Miasmatic analysis notes',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FamilyTable extends StatelessWidget {
  const _FamilyTable({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
        () => DataTable(
          columnSpacing: 12,
          columns: const [
            DataColumn(label: Text('Relation')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Age')),
            DataColumn(label: Text('Hereditary diseases')),
          ],
          rows: CasePaperController.relatives.map((rel) {
            final item = c.draft['relativeHistory'] is Map
                ? (c.draft['relativeHistory'] as Map)[rel] as Map? ?? const {}
                : const {};
            return DataRow(
              cells: [
                DataCell(SizedBox(width: 160, child: Text(rel))),
                DataCell(
                  SizedBox(
                    width: 160,
                    child: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: 'Alive', label: Text('Alive')),
                        ButtonSegment(value: 'Dead', label: Text('Dead')),
                      ],
                      selected: {item['status']?.toString() ?? 'Alive'},
                      onSelectionChanged: (s) =>
                          c.updateRelative(rel, 'status', s.first),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      key: ValueKey('${c.editingId}-rel-age-$rel'),
                      initialValue: item['age']?.toString() ?? '',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => c.updateRelative(rel, 'age', v),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 460,
                    child: ChoiceChipGroup(
                      label: '',
                      options: CasePaperController.familyDiseases,
                      selected: _diseases(item),
                      dense: true,
                      onChanged: (vals) =>
                          c.updateRelative(rel, 'diseases', vals.toList()),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Set<String> _diseases(Map item) => item['diseases'] is Iterable
      ? (item['diseases'] as Iterable).map((e) => e.toString()).toSet()
      : <String>{};
}

class _FamilyList extends StatelessWidget {
  const _FamilyList({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: CasePaperController.relatives.map((rel) {
          final item = c.draft['relativeHistory'] is Map
              ? (c.draft['relativeHistory'] as Map)[rel] as Map? ?? const {}
              : const {};
          final diseases = item['diseases'] is Iterable
              ? (item['diseases'] as Iterable).map((e) => e.toString()).toSet()
              : <String>{};
          return ExpansionTile(
            key: ValueKey('${c.editingId}-rel-$rel'),
            title: Text(rel, style: const TextStyle(fontSize: 13)),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Status',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'Alive', label: Text('Alive')),
                      ButtonSegment(value: 'Dead', label: Text('Dead')),
                    ],
                    selected: {item['status']?.toString() ?? 'Alive'},
                    onSelectionChanged: (s) =>
                        c.updateRelative(rel, 'status', s.first),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: ValueKey('${c.editingId}-rel-age-mob-$rel'),
                initialValue: item['age']?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => c.updateRelative(rel, 'age', v),
              ),
              const SizedBox(height: 8),
              ChoiceChipGroup(
                label: 'Diseases',
                options: CasePaperController.familyDiseases,
                selected: diseases,
                dense: true,
                onChanged: (vals) =>
                    c.updateRelative(rel, 'diseases', vals.toList()),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FRAME 5 – Physical Generals & Dream Analysis
// ══════════════════════════════════════════════════════════════════════════════
class _Frame5Generals extends StatelessWidget {
  const _Frame5Generals({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Food Preferences',
          icon: Icons.restaurant_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftChipGroup(
                c,
                fieldKey: 'foodDesires',
                label: 'Food desires & cravings',
                options: CasePaperController.foodItems,
                dense: true,
              ),
              const SizedBox(height: 12),
              _DraftChipGroup(
                c,
                fieldKey: 'foodAversions',
                label: 'Food aversions',
                options: CasePaperController.foodItems,
                dense: true,
              ),
              const SizedBox(height: 12),
              _DraftChipGroup(
                c,
                fieldKey: 'foodAggravations',
                label: 'Food aggravations (complaints after eating)',
                options: CasePaperController.foodItems,
                dense: true,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Thermals, Thirst & Perspiration',
          icon: Icons.thermostat_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftPillToggle(
                c,
                fieldKey: 'thermal',
                label: 'Thermal preference',
                options: const ['Chilly', 'Hot', 'Ambi-thermal'],
              ),
              const SizedBox(height: 12),
              _DraftPillToggle(
                c,
                fieldKey: 'thirst',
                label: 'Thirst',
                options: const [
                  'Large quantities',
                  'Small quantities',
                  'Thirstless',
                  'Frequent',
                  'Infrequent',
                ],
              ),
              const SizedBox(height: 12),
              _DraftPillToggle(
                c,
                fieldKey: 'waterTemperature',
                label: 'Preferred water temperature',
                options: const ['Ice-cold', 'Cold', 'Normal', 'Warm / hot'],
              ),
              const SizedBox(height: 16),
              Obx(() {
                final intensity =
                    (c.draft['sweatIntensity'] as num?)?.toInt() ?? 1;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sweat intensity: ${['Scanty', 'Moderate', 'Profuse'][intensity.clamp(0, 2)]}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Slider(
                      value: intensity.toDouble(),
                      min: 0,
                      max: 2,
                      divisions: 2,
                      label: [
                        'Scanty',
                        'Moderate',
                        'Profuse',
                      ][intensity.clamp(0, 2)],
                      onChanged: (v) =>
                          c.updateField('sweatIntensity', v.round()),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              _DraftChipGroup(
                c,
                fieldKey: 'sweatTraits',
                label: 'Sweat characteristics',
                options: CasePaperController.sweatTraits,
                dense: true,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Bowels, Stool & Urine',
          icon: Icons.monitor_heart_outlined,
          child: _DraftChipGroup(
            c,
            fieldKey: 'stoolUrineTags',
            label: '',
            options: CasePaperController.stoolUrineTags,
            dense: true,
          ),
        ),
        SectionCard(
          title: 'Environmental Modalities Matrix',
          icon: Icons.wb_sunny_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: CasePaperController.modalityStimuli.map((stimulus) {
              return Obx(
                () => ModalityMatrixRow(
                  key: ValueKey('mod-$stimulus'),
                  stimulus: stimulus,
                  value: c.modalityFor(stimulus),
                  onChanged: (v) => c.setModality(stimulus, v),
                ),
              );
            }).toList(),
          ),
        ),
        SectionCard(
          title: 'Dream Analysis Matrix',
          icon: Icons.nights_stay_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: CasePaperController.dreamGroups.entries.map((group) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _DraftChipGroup(
                  c,
                  fieldKey: 'dreamTags',
                  label: group.key,
                  options: group.value,
                  dense: true,
                ),
              );
            }).toList(),
          ),
        ),
        SectionCard(
          title: 'General Notes',
          icon: Icons.notes_outlined,
          child: _DraftField(
            c,
            fieldKey: 'generalsNotes',
            label: 'Physical generals – doctor notes',
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FRAME 6 – Female Lifecycle & Hormonal Transitions
// ══════════════════════════════════════════════════════════════════════════════
class _Frame6Female extends StatelessWidget {
  const _Frame6Female({required this.c});
  final CasePaperController c;

  static const _menstrualSymptoms = [
    'Headache',
    'Migraine',
    'Mood swings / irritability',
    'Anxiety / depression',
    'Breast tenderness',
    'Bloating',
    'Back pain',
    'Cramps',
    'Nausea / vomiting',
    'Diarrhoea',
    'Constipation',
    'Increased appetite',
    'Fatigue / weakness',
    'Sleep disturbance',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Menarche & Cycle Parameters',
          icon: Icons.calendar_view_month_outlined,
          child: ResponsiveGrid(
            minColumnWidth: 200,
            children: [
              _DraftField(
                c,
                fieldKey: 'menarcheAge',
                label: 'Age at menarche',
                keyboard: TextInputType.number,
              ),
              _DraftField(
                c,
                fieldKey: 'cycleDays',
                label: 'Cycle interval (days)',
                keyboard: TextInputType.number,
              ),
              _DraftField(
                c,
                fieldKey: 'cyclePeriodDays',
                label: 'Duration of flow (days)',
                keyboard: TextInputType.number,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Cycle Rhythm & Flow Character',
          icon: Icons.water_drop_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftPillToggle(
                c,
                fieldKey: 'cycleRhythm',
                label: 'Cycle rhythm',
                options: const [
                  'Regular',
                  'Irregular',
                  'Scanty',
                  'Suppressed',
                  'Amenorrhoea',
                ],
              ),
              const SizedBox(height: 12),
              _DraftChipGroup(
                c,
                fieldKey: 'flowCharacter',
                label: 'Flow character (select all that apply)',
                options: const [
                  'Scanty',
                  'Normal',
                  'Heavy / flooding',
                  'Clotted',
                  'Dark',
                  'Pale / watery',
                  'Staining',
                  'Offensive odor',
                  'Painless',
                  'Dysmenorrhoea',
                ],
                dense: true,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Associated Complaints by Cycle Phase',
          icon: Icons.timeline_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Expanded(flex: 3, child: Text('Symptom')),
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: ['Before', 'During', 'After']
                            .map(
                              (label) => Expanded(
                                child: Center(
                                  child: Text(
                                    label,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              ..._menstrualSymptoms.map((symptom) {
                return Obx(() {
                  final current = c.menstrualTimingFor(symptom);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            symptom,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: ['Before', 'During', 'After'].map((
                              phase,
                            ) {
                              final active = current == phase;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => c.setMenstrualTiming(
                                    symptom,
                                    active ? '' : phase,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primaryContainer
                                          : Theme.of(
                                              context,
                                            ).colorScheme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: active
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        phase,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: active
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: active
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              }),
            ],
          ),
        ),
        SectionCard(
          title: 'Leucorrhoea',
          icon: Icons.opacity_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftChipGroup(
                c,
                fieldKey: 'leucorrhoeaColor',
                label: 'Color / appearance',
                options: const [
                  'White',
                  'Yellow',
                  'Green',
                  'Bloody',
                  'Watery',
                  'Thick / ropy',
                ],
                dense: true,
              ),
              const SizedBox(height: 10),
              _DraftChipGroup(
                c,
                fieldKey: 'leucorrhoeaTraits',
                label: 'Associated traits',
                options: const [
                  'Stains linen',
                  'Itching / burning',
                  'Offensive odor',
                  'Excoriating',
                  'Acrid',
                  'Non-offensive',
                  'Copious',
                  'Scanty',
                ],
                dense: true,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Obstetric & Hormonal History',
          icon: Icons.child_care_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResponsiveGrid(
                minColumnWidth: 150,
                children: [
                  _DraftStepper(
                    c,
                    fieldKey: 'pregnancies',
                    label: 'Pregnancies',
                  ),
                  _DraftStepper(
                    c,
                    fieldKey: 'liveChildren',
                    label: 'Live children',
                  ),
                  _DraftStepper(c, fieldKey: 'abortions', label: 'Abortions'),
                  _DraftStepper(c, fieldKey: 'dnc', label: 'D&C'),
                  _DraftStepper(
                    c,
                    fieldKey: 'lactationMonths',
                    label: 'Lactation (months)',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DraftPillToggle(
                c,
                fieldKey: 'ocpUse',
                label: 'Oral contraceptive pill (OCP) use',
                options: const ['Never', 'Past', 'Current'],
              ),
              const SizedBox(height: 12),
              _DraftField(
                c,
                fieldKey: 'obstetricNotes',
                label: 'Obstetric / hormonal notes',
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FRAME 7 – Objective Examination & Physical Findings
// ══════════════════════════════════════════════════════════════════════════════
class _Frame7Examination extends StatelessWidget {
  const _Frame7Examination({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Vitals',
          icon: Icons.monitor_heart_outlined,
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResponsiveGrid(
                minColumnWidth: 180,
                children: [
                  _DraftField(
                    c,
                    fieldKey: 'pulse',
                    label: 'Pulse (per min)',
                    keyboard: TextInputType.number,
                  ),
                  _DraftField(
                    c,
                    fieldKey: 'bloodPressure',
                    label: 'Blood pressure',
                    hint: 'e.g. 120/80',
                  ),
                  _DraftField(
                    c,
                    fieldKey: 'respiratoryRate',
                    label: 'Respiratory rate',
                    keyboard: TextInputType.number,
                  ),
                  _DraftField(
                    c,
                    fieldKey: 'temperature',
                    label: 'Temperature (°F)',
                    keyboard: TextInputType.number,
                  ),
                  _DraftField(
                    c,
                    fieldKey: 'weight',
                    label: 'Weight (kg)',
                    keyboard: TextInputType.number,
                  ),
                  _DraftField(
                    c,
                    fieldKey: 'height',
                    label: 'Height (cm)',
                    keyboard: TextInputType.number,
                  ),
                  Obx(
                    () => InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'BMI (auto-calculated)',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        c.bmi != null
                            ? '${c.bmi!.toStringAsFixed(1)} kg/m²'
                            : 'Enter weight & height',
                        style: c.bmi != null
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Quick Inspection Tags',
          icon: Icons.search_outlined,
          child: _DraftFilterCloud(
            c,
            fieldKey: 'inspectionTags',
            label: 'Tap to select inspection findings',
            options: CasePaperController.inspectionTags,
            icon: Icons.visibility_outlined,
          ),
        ),
        SectionCard(
          title: 'Systemic Examination',
          icon: Icons.medical_information_outlined,
          child: ResponsiveGrid(
            minColumnWidth: 200,
            children: [
              _DraftField(c, fieldKey: 'eyes', label: 'Eyes'),
              _DraftField(c, fieldKey: 'ears', label: 'Ears'),
              _DraftField(c, fieldKey: 'nose', label: 'Nose'),
              _DraftField(c, fieldKey: 'throat', label: 'Throat / tonsils'),
              _DraftField(
                c,
                fieldKey: 'respiratory',
                label: 'Respiratory / chest',
              ),
              _DraftField(c, fieldKey: 'cvs', label: 'CVS / heart'),
              _DraftField(c, fieldKey: 'git', label: 'GIT / abdomen'),
              _DraftField(c, fieldKey: 'cns', label: 'CNS / neurological'),
            ],
          ),
        ),
        SectionCard(
          title: 'Objective Peculiarities & Findings',
          icon: Icons.lightbulb_outlined,
          child: _DraftField(
            c,
            fieldKey: 'objectiveFindings',
            label: 'Objective examination peculiarities (doctor notes)',
            maxLines: 4,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FRAME 8 – Mentals, Repertorial Synthesis & Prescription
// ══════════════════════════════════════════════════════════════════════════════
class _Frame8Mentals extends StatelessWidget {
  const _Frame8Mentals({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Mental Attributes & Disposition',
          icon: Icons.psychology_outlined,
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftChipGroup(
                c,
                fieldKey: 'mentalTags',
                label: 'Tap to select matching mental rubrics',
                options: CasePaperController.mentalRubrics,
              ),
              const SizedBox(height: 12),
              _DraftField(
                c,
                fieldKey: 'mentalNotes',
                label: 'Doctor mental notes / peculiarities',
                maxLines: 3,
                hint: 'Describe the peculiar / striking mental symptoms…',
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Repertory Rubrics',
          icon: Icons.menu_book_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftFilterCloud(
                c,
                fieldKey: 'rubrics',
                label: 'Selected repertory rubrics',
                options: CasePaperController.repertorialRubrics,
                icon: Icons.search_outlined,
              ),
              const SizedBox(height: 12),
              _DraftField(
                c,
                fieldKey: 'repertorizationNotes',
                label: 'Repertorization / case analysis notes',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _DraftField(
                c,
                fieldKey: 'remedyDifferential',
                label: 'Remedy differential / totality summary',
                maxLines: 3,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Prescription',
          icon: Icons.medication_outlined,
          child: Obx(() {
            final entries = c.medicineEntries;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...entries.asMap().entries.map(
                  (e) => _MedicineRow(c: c, index: e.key),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: c.addMedicine,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add medicine'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        SectionCard(
          title: 'Follow-up & Doctor Conclusion',
          icon: Icons.event_available_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftDateField(
                c,
                fieldKey: 'followUpDate',
                label: 'Follow-up date',
              ),
              const SizedBox(height: 12),
              _DraftField(
                c,
                fieldKey: 'followUpNotes',
                label: 'Follow-up instructions',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _DraftField(
                c,
                fieldKey: 'doctorConclusion',
                label: 'Doctor conclusion / final analysis',
                maxLines: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MedicineRow extends StatelessWidget {
  const _MedicineRow({required this.c, required this.index});
  final CasePaperController c;
  final int index;

  @override
  Widget build(BuildContext context) {
    final medicine = c.medicineEntries[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Medicine ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Remove medicine',
                  onPressed: () => c.removeMedicine(index),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Medicine autocomplete
            _MedicineAutocomplete(c: c, index: index, medicine: medicine),
            const SizedBox(height: 10),
            // Potency chips
            ChoiceChipGroup(
              label: 'Potency',
              options: CasePaperController.potencies,
              selected: {medicine['potency']?.toString() ?? '30C'},
              multiSelect: false,
              dense: true,
              onChanged: (vals) {
                if (vals.isNotEmpty)
                  c.updateMedicine(index, 'potency', vals.first);
              },
            ),
            const SizedBox(height: 10),
            ResponsiveGrid(
              minColumnWidth: 180,
              children: [
                _medicineDropdown(
                  context,
                  c,
                  index,
                  'dose',
                  'Dose form',
                  CasePaperController.doseTypes,
                  medicine['dose']?.toString(),
                ),
                _medicineDropdown(
                  context,
                  c,
                  index,
                  'frequency',
                  'Frequency',
                  CasePaperController.frequencies,
                  medicine['frequency']?.toString(),
                ),
                TextFormField(
                  key: ValueKey('${c.editingId}-med-dur-$index'),
                  initialValue: medicine['duration']?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    hintText: 'e.g. 15 days',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => c.updateMedicine(index, 'duration', v),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: ValueKey('${c.editingId}-med-notes-$index'),
              initialValue: medicine['notes']?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Prescription notes (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => c.updateMedicine(index, 'notes', v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicineDropdown(
    BuildContext context,
    CasePaperController c,
    int index,
    String key,
    String label,
    List<String> options,
    String? currentValue,
  ) {
    final val = options.contains(currentValue) ? currentValue : options.first;
    return DropdownButtonFormField<String>(
      key: ValueKey('${c.editingId}-med-$key-$index'),
      isExpanded: true,
      initialValue: val,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: (v) {
        if (v != null) c.updateMedicine(index, key, v);
      },
    );
  }
}

class _MedicineAutocomplete extends StatelessWidget {
  const _MedicineAutocomplete({
    required this.c,
    required this.index,
    required this.medicine,
  });
  final CasePaperController c;
  final int index;
  final Map<String, dynamic> medicine;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      key: ValueKey('${c.editingId}-med-name-$index'),
      initialValue: TextEditingValue(text: medicine['name']?.toString() ?? ''),
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return const [];
        final q = textEditingValue.text.toLowerCase();
        return CasePaperController.remedies
            .where((r) => r.toLowerCase().contains(q))
            .take(8);
      },
      fieldViewBuilder: (ctx, controller, focusNode, onSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Medicine / remedy name',
            hintText: 'Type to search…',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => c.updateMedicine(index, 'name', v),
          onFieldSubmitted: (_) => onSubmitted(),
        );
      },
      onSelected: (v) => c.updateMedicine(index, 'name', v),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Desktop Footer
// ══════════════════════════════════════════════════════════════════════════════
class _DesktopFooter extends StatelessWidget {
  const _DesktopFooter({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final statusText = c.autosaveStatus.value;
      final saving = c.isSaving.value;
      return SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1140),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    saving
                        ? Icons.cloud_upload_outlined
                        : Icons.cloud_done_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _SwitchPaperMenu(c: c),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: saving ? null : () => _saveDraft(context, c),
                    icon: saving
                        ? const SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined, size: 16),
                    label: Text(saving ? 'Saving…' : 'Save Draft'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: saving ? null : () => _exportPdf(context, c),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                    label: const Text('Export PDF'),
                    style: FilledButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Mobile Footer
// ══════════════════════════════════════════════════════════════════════════════
class _MobileFooter extends StatelessWidget {
  const _MobileFooter({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final saving = c.isSaving.value;
      final frame = c.currentFrame.value;
      return SafeArea(
        top: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              IconButton(
                tooltip: 'Previous frame',
                onPressed: frame == 0 ? null : () => c.currentFrame.value--,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${frame + 1}/8 · ${c.autosaveStatus.value}',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next frame',
                onPressed: frame == 7 ? null : () => c.currentFrame.value++,
                icon: const Icon(Icons.chevron_right),
              ),
              IconButton(
                tooltip: 'Save Draft',
                onPressed: saving ? null : () => _saveDraft(context, c),
                icon: saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Switch paper popup menu
// ──────────────────────────────────────────────────────────────────────────────
class _SwitchPaperMenu extends StatelessWidget {
  const _SwitchPaperMenu({required this.c});
  final CasePaperController c;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Switch case paper',
      onSelected: (value) {
        if (value == '__new__') {
          c.switchToPaper(null);
          return;
        }
        final match = c.papers.where(
          (p) => (p['caseId'] ?? p['_id']).toString() == value,
        );
        if (match.isNotEmpty) c.switchToPaper(match.first);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: '__new__', child: Text('New Case Paper 1')),
        ...c.papers.map(
          (p) => PopupMenuItem(
            value: (p['caseId'] ?? p['_id']).toString(),
            child: Text(
              'Case Paper 1 · ${(p['data'] as Map?)?['date'] ?? 'Undated'}',
            ),
          ),
        ),
      ],
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.swap_horiz, size: 16),
        label: const Text('Switch Paper'),
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Action helpers (free functions)
// ──────────────────────────────────────────────────────────────────────────────
Future<void> _saveDraft(BuildContext context, CasePaperController c) async {
  final saved = await c.saveToPatient();
  if (saved) Get.back(result: Map<String, dynamic>.from(c.patient));
}

Future<void> _exportPdf(BuildContext context, CasePaperController c) async {
  final saved = await c.saveToPatient(showFeedback: false);
  if (!saved) return;
  try {
    final data = Map<String, dynamic>.from(c.draft)
      ..['prescriptionMedicines'] = c.medicineEntries
          .map(Map<String, dynamic>.from)
          .toList();
    await CasePaperPdfService.generateAndPrint(
      patientName:
          c.patient['name']?.toString() ??
          data['name']?.toString() ??
          'Patient',
      caseData: data,
    );
    Get.snackbar('PDF ready', 'Detailed case paper PDF generated.');
  } catch (e) {
    Get.snackbar('PDF failed', e.toString());
  }
}
