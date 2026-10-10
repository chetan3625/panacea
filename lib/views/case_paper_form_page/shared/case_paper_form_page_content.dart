import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/case_paper_controller.dart';
import '../../../components/case_paper_components.dart';
import '../../../components/common_components.dart';

class CasePaperFormPageContent extends StatelessWidget {
  final bool isCompact;

  const CasePaperFormPageContent({super.key, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CasePaperController>();
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildFrameCard(
              title: '1. Demographics & Registry',
              initiallyExpanded: true,
              children: [
                _buildResponsiveRow([
                  Expanded(
                    child: CustomTextField(
                      controller: controller.occupationController,
                      label: 'Occupation',
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: controller.maritalStatusController,
                      label: 'Marital Status',
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.referredByController,
                  label: 'Referred To Us By',
                ),
              ],
            ),

            _buildFrameCard(
              title: '2. Chief Complaints & Causation (LSMC)',
              children: [
                CustomTextField(
                  controller: controller.chiefComplaintsController,
                  label: 'Chief Complaints & Associated Troubles',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.causationJourneyController,
                  label: 'Journey & Cause (Emotions, Intrinsic, Extrinsic)',
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                MultiSelectChipGroup(
                  title: 'Endocrinal Interventions / Transitions',
                  options: const [
                    'Developmental Delays',
                    'Puberty',
                    'Menarche',
                    'Pregnancy',
                    'Menopause',
                    'OC Pills',
                  ],
                  selectedItems: controller.selectedEndocrinalInterventions,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.historyOfMedicinesController,
                  label: 'History of Medicines Taken',
                  maxLines: 2,
                ),
              ],
            ),

            _buildFrameCard(
              title: '3. Past Medical History (CPS Timeline)',
              children: [
                MultiSelectChipGroup(
                  title: 'Select Diseases Suffered (Creates Timeline Below)',
                  options: controller.pastDiseaseOptions,
                  selectedItems: controller.pastDiseases,
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.pastDiseases.isEmpty)
                    return const SizedBox.shrink();
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.pastDiseases.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final disease = controller.pastDiseases[index];
                        return ListTile(
                          title: Text(
                            disease,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: _buildResponsiveRow([
                              Expanded(
                                child: CustomTextField(
                                  label: 'Year',
                                  isNumber: true,
                                ),
                              ),
                              Expanded(child: CustomTextField(label: 'Cause')),
                              Expanded(
                                child: CustomTextField(label: 'Symptoms'),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),

            _buildFrameCard(
              title: '4. Family History & Miasm',
              children: [
                Text(
                  'Family Diathesis Matrix',
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.familyHistoryMatrix.keys.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final relation = controller.familyHistoryMatrix.keys
                          .elementAt(index);
                      final selectedDiseases =
                          controller.familyHistoryMatrix[relation]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            relation,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          MultiSelectChipGroup(
                            title: '',
                            options: const [
                              'Cancer',
                              'DM',
                              'RA',
                              'TB',
                              'Asthma',
                              'HTN',
                              'Heart Trouble',
                              'Kidney Disease',
                            ],
                            selectedItems: selectedDiseases,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Divider(height: 48),
                SegmentedToggleGroup(
                  title: 'Miasmatic Background',
                  options: controller.miasmOptions,
                  selectedValue: controller.selectedMiasm,
                ),
              ],
            ),

            _buildFrameCard(
              title: '5. Physical Generals & Dreams',
              children: [
                SegmentedToggleGroup(
                  title: 'Thermals',
                  options: const ['Chilly', 'Ambi-thermal', 'Hot'],
                  selectedValue: controller.selectedThermals,
                ),
                const SizedBox(height: 24),
                _buildResponsiveRow([
                  Expanded(
                    child: SegmentedToggleGroup(
                      title: 'Thirst',
                      options: const [
                        'Normal',
                        'Thirstless',
                        'Large Quantities',
                      ],
                      selectedValue: controller.selectedThirst,
                    ),
                  ),
                  Expanded(
                    child: SegmentedToggleGroup(
                      title: 'Water Temp',
                      options: const ['Normal', 'Cold', 'Warm'],
                      selectedValue: controller.selectedThirstTemp,
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                MultiSelectChipGroup(
                  title: 'Bowel & Urine Traits',
                  options: const [
                    'Constipation',
                    'Diarrhoea',
                    'Bleeding',
                    'Piles',
                    'Fissure',
                    'Urgency',
                    'Offensive Smell',
                    'Burning Urine',
                  ],
                  selectedItems: controller.bowelUrineTraits,
                ),
                const Divider(height: 48),
                Text(
                  'Modalities (Factors Affecting)',
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...controller.modalities.keys.map(
                  (key) => ModalityMatrixRow(
                    label: key,
                    stateValue: controller.modalities[key]!,
                  ),
                ),
                const Divider(height: 48),
                MultiSelectChipGroup(
                  title: 'Dream Analysis',
                  options: controller.dreamOptions,
                  selectedItems: controller.dreamCategories,
                ),
              ],
            ),

            _buildFrameCard(
              title: '6. Female History (Conditional)',
              children: [
                _buildResponsiveRow([
                  Expanded(
                    child: CustomTextField(
                      controller: controller.menarcheAgeController,
                      label: 'Menarche Age',
                      isNumber: true,
                    ),
                  ),
                  Expanded(
                    child: SegmentedToggleGroup(
                      title: 'Cycle Rhythm',
                      options: const ['Regular', 'Irregular'],
                      selectedValue: controller.isCycleRegular,
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                SegmentedToggleGroup(
                  title: 'Character of Flow',
                  options: const [
                    'Scanty',
                    'Normal',
                    'Heavy',
                    'Clotted',
                    'Dark',
                  ],
                  selectedValue: controller.menstrualFlow,
                ),
                const SizedBox(height: 24),
                MultiSelectChipGroup(
                  title: 'Menses Concomitants',
                  options: const [
                    'Breast Pain',
                    'Cravings',
                    'Mood Swings',
                    'Thirst',
                    'GI Upset',
                    'Skin Eruptions',
                  ],
                  selectedItems: controller.mensesConcomitants,
                ),
                const SizedBox(height: 24),
                MultiSelectChipGroup(
                  title: 'Leucorrhoea Profile',
                  options: const [
                    'Bland',
                    'Acrid',
                    'Staining',
                    'Offensive Odour',
                    'Itching',
                  ],
                  selectedItems: controller.leucorrhoeaTags,
                ),
              ],
            ),

            _buildFrameCard(
              title: '7. Examination Findings',
              children: [
                _buildResponsiveRow([
                  Expanded(
                    child: CustomTextField(
                      controller: controller.bpController,
                      label: 'Blood Pressure',
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: controller.pulseController,
                      label: 'Pulse',
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildResponsiveRow([
                  Expanded(
                    child: CustomTextField(
                      controller: controller.weightController,
                      label: 'Weight (kg)',
                      isNumber: true,
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: controller.heightController,
                      label: 'Height (cm)',
                      isNumber: true,
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                MultiSelectChipGroup(
                  title: 'Objective Inspection',
                  options: const [
                    'Coated Tongue',
                    'Map Tongue',
                    'Flabby Tongue',
                    'Dry Skin',
                    'Brittle Nails',
                    'Enlarged Lymph Nodes',
                  ],
                  selectedItems: controller.objectiveInspectionTags,
                ),
              ],
            ),

            _buildFrameCard(
              title: '8. Mentals, Rubrics & Prescription',
              children: [
                MultiSelectChipGroup(
                  title: 'Mental Dispositions & Reactions',
                  options: controller.mentalOptions,
                  selectedItems: controller.mentalRubrics,
                ),
                const Divider(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prescription Formulation',
                      style: textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: controller.addMedicine,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Medicine'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.prescribedMedicines.length,
                    itemBuilder: (context, index) {
                      final med = controller.prescribedMedicines[index];
                      return Padding(
                        key: ValueKey(med['id']),
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildResponsiveRow([
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: med['name'],
                              decoration: const InputDecoration(
                                labelText: 'Medicine',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) =>
                                  controller.updateMedicine(index, 'name', val),
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Potency',
                                border: OutlineInputBorder(),
                              ),
                              value: med['potency'],
                              items: ['30C', '200C', '1M', '10M', 'LM']
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) => controller.updateMedicine(
                                index,
                                'potency',
                                val ?? '30C',
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: med['dosage'],
                              decoration: const InputDecoration(
                                labelText: 'Dosage',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) => controller.updateMedicine(
                                index,
                                'dosage',
                                val,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => controller.removeMedicine(index),
                          ),
                        ]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: controller.prescriptionNotesController,
                  label: 'Doctor Conclusions & Follow-up Notes',
                  maxLines: 4,
                ),
              ],
            ),

            const SizedBox(height: 40),
            _buildActionButtons(controller),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameCard({
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      elevation: 0,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        childrenPadding: const EdgeInsets.all(20),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
            children.expand((w) => [w, const SizedBox(height: 16)]).toList()
              ..removeLast(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.expand((w) => [w, const SizedBox(width: 16)]).toList()
        ..removeLast(),
    );
  }

  Widget _buildActionButtons(CasePaperController controller) {
    final buttons = [
      OutlinedButton.icon(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back to Profile'),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(20)),
      ),
      FilledButton.icon(
        onPressed: controller.saveCasePaper,
        icon: const Icon(Icons.save),
        label: const Text('Save Case Paper'),
        style: FilledButton.styleFrom(padding: const EdgeInsets.all(20)),
      ),
    ];

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [buttons[1], const SizedBox(height: 12), buttons[0]],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [buttons[0], const SizedBox(width: 16), buttons[1]],
    );
  }
}
