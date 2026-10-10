import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panacea/views/patient_form_page.dart';

class PatientProfilePage extends StatelessWidget {
  final String patientName;
  final String mobileNumber;

  const PatientProfilePage({
    super.key,
    required this.patientName,
    required this.mobileNumber,
  });

  // Mock data for Medical History
  static final List<Map<String, dynamic>> _pastVisits = [
    {
      'date': DateTime.now().subtract(const Duration(days: 14)),
      'complaints': 'Severe right-sided headache, worse with light.',
      'diagnosis': 'Migraine (Right-sided)',
      'medicines': [
        {'name': 'Belladonna', 'potency': '30C', 'dosage': '4 pills, 3x/day'},
        {'name': 'Sanguinaria', 'potency': '200C', 'dosage': '2 drops, SOS'},
      ],
      'advice': 'Avoid bright lights and excessive screen time.',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 45)),
      'complaints': 'Mild joint pain in knees, stiffness in morning.',
      'diagnosis': 'Early Arthritis',
      'medicines': [
        {'name': 'Rhus Tox', 'potency': '30C', 'dosage': '4 pills, 2x/day'},
      ],
      'advice': 'Warm compresses and light stretching.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_document), onPressed: () {}),
          const SizedBox(width: 16),
        ],
      ),
      // FAB for Mobile to quickly add a new consultation
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _startNewConsultation(context),
              icon: const Icon(Icons.add),
              label: const Text('New Visit'),
            ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Top Header: Patient Demographics ---
                _buildPatientHeader(context, textTheme),
                const SizedBox(height: 32),

                // --- Action Bar (Desktop) ---
                if (isDesktop)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Treatment History',
                        style: textTheme.headlineMedium,
                      ),
                      FilledButton.icon(
                        onPressed: () => _startNewConsultation(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Start New Consultation'),
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

                // --- Medical History Timeline ---
                ..._pastVisits.map(
                  (visit) => _buildVisitCard(context, visit, textTheme),
                ),
                const SizedBox(height: 60), // Padding for FAB on mobile
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildPatientHeader(BuildContext context, TextTheme textTheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                patientName[0].toUpperCase(),
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
                    patientName,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mobileNumber,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(context, Icons.calendar_month, '34 Yrs'),
                      _buildInfoChip(context, Icons.person, 'Male'),
                      _buildInfoChip(context, Icons.bloodtype, 'O+'),
                      _buildInfoChip(
                        context,
                        Icons.location_on,
                        'Nashik, Maharashtra',
                      ),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        // border: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
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

  Widget _buildVisitCard(
    BuildContext context,
    Map<String, dynamic> visit,
    TextTheme textTheme,
  ) {
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
            // Date and Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(visit['date']),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Generating PDF for past visit...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Prescription'),
                ),
              ],
            ),
            const Divider(height: 32),

            // Clinical Details
            _buildDetailRow(textTheme, 'Complaints:', visit['complaints']),
            const SizedBox(height: 12),
            _buildDetailRow(textTheme, 'Diagnosis:', visit['diagnosis']),
            const SizedBox(height: 16),

            // Prescribed Medicines Table
            Text(
              'Medicines Prescribed:',
              style: textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Prevent nested scroll crashes
                itemCount: visit['medicines'].length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final med = visit['medicines'][index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      med['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Dosage: ${med['dosage']}'),
                    trailing: Chip(
                      label: Text(med['potency']),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      side: BorderSide.none,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(textTheme, 'Advice:', visit['advice']),
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

  // --- Navigation ---
  void _startNewConsultation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PatientFormPage()),
    );
  }
}
