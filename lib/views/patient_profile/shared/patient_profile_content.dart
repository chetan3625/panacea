import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panacea/constants/app_routes.dart';
import 'package:panacea/controller/auth_session.dart';

class PatientProfilePageContent extends StatelessWidget {
  final String patientName;
  final String mobileNumber;
  // Full patient map passed from home page navigation
  final Map<String, dynamic> patient;

  const PatientProfilePageContent({
    super.key,
    required this.patientName,
    required this.mobileNumber,
    this.patient = const {},
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    // Derive real patient data from the passed map
    final name = patient['name']?.toString() ?? patientName;
    final mobile = patient['mobile']?.toString() ??
        patient['mobileNumber']?.toString() ??
        mobileNumber;
    final age = patient['age']?.toString() ?? '';
    final gender = patient['gender']?.toString() ?? '';
    final bloodGroup = patient['bloodGroup']?.toString() ??
        patient['blood_group']?.toString() ??
        '';
    final city = patient['city']?.toString() ??
        patient['address']?.toString() ??
        '';

    // Build visit history from real case papers stored on patient
    final rawPapers = patient['casePapers'];
    final List<Map<String, dynamic>> casePapers = rawPapers is List
        ? rawPapers
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList()
        : [];

    // Get token from AuthSession
    final token = Get.isRegistered<AuthSession>()
        ? Get.find<AuthSession>().token.value
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            tooltip: 'View Case Papers',
            onPressed: () => _openCasePapers(context, token),
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openCasePapers(context, token),
              icon: const Icon(Icons.add),
              label: const Text('New Visit'),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Patient Header ---
            _buildPatientHeader(
              context,
              textTheme,
              name: name,
              mobile: mobile,
              age: age,
              gender: gender,
              bloodGroup: bloodGroup,
              city: city,
            ),
            const SizedBox(height: 32),

            // --- Action Bar ---
            if (isDesktop)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Treatment History', style: textTheme.headlineMedium),
                  FilledButton.icon(
                    onPressed: () => _openCasePapers(context, token),
                    icon: const Icon(Icons.add),
                    label: const Text('Open Case Papers'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text('Treatment History', style: textTheme.headlineMedium),

            const SizedBox(height: 24),

            // --- Real Case Papers or Empty State ---
            if (casePapers.isEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No case papers recorded yet.',
                        style: textTheme.bodyLarge
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _openCasePapers(context, token),
                        icon: const Icon(Icons.add),
                        label: const Text('Start First Case Paper'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...casePapers.map(
                (paper) => _buildCasePaperCard(context, paper, textTheme),
              ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(
    BuildContext context,
    TextTheme textTheme, {
    required String name,
    required String mobile,
    required String age,
    required String gender,
    required String bloodGroup,
    required String city,
  }) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (mobile.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      mobile,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (age.isNotEmpty)
                        _buildInfoChip(
                            context, Icons.calendar_month, '$age Yrs'),
                      if (gender.isNotEmpty)
                        _buildInfoChip(context, Icons.person, gender),
                      if (bloodGroup.isNotEmpty)
                        _buildInfoChip(
                            context, Icons.bloodtype, bloodGroup),
                      if (city.isNotEmpty)
                        _buildInfoChip(context, Icons.location_on, city),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCasePaperCard(
    BuildContext context,
    Map<String, dynamic> paper,
    TextTheme textTheme,
  ) {
    final data = paper['data'] is Map
        ? Map<String, dynamic>.from(paper['data'] as Map)
        : paper;

    final date = data['date']?.toString() ?? '';
    final paperType = data['paperType']?.toString() ??
        paper['paperType']?.toString() ??
        'Case Paper';
    final complaint = data['chiefComplaint']?.toString() ??
        data['chiefComplaints']?.toString() ??
        '';

    // Build remedy string
    String remedy = '';
    if (data['remedy'] != null && data['remedy'].toString().isNotEmpty) {
      remedy = data['remedy'].toString();
    } else if (paper['prescription'] is List &&
        (paper['prescription'] as List).isNotEmpty) {
      final first = (paper['prescription'] as List).first;
      if (first is Map) {
        remedy = '${first['name'] ?? ''} ${first['potency'] ?? ''}'.trim();
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_filled,
                        size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      date.isNotEmpty ? date : paperType,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  paperType,
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (complaint.isNotEmpty) ...[
              const Divider(height: 24),
              _buildDetailRow(textTheme, 'Complaints:', complaint),
            ],
            if (remedy.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(textTheme, 'Remedy:', remedy),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(TextTheme textTheme, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
          ),
        ),
        Expanded(child: Text(content, style: textTheme.bodyLarge)),
      ],
    );
  }

  void _openCasePapers(BuildContext context, String? token) {
    Get.toNamed(
      AppRoutes.casePapers,
      arguments: {'token': token, 'patient': patient},
    );
  }
}
