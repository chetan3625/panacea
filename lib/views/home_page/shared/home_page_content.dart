import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panacea/components/common_components.dart';
import 'package:panacea/constants/app_routes.dart';
import 'package:panacea/controller/home_controller.dart';
import 'package:panacea/controller/auth_session.dart';
import 'package:panacea/theme/app_theme.dart';
import 'package:panacea/theme/app_widgets.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 900;
    final textTheme = Theme.of(context).textTheme;

    if (isDesktop) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              SizedBox(width: 230, child: _buildSidebar(context)),
              Expanded(
                child: Column(
                  children: [
                    _buildDesktopHeader(context, controller),
                    Expanded(
                      child: Container(
                        color: AppColors.background,
                        child: _buildDesktopContent(
                          context,
                          controller,
                          textTheme,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildRedesignedMobile(context, controller, textTheme);
  }

  Widget _buildRedesignedMobile(
    BuildContext context,
    HomeController controller,
    TextTheme textTheme,
  ) {
    var filter = 'All';
    return Scaffold(
      body: SafeArea(
        child: StatefulBuilder(builder: (context, setLocalState) {
          final hour = DateTime.now().hour;
          final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
          return Stack(children: [
            Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(greeting, style: textTheme.bodySmall),
                    Text('Dr. Clinic Dashboard', style: textTheme.titleLarge),
                  ])),
                  IconButton(tooltip: 'Notifications', onPressed: controller.fetchPatients, icon: const Icon(Icons.notifications_none_rounded)),
                  IconButton(tooltip: 'Log out', onPressed: _confirmLogout, icon: const Icon(Icons.logout_rounded)),
                ]),
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildPatientSearch(controller)),
              const SizedBox(height: 12),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Obx(() => Row(children: [
                Expanded(child: StatTile(label: 'Patients', value: '${controller.recentPatients.length}', icon: Icons.people_outline)),
                const SizedBox(width: 8),
                Expanded(child: StatTile(label: 'This month', value: '${controller.patientsAddedThisMonth}', icon: Icons.person_add_alt_1, color: AppColors.success, tint: AppColors.successLight)),
                const SizedBox(width: 8),
                Expanded(child: StatTile(label: 'Follow-ups', value: '${controller.recentPatients.where((p) { final date = DateTime.tryParse(p['followUpDate']?.toString() ?? ''); final now = DateTime.now(); return date != null && date.year == now.year && date.month == now.month && date.day == now.day; }).length}', icon: Icons.event_available_outlined, color: AppColors.warning, tint: AppColors.warningLight)),
              ]))),
              const SizedBox(height: 14),
              SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
                for (final option in ['All', 'Follow-up today', 'New']) ...[
                  ChoiceChip(label: Text(option), selected: filter == option, onSelected: (_) => setLocalState(() => filter = option)),
                  const SizedBox(width: 6),
                ],
              ])),
              Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: SectionHeader(title: 'Patient directory')),
              Expanded(child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                if (controller.loadError.value.isNotEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_friendlyLoadError(controller.loadError.value), textAlign: TextAlign.center), TextButton.icon(onPressed: controller.fetchPatients, icon: const Icon(Icons.refresh), label: const Text('Retry'))]));
                final patients = controller.visiblePatients.where((patient) {
                  if (filter == 'Follow-up today') {
                    final date = DateTime.tryParse(patient['followUpDate']?.toString() ?? '');
                    final now = DateTime.now();
                    return date != null && date.year == now.year && date.month == now.month && date.day == now.day;
                  }
                  if (filter == 'New') {
                    final date = DateTime.tryParse(patient['createdAt']?.toString() ?? '');
                    final now = DateTime.now();
                    return date != null && date.year == now.year && date.month == now.month;
                  }
                  return true;
                }).toList();
                if (patients.isEmpty) return Center(child: Text(controller.recentPatients.isEmpty ? 'No patients yet. Add your first patient.' : 'No patients match this filter.', style: textTheme.bodyMedium));
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 104),
                  itemCount: patients.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _buildRedesignedPatientTile(context, controller, patients[index]),
                );
              })),
            ]),
            Positioned(right: 16, bottom: 16, child: FloatingActionButton.extended(
              onPressed: controller.navigateToPatientForm,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('New patient'),
            )),
          ]);
        }),
      ),
    );
  }

  Widget _buildRedesignedPatientTile(BuildContext context, HomeController controller, Map<String, dynamic> patient) {
    final name = patient['name']?.toString() ?? 'Unnamed patient';
    final age = patient['age']?.toString() ?? '';
    final gender = patient['gender']?.toString() ?? '';
    final blood = patient['bloodGroup']?.toString() ?? '';
    final mobile = patient['mobile']?.toString() ?? '';
    final followUp = DateTime.tryParse(patient['followUpDate']?.toString() ?? '');
    final status = followUp == null ? 'Patient' : 'Follow-up ${followUp.day}/${followUp.month}';
    final initials = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2).map((part) => part[0].toUpperCase()).join();
    return Material(color: Colors.transparent, child: InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: () => _showPatientDetails(context, controller, patient),
      child: AppCard(padding: const EdgeInsets.all(12), child: Row(children: [
        InitialsAvatar(initials: initials.isEmpty ? '?' : initials),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 3),
          Text([if (age.isNotEmpty) '$age yrs', gender, blood, mobile].where((s) => s.isNotEmpty).join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          StatusTag(label: status, color: followUp == null ? AppColors.secondary : AppColors.warning, background: followUp == null ? AppColors.background : AppColors.warningLight),
        ])),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: AppColors.muted),
      ])),
    ));
  }

  String _friendlyLoadError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('clientexception') || lower.contains('socketexception') || lower.contains('socketconnection')) {
      return 'Could not connect to the clinic server. Check your connection and try again.';
    }
    return message;
  }

  Widget _buildSidebar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.health_and_safety, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PANACEA',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'CLINIC WORKSPACE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, letterSpacing: 1.1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 42),
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 10),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
          // Fix: Wrap with Material instead of Container to allow ink effects to paint properly
          Material(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              dense: true,
              leading: Icon(Icons.grid_view_rounded, color: colors.primary),
              title: Text(
                'Dashboard',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () {},
            ),
          ),
          const Spacer(),
          const Divider(),
          Material(
            color: Colors.transparent,
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.support_agent_outlined),
              title: const Text('Refresh patient data'),
              onTap: () => Get.find<HomeController>().fetchPatients(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8),
            child: Text(
              'Panacea Desktop',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, HomeController controller) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text('Clinic dashboard', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 16),
          Expanded(child: _buildPatientSearch(controller)),
          const SizedBox(width: 14),
          FilledButton.icon(onPressed: controller.navigateToPatientForm, icon: const Icon(Icons.person_add_alt_1), label: const Text('New patient')),
          const SizedBox(width: 8),
          IconButton(tooltip: 'Log out', onPressed: _confirmLogout, icon: const Icon(Icons.logout_rounded)),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) await Get.find<AuthSession>().signOut();
  }

  Widget _buildDesktopContent(
    BuildContext context,
    HomeController controller,
    TextTheme textTheme,
  ) {
    return Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview', style: textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Patient records and recent consultations',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: StatTile(label: 'Patients', value: '${controller.recentPatients.length}', icon: Icons.people_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(label: 'Added this month', value: '${controller.patientsAddedThisMonth}', icon: Icons.person_add_alt_1, color: AppColors.success, tint: AppColors.successLight),
                ),
                const SizedBox(width: 12),
                Expanded(child: StatTile(label: 'Follow-ups due', value: '${controller.recentPatients.where((p) { final date = DateTime.tryParse(p['followUpDate']?.toString() ?? ''); final now = DateTime.now(); return date != null && date.year == now.year && date.month == now.month && date.day == now.day; }).length}', icon: Icons.event_available_outlined, color: AppColors.warning, tint: AppColors.warningLight)),
                const SizedBox(width: 12),
                Expanded(child: StatTile(label: 'Case papers', value: '${controller.recentPatients.fold<int>(0, (count, patient) => count + ((patient['casePapers'] as List?)?.length ?? 0))}', icon: Icons.description_outlined)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildDesktopPatientDirectory(
              context,
              controller,
              textTheme,
            ),
          ),
        ],
      ),
    )));
  }

  Widget _buildPatientSearch(HomeController controller) {
    return Obx(
      () => CustomTextField(
        controller: controller.searchController,
        label: 'Search patient by name or mobile',
        prefixIcon: Icons.search,
        onChanged: controller.updateSearch,
        suffixIcon: controller.searchQuery.value.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: controller.clearSearch,
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }

  Widget _buildDesktopPatientDirectory(
    BuildContext context,
    HomeController controller,
    TextTheme textTheme,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 16, 12),
            child: Row(
              children: [
                Text('Patient directory', style: textTheme.titleMedium),
                const SizedBox(width: 10),
                Obx(
                  () => Text(
                    '${controller.visiblePatients.length} records',
                    style: textTheme.bodySmall,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: controller.fetchPatients,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.loadError.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_friendlyLoadError(controller.loadError.value)),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: controller.fetchPatients,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final patients = controller.visiblePatients;

              if (patients.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.recentPatients.isEmpty
                            ? Icons.person_search_outlined
                            : Icons.search_off_rounded,
                        size: 38,
                        color: AppColors.muted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.recentPatients.isEmpty
                            ? 'No patient records yet'
                            : 'No patients match that search',
                        style: textTheme.titleMedium,
                      ),
                      if (controller.recentPatients.isEmpty) ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: controller.navigateToPatientForm,
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Add first patient'),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.separated(
                key: const ValueKey('desktop_patient_list'),
                padding: const EdgeInsets.symmetric(horizontal: 0),
                itemCount: patients.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  final name = patient['name']?.toString() ?? 'Unnamed patient';
                  final mobile = patient['mobile']?.toString() ?? '';
                  final notes =
                      patient['diagnosis']?.toString().isNotEmpty == true
                      ? patient['diagnosis'].toString()
                      : patient['complaints']?.toString() ?? '';
                  final added = DateTime.tryParse(
                    patient['createdAt']?.toString() ?? '',
                  );

                  return Material(
                    key: ValueKey(
                      patient['_id'] ?? index,
                    ), // Fix: Protects layout states upon filter
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          _showPatientDetails(context, controller, patient),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    child: Text(
                                      name.isEmpty
                                          ? '?'
                                          : name[0].toUpperCase(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                mobile,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                notes.isEmpty ? 'No consultation notes' : notes,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                added == null
                                    ? ''
                                    : '${added.day}/${added.month}/${added.year}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Edit patient',
                                  onPressed: () =>
                                      controller.editPatient(patient),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'Delete patient',
                                  onPressed: () =>
                                      _confirmDelete(controller, patient, name),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  color: Theme.of(context).colorScheme.error,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _showPatientDetails(
    BuildContext context,
    HomeController controller,
    Map<String, dynamic> patient,
  ) async {
    final name = patient['name']?.toString() ?? 'Patient';
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final action = isWide
        ? await showDialog<String>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
              content: SizedBox(width: 560, child: _patientDetailRows(patient)),
              actions: _patientDetailActions(dialogContext),
            ),
          )
        : await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (sheetContext) => SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * .9),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 18),
                  Row(children: [
                    InitialsAvatar(initials: name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2).map((part) => part[0].toUpperCase()).join(), size: 52),
                    const SizedBox(width: 12),
                    Expanded(child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(sheetContext).textTheme.titleLarge)),
                  ]),
                  const SizedBox(height: 14),
                  Flexible(child: SingleChildScrollView(child: _patientDetailRows(patient))),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: PrimaryButton(label: 'Case papers', icon: Icons.description_outlined, onPressed: () => Navigator.pop(sheetContext, 'case-papers'))),
                    const SizedBox(width: 8),
                    Expanded(child: SecondaryButton(label: 'Edit patient', icon: Icons.edit_outlined, onPressed: () => Navigator.pop(sheetContext, 'edit'))),
                  ]),
                  TextButton(onPressed: () => Navigator.pop(sheetContext, 'close'), child: const Text('Close')),
                ]),
              ),
            ),
          );

    if (action == 'edit') controller.editPatient(patient);
    if (action == 'case-papers') {
      Get.toNamed(AppRoutes.casePapers, arguments: {'token': controller.token, 'patient': patient});
    }
  }

  Widget _patientDetailRows(Map<String, dynamic> patient) {
    final followUp = DateTime.tryParse(patient['followUpDate']?.toString() ?? '');
    final medicines = patient['medicines'] is List ? patient['medicines'] as List : const [];
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        _detailLine('Mobile', patient['mobile']),
        _detailLine('Age and gender', [patient['age'], patient['gender']].where((v) => v != null && v.toString().isNotEmpty).join(', ')),
        _detailLine('Blood group', patient['bloodGroup']),
        _detailLine('Address', patient['address']),
        _detailLine('Case papers', '${(patient['casePapers'] as List?)?.length ?? 0} records'),
        if (followUp != null) _detailLine('Next follow-up', '${followUp.day}/${followUp.month}/${followUp.year}'),
        if (patient['complaints']?.toString().isNotEmpty == true) ...[
          const Divider(height: 24),
          _detailLine('Complaints', patient['complaints']),
          _detailLine('Diagnosis', patient['diagnosis']),
          _detailLine('Advice', patient['advice']),
        ],
        if (medicines.isNotEmpty) ...[
          const Divider(height: 24),
          const Text('Prescribed medicines', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...medicines.map((medicine) => medicine is! Map ? const SizedBox.shrink() : Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('${medicine['name'] ?? ''}   ${medicine['potency'] ?? ''}   ${medicine['dosage'] ?? ''}'),
          )),
        ],
      ]),
    );
  }

  List<Widget> _patientDetailActions(BuildContext context) => [
    TextButton(onPressed: () => Navigator.of(context).pop('close'), child: const Text('Close')),
    OutlinedButton.icon(onPressed: () => Navigator.of(context).pop('case-papers'), icon: const Icon(Icons.assignment_outlined), label: const Text('Case papers')),
    FilledButton.icon(onPressed: () => Navigator.of(context).pop('edit'), icon: const Icon(Icons.edit_outlined), label: const Text('Edit patient')),
  ];

  Widget _detailLine(String label, dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.secondary),
            ),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    HomeController controller,
    Map<String, dynamic> patient,
    String name,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete patient?'),
        content: Text('Delete the record for $name? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) controller.deletePatient(patient);
  }
  
}

