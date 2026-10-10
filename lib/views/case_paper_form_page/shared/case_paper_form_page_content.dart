import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/case_paper_controller.dart';
import '../../../components/case_paper_components.dart';
import '../../../components/common_components.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_widgets.dart';

class CasePaperFormPageContent extends StatelessWidget {
  final bool isCompact;

  const CasePaperFormPageContent({super.key, required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CasePaperController>();
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, isCompact ? 112 : 24),
      children: [
        _buildProgressCard(context, controller),

        // --- DYNAMIC CARD FOR CASE PAPER 2 (ACUTE) ---
        Obx(() {
          if (controller.selectedCasePaperType.value.contains('Acute')) {
            return _buildFrameCard(
              title: '⚡ Acute Case Paper Assessment (Quick Intake)',
              initiallyExpanded: true,
              children: [
                RadioSelectGroup(
                  title: 'Onset Speed',
                  options: const [
                    'Sudden (Hours)',
                    'Gradual (Days)',
                    'Periodic / Recurrent'
                  ],
                  selectedValue: controller.acuteOnset,
                ),
                const SizedBox(height: 16),
                RadioSelectGroup(
                  title: 'Acute Exciting Cause',
                  options: const [
                    'Cold Draught / Wind',
                    'Sun / Heat Exposure',
                    'Over-eating / Indigestion',
                    'Emotional Upset / Anger',
                    'Wet / Rain',
                    'Physical Exertion'
                  ],
                  selectedValue: controller.acuteCause,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.acuteNotesController,
                  label: 'Acute Keynotes & Remedy Selection Notes',
                  maxLines: 2,
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),

        // --- DYNAMIC CARD FOR CASE PAPER 3 (THYROID CASE PAPER) ---
        Obx(() {
          if (controller.selectedCasePaperType.value.contains('Thyroid')) {
            return _buildFrameCard(
              title: '🦋 Thyroid Case Paper (Specialized Endocrinology Intake)',
              initiallyExpanded: true,
              children: [
                RadioSelectGroup(
                  title: 'Thyroid Diagnosis',
                  options: const [
                    'Hypothyroidism',
                    'Hyperthyroidism',
                    'Hashimoto\'s Thyroiditis',
                    'Graves\' Disease',
                    'Goitre / Thyroid Nodules'
                  ],
                  selectedValue: controller.thyroidDiagnosis,
                ),
                const SizedBox(height: 16),
                RadioSelectGroup(
                  title: 'Onset Phase & Physiological Trigger',
                  options: const [
                    'Puberty / Hormonal Phase',
                    'Pregnancy / Post-parturition',
                    'Menopause / Post-menopause',
                    'Post-Hysterectomy',
                    'Medical (OC Pills/Steroids)',
                    'Emotional Grief / Fear'
                  ],
                  selectedValue: controller.thyroidOnsetTrigger,
                ),
                const SizedBox(height: 16),
                RadioSelectGroup(
                  title: 'Goitre / Neck Swelling Location & Extent',
                  options: const [
                    'Neck Swelling (Diffuse)',
                    'Right Lobe Only',
                    'Left Lobe Only',
                    'Involving Chin & Neck',
                    'Nodular / Knotty'
                  ],
                  selectedValue: controller.goitreLocation,
                ),
                const SizedBox(height: 16),
                _buildResponsiveRow(
                  children: [
                    RadioSelectGroup(
                      title: 'Goitre Sensation',
                      options: const [
                        'Constriction / Air Passing',
                        'Painful / Sensitive',
                        'Painless Aching',
                        'Pressure on Swallowing'
                      ],
                      selectedValue: controller.goitreSensation,
                    ),
                    RadioSelectGroup(
                      title: 'Physique & Emaciation Pattern',
                      options: const [
                        'Myxoedema / Puffy Physique',
                        'Emaciation Above Downwards',
                        'Emaciation Below Upwards',
                        'Obesity (Lower Body)',
                        'Obesity (Upper Body)'
                      ],
                      selectedValue: controller.physiqueEmaciation,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Laboratory & Thyroid Profile (T3, T4, TSH)',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildResponsiveRow(
                  children: [
                    CustomTextField(
                      controller: controller.t3Controller,
                      label: 'Serum T3 (ng/dL)',
                      isNumber: true,
                    ),
                    CustomTextField(
                      controller: controller.t4Controller,
                      label: 'Serum T4 (µg/dL)',
                      isNumber: true,
                    ),
                    CustomTextField(
                      controller: controller.tshController,
                      label: 'Serum TSH (mIU/L)',
                      isNumber: true,
                    ),
                    CustomTextField(
                      controller: controller.antiTpoController,
                      label: 'Anti-TPO / USG Notes',
                    ),
                  ],
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),

        _buildFrameCard(
          title: '1. Demographics & Registry',
          initiallyExpanded: true,
          children: [
            RadioSelectGroup(
              title: 'Marital Status',
              options: const [
                'Single',
                'Married',
                'Divorced',
                'Widowed',
                'Separated'
              ],
              selectedValue: controller.selectedMaritalStatus,
              controller: controller.maritalStatusController,
            ),
            const SizedBox(height: 20),
            RadioSelectGroup(
              title: 'Referred To Us By',
              options: const [
                'Self / Direct',
                'Family / Relative',
                'Doctor Referral',
                'Online / Social Media',
                'Camp / Seminar',
                'Other'
              ],
              selectedValue: controller.selectedReferredBy,
              controller: controller.referredByController,
            ),
            const SizedBox(height: 20),
            RadioSelectGroup(
              title: 'Occupation Type',
              options: const [
                'Desk Job / Corporate',
                'Business / Shop',
                'Homemaker',
                'Student',
                'Field Work / Labor',
                'Healthcare / Teacher',
                'Retired'
              ],
              selectedValue: controller.selectedOccupation,
              controller: controller.occupationController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.occupationController,
              label: 'Occupation Details / Custom Notes (Optional)',
            ),
          ],
        ),

        _buildFrameCard(
          title: '2. Chief Complaints & Causation (LSMC)',
          children: [
            QuickAppendTextField(
              controller: controller.chiefComplaintsController,
              label: 'Chief Complaints & Associated Troubles',
              maxLines: 3,
              quickSuggestions: const [
                'Headache / Migraine',
                'Acidity / Gastric',
                'Skin Eruption / Itching',
                'Joint / Back Pain',
                'Allergic Rhinitis / Cough',
                'Anxiety / Stress',
                'Insomnia / Sleep Issues',
                'Menstrual Irregularity',
              ],
            ),
            const SizedBox(height: 20),
            QuickAppendTextField(
              controller: controller.causationJourneyController,
              label: 'Journey & Cause (Emotions, Intrinsic, Extrinsic)',
              maxLines: 2,
              quickSuggestions: const [
                'Emotional Shock / Grief',
                'Post-Infection / Illness',
                'Weather / Sudden Cold',
                'Over-exertion / Stress',
                'Dietary Excess / Poisoning',
                'Suppression of Eruptions',
                'Injury / Trauma',
                'Hormonal Change',
              ],
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
            const SizedBox(height: 20),
            QuickAppendTextField(
              controller: controller.historyOfMedicinesController,
              label: 'History of Medicines Taken',
              maxLines: 2,
              quickSuggestions: const [
                'Allopathy / Antibiotics',
                'Painkillers / NSAIDs',
                'Steroids',
                'Homeopathic Remedies',
                'Ayurvedic / Herbal',
                'Supplements / Vitamins',
                'No prior meds',
              ],
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
                  if (controller.pastDiseases.isEmpty) {
                    return const SizedBox.shrink();
                  }
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
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final disease = controller.pastDiseases[index];
                        return Material(
                          color:
                              Colors.transparent, // Fixes ListTile ink warning
                          child: ListTile(
                            title: Text(
                              disease,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: _buildResponsiveRow(
                                children: const [
                                  CustomTextField(
                                    label: 'Year',
                                    isNumber: true,
                                  ),
                                  CustomTextField(label: 'Cause'),
                                  CustomTextField(label: 'Symptoms'),
                                ],
                              ),
                            ),
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
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.familyHistoryMatrix.keys.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                _buildResponsiveRow(
                  children: [
                    SegmentedToggleGroup(
                      title: 'Thirst',
                      options: const [
                        'Normal',
                        'Thirstless',
                        'Large Quantities',
                      ],
                      selectedValue: controller.selectedThirst,
                    ),
                    SegmentedToggleGroup(
                      title: 'Water Temp',
                      options: const ['Normal', 'Cold', 'Warm'],
                      selectedValue: controller.selectedThirstTemp,
                    ),
                  ],
                ),
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
                    color: AppColors.text,
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
                _buildResponsiveRow(
                  children: [
                    CustomTextField(
                      controller: controller.menarcheAgeController,
                      label: 'Menarche Age',
                      isNumber: true,
                    ),
                    SegmentedToggleGroup(
                      title: 'Cycle Rhythm',
                      options: const ['Regular', 'Irregular'],
                      selectedValue: controller.isCycleRegular,
                    ),
                  ],
                ),
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
                _buildResponsiveRow(
                  children: [
                    CustomTextField(
                      controller: controller.bpController,
                      label: 'Blood Pressure',
                    ),
                    CustomTextField(
                      controller: controller.pulseController,
                      label: 'Pulse',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildResponsiveRow(
                  children: [
                    CustomTextField(
                      controller: controller.weightController,
                      label: 'Weight (kg)',
                      isNumber: true,
                    ),
                    CustomTextField(
                      controller: controller.heightController,
                      label: 'Height (cm)',
                      isNumber: true,
                    ),
                  ],
                ),
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
                        child: _buildResponsiveRow(
                          flexes: [
                            2,
                            1,
                            2,
                            0,
                          ], // 0 flex avoids Expanded on the delete icon
                          children: [
                            TextFormField(
                              initialValue: med['name'],
                              decoration: const InputDecoration(
                                labelText: 'Medicine',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) =>
                                  controller.updateMedicine(index, 'name', val),
                            ),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Potency',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: med['potency'],
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
                            TextFormField(
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
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => controller.removeMedicine(index),
                            ),
                          ],
                        ),
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

            const SizedBox(height: 24),
          ],
        );
      }

  Widget _buildFrameCard({
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    final sectionNumber = RegExp(r'^\s*(\d+)\.').firstMatch(title)?.group(1);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      elevation: 0,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: sectionNumber == null
            ? null
            : CircleAvatar(
                radius: 13,
                backgroundColor: initiallyExpanded ? AppColors.success : AppColors.primary,
                child: Text(sectionNumber, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        childrenPadding: const EdgeInsets.all(20),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, CasePaperController controller) => Obx(() {
    final complete = [
      controller.occupationController.text.trim().isNotEmpty || controller.selectedMaritalStatus.value.isNotEmpty,
      controller.chiefComplaintsController.text.trim().isNotEmpty,
      controller.pastDiseases.isNotEmpty,
      controller.familyHistoryMatrix.values.any((values) => values.isNotEmpty),
      controller.foodDesires.isNotEmpty || controller.foodAversions.isNotEmpty || controller.dreamCategories.isNotEmpty,
      controller.menarcheAgeController.text.trim().isNotEmpty || controller.leucorrhoeaTags.isNotEmpty,
      controller.objectiveInspectionTags.isNotEmpty || controller.weightController.text.isNotEmpty || controller.bpController.text.isNotEmpty,
      controller.mentalRubrics.isNotEmpty || controller.prescriptionNotesController.text.trim().isNotEmpty || controller.prescribedMedicines.isNotEmpty,
    ].where((value) => value).length;
    return AppCard(
      color: AppColors.primaryLight,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text('$complete of 8 sections done', style: Theme.of(context).textTheme.bodySmall)),
          Text('${(complete / 8 * 100).round()}%', style: Theme.of(context).textTheme.bodySmall),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: complete / 8, color: AppColors.primary, backgroundColor: AppColors.card),
      ]),
    );
  });

  /// Rebuilt to safely handle layout logic internally instead of passing pre-Expanded widgets
  Widget _buildResponsiveRow({
    required List<Widget> children,
    List<int>? flexes,
  }) {
    if (isCompact) {
      // Mobile: Stack vertically without using Expanded
      final columnChildren = <Widget>[];
      for (int i = 0; i < children.length; i++) {
        columnChildren.add(children[i]);
        if (i < children.length - 1) {
          columnChildren.add(const SizedBox(height: 16));
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columnChildren,
      );
    }

    // Desktop: Lay out horizontally, injecting Expanded where requested
    final rowChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      final flex = (flexes != null && i < flexes.length) ? flexes[i] : 1;

      if (flex > 0) {
        rowChildren.add(Expanded(flex: flex, child: children[i]));
      } else {
        rowChildren.add(
          children[i],
        ); // flex 0 = render at natural width (e.g. icons)
      }

      if (i < children.length - 1) {
        rowChildren.add(const SizedBox(width: 16));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowChildren,
    );
  }

}
