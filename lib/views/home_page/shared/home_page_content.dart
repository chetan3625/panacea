import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panacea/components/common_components.dart';
import 'package:panacea/constants/app_routes.dart';
import 'package:panacea/controller/home_controller.dart';
import 'package:panacea/controller/auth_session.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final textTheme = Theme.of(context).textTheme;

    if (isDesktop) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              SizedBox(width: 244, child: _buildSidebar(context)),
              Expanded(
                child: Column(
                  children: [
                    _buildDesktopHeader(context, controller),
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF4F7FA),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dr. Clinic Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.navigateToPatientForm,
        child: const Icon(Icons.add),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                _buildPatientSearch(controller),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildAddButton(controller),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth < 560
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 2;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: Obx(
                            () => _buildMetric(
                              'Total patients',
                              '${controller.recentPatients.length}',
                              Icons.groups_2_outlined,
                              const Color(0xFF006FFD),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: Obx(
                            () => _buildMetric(
                              'Added this month',
                              '${controller.patientsAddedThisMonth}',
                              Icons.person_add_alt_1,
                              const Color(0xFF18866B),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Patient directory',
                        style: textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh patients',
                      onPressed: controller.fetchPatients,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.loadError.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.loadError.value,
                            textAlign: TextAlign.center,
                          ),
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
                      child: Text(
                        controller.recentPatients.isEmpty
                            ? 'No patients yet. Add a patient to see them here.'
                            : 'No patients match your search.',
                        style: textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      final name =
                          patient['name']?.toString() ?? 'Unnamed patient';
                      final createdAt = DateTime.tryParse(
                        patient['createdAt']?.toString() ?? '',
                      );
                      final visitDate = createdAt == null
                          ? 'Date unavailable'
                          : '${createdAt.day}/${createdAt.month}/${createdAt.year}';
                      final condition =
                          patient['diagnosis']?.toString().isNotEmpty == true
                          ? patient['diagnosis'].toString()
                          : patient['complaints']?.toString() ?? '';

                      return Card(
                        key: ValueKey(
                          patient['_id'] ?? index,
                        ), // Fix: Prevents semantics rendering crash
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: () =>
                              _showPatientDetails(context, controller, patient),
                          leading: CircleAvatar(
                            child: Text(
                              name.isEmpty ? '?' : name[0].toUpperCase(),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${patient['mobile'] ?? ''}   Added: $visitDate\n${condition.isEmpty ? 'No consultation notes' : condition}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            tooltip: 'Patient actions',
                            onSelected: (action) {
                              if (action == 'edit') {
                                controller.editPatient(patient);
                              }
                              if (action == 'delete') {
                                _confirmDelete(controller, patient, name);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit patient'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete patient'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5EAF0))),
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
                color: Color(0xFF788493),
              ),
            ),
          ),
          // Fix: Wrap with Material instead of Container to allow ink effects to paint properly
          Material(
            color: const Color(0xFFEAF2FF),
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
              style: TextStyle(fontSize: 12, color: Color(0xFF788493)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, HomeController controller) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5EAF0))),
      ),
      child: Row(
        children: [
          Text(
            'Clinic dashboard',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Refresh patients',
            onPressed: controller.fetchPatients,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.all(32),
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
              SizedBox(width: 300, child: _buildPatientSearch(controller)),
              const SizedBox(width: 16),
              SizedBox(
                width: 160,
                child: FilledButton.icon(
                  onPressed: controller.navigateToPatientForm,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Add patient'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'Total patients',
                    '${controller.recentPatients.length}',
                    Icons.groups_2_outlined,
                    const Color(0xFF006FFD),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetric(
                    'Added this month',
                    '${controller.patientsAddedThisMonth}',
                    Icons.person_add_alt_1,
                    const Color(0xFF18866B),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: _buildDesktopPatientDirectory(
              context,
              controller,
              textTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5EAF0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF687587))),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        border: Border.all(color: const Color(0xFFE5EAF0)),
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
                      Text(controller.loadError.value),
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
                        color: const Color(0xFF8793A1),
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
    final medicines = patient['medicines'] is List
        ? patient['medicines'] as List
        : const [];
    final followUp = DateTime.tryParse(
      patient['followUpDate']?.toString() ?? '',
    );

    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(name),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailLine('Mobile', patient['mobile']),
                _detailLine('Age', patient['age']),
                _detailLine('Gender', patient['gender']),
                _detailLine('Blood group', patient['bloodGroup']),
                _detailLine('Address', patient['address']),
                const Divider(height: 28),
                _detailLine('Complaints', patient['complaints']),
                _detailLine('Diagnosis', patient['diagnosis']),
                _detailLine('Advice', patient['advice']),
                _detailLine(
                  'Case papers',
                  '${(patient['casePapers'] as List?)?.length ?? 0} records',
                ),
                _detailLine(
                  'Follow-up',
                  followUp == null
                      ? null
                      : '${followUp.day}/${followUp.month}/${followUp.year}',
                ),
                if (medicines.isNotEmpty) ...[
                  const Divider(height: 28),
                  const Text(
                    'Prescribed medicines',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...medicines.map((medicine) {
                    if (medicine is! Map) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${medicine['name'] ?? ''}   ${medicine['potency'] ?? ''}   ${medicine['dosage'] ?? ''}',
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('close'),
            child: const Text('Close'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop('case-papers'),
            icon: const Icon(Icons.assignment_outlined),
            label: const Text('Case papers'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop('edit'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit patient'),
          ),
        ],
      ),
    );

    if (action == 'edit') controller.editPatient(patient);
    if (action == 'case-papers') {
      Get.toNamed(
        AppRoutes.casePapers,
        arguments: {'token': controller.token, 'patient': patient},
      );
    }
  }

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
              style: const TextStyle(color: Color(0xFF687587)),
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

  Widget _buildAddButton(HomeController controller) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      ),
      onPressed: controller.navigateToPatientForm,
      icon: const Icon(Icons.person_add),
      label: const Text('+ Add New Patient'),
    );
  }
}
