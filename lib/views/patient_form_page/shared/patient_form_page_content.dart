import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panacea/constants/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:panacea/constants/theme.dart';
import 'package:panacea/controller/auth_session.dart';
import 'package:panacea/services/api_service.dart';
import 'package:panacea/services/perscription_pdf_service.dart';

class PatientFormPageContent extends StatefulWidget {
  const PatientFormPageContent({super.key});

  @override
  State<PatientFormPageContent> createState() => _PatientFormPageContentState();
}

class _PatientFormPageContentState extends State<PatientFormPageContent> {
  // Section A Controllers
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedGender;
  String? _selectedBloodGroup;

  // Section B Controllers
  final TextEditingController _complaintsController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _adviceController = TextEditingController();
  DateTime _followUpDate = DateTime.now().add(const Duration(days: 7));

  // Dynamic Medicines List
  final List<Map<String, String>> _medicines = [];
  int _nextMedicineId = 0;
  bool _isSaving = false;
  String? _token;
  Map<String, dynamic>? _patient;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    if (arguments is Map) {
      _token = arguments['token']?.toString();
      final patient = arguments['patient'];
      if (patient is Map) {
        _patient = Map<String, dynamic>.from(patient);
        _mobileController.text = _patient?['mobile']?.toString() ?? '';
        _nameController.text = _patient?['name']?.toString() ?? '';
        _ageController.text = _patient?['age']?.toString() ?? '';
        _addressController.text = _patient?['address']?.toString() ?? '';
        _selectedGender = _patient?['gender']?.toString();
        _selectedBloodGroup = _patient?['bloodGroup']?.toString();
        _complaintsController.text = _patient?['complaints']?.toString() ?? '';
        _diagnosisController.text = _patient?['diagnosis']?.toString() ?? '';
        _adviceController.text = _patient?['advice']?.toString() ?? '';
        final followUpDate = DateTime.tryParse(
          _patient?['followUpDate']?.toString() ?? '',
        );
        if (followUpDate != null) _followUpDate = followUpDate;
        final medicines = _patient?['medicines'];
        if (medicines is List) {
          for (final medicine in medicines) {
            if (medicine is Map) {
              _medicines.add({
                'id': '${_nextMedicineId++}',
                'name': medicine['name']?.toString() ?? '',
                'potency': medicine['potency']?.toString() ?? '30C',
                'dosage': medicine['dosage']?.toString() ?? '',
              });
            }
          }
        }
      }
    }
  }

  void _addMedicineField() {
    setState(() {
      _medicines.add({
        'id': '${_nextMedicineId++}',
        'name': '',
        'potency': '30C',
        'dosage': '',
      });
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _complaintsController.dispose();
    _diagnosisController.dispose();
    _adviceController.dispose();
    super.dispose();
  }

  Future<void> _selectFollowUpDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _followUpDate && mounted) {
      setState(() {
        _followUpDate = picked;
      });
    }
  }

  Future<void> _submitPatient({
    required bool generatePdf,
    bool startCasePaper = false,
  }) async {
    if (_nameController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter the patient name and mobile number first.'),
        ),
      );
      return;
    }

    if (_token == null || _token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again to save patients.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final payload = {
        'name': _nameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'age': _ageController.text.trim(),
        'gender': _selectedGender ?? '',
        'bloodGroup': _selectedBloodGroup ?? '',
        'address': _addressController.text.trim(),
        'complaints': _complaintsController.text.trim(),
        'diagnosis': _diagnosisController.text.trim(),
        'medicines': _medicines
            .map(
              (medicine) => {
                'name': medicine['name'] ?? '',
                'potency': medicine['potency'] ?? '30C',
                'dosage': medicine['dosage'] ?? '',
              },
            )
            .where((medicine) => medicine['name']!.trim().isNotEmpty)
            .toList(),
        'advice': _adviceController.text.trim(),
        'followUpDate': _followUpDate.toIso8601String(),
      };
      final response = _patient == null
          ? await ApiService.post('/patients', payload, token: _token)
          : await ApiService.put(
              '/patients/${_patient!['_id']}',
              payload,
              token: _token,
            );
      if (response.statusCode == 401 || response.statusCode == 403) {
        await Get.find<AuthSession>().signOut();
        return;
      }
      final data = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(data['message'] ?? 'Could not save patient record.');
      }

      if (startCasePaper) {
        final savedPatient = data['patient'];
        if (savedPatient is! Map) {
          throw Exception(
            'Patient was saved, but could not open the case paper.',
          );
        }
        await Get.toNamed(
          AppRoutes.casePapers,
          arguments: {
            'token': _token,
            'patient': Map<String, dynamic>.from(savedPatient),
            'startNew': true,
          },
        );
      }

      if (generatePdf) {
        try {
          await PrescriptionPdfService.generateAndPrintPdf(
            patientName: _nameController.text.trim(),
            age: _ageController.text.trim(),
            gender: _selectedGender ?? 'Not specified',
            bloodGroup: _selectedBloodGroup ?? '',
            mobile: _mobileController.text.trim(),
            address: _addressController.text.trim(),
            complaints: _complaintsController.text.trim(),
            diagnosis: _diagnosisController.text.trim(),
            medicines: payload['medicines'] as List<Map<String, String>>,
            advice: _adviceController.text.trim(),
            followUpDate: _followUpDate,
          );
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Record saved, but PDF generation failed: $error',
                ),
              ),
            );
          }
        }
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save the patient: ${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_patient == null ? 'New Consultation' : 'Edit Patient'),
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;
            final isDesktop = constraints.maxWidth >= 1100;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1580 : 800,
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 48 : 24,
                      vertical: isDesktop ? 36 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _patient == null
                                        ? 'New patient record'
                                        : 'Update patient record',
                                    style: textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Patient details and consultation notes',
                                    style: textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            if (isDesktop)
                              Text(
                                DateFormat(
                                  'EEEE, MMM d',
                                ).format(DateTime.now()),
                                style: textTheme.bodyMedium,
                              ),
                          ],
                        ),
                        SizedBox(height: isDesktop ? 24 : 16),
                        if (isDesktop)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildDemographicsSection(
                                textTheme,
                                isCompact,
                                isDesktop: true,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: _buildConsultationSection(
                                      textTheme,
                                      isDesktop: true,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 7,
                                    child: _buildPrescriptionSection(
                                      textTheme,
                                      isCompact,
                                      context,
                                      isDesktop: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        else ...[
                          _buildDemographicsSection(textTheme, isCompact),
                          const SizedBox(height: 24),
                          _buildConsultationSection(textTheme),
                          const SizedBox(height: 24),
                          _buildPrescriptionSection(
                            textTheme,
                            isCompact,
                            context,
                          ),
                        ],
                        const SizedBox(height: 24),

                        // --- Action Buttons ---
                        isCompact
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _isSaving
                                        ? null
                                        : () => _submitPatient(
                                            generatePdf: false,
                                          ),
                                    icon: const Icon(Icons.save),
                                    label: const Text('Save record'),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: _isSaving
                                        ? null
                                        : () => _submitPatient(
                                            generatePdf: false,
                                            startCasePaper: true,
                                          ),
                                    icon: const Icon(Icons.assignment_outlined),
                                    label: const Text(
                                      'Save & start Case Paper 1',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton.icon(
                                    onPressed: _isSaving
                                        ? null
                                        : () =>
                                              _submitPatient(generatePdf: true),
                                    icon: _isSaving
                                        ? const SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.picture_as_pdf),
                                    label: Text(
                                      _isSaving
                                          ? 'Saving…'
                                          : 'Save & generate PDF',
                                    ),
                                  ),
                                ],
                              )
                            : Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _isSaving
                                        ? null
                                        : () => _submitPatient(
                                            generatePdf: false,
                                          ),
                                    icon: const Icon(Icons.save),
                                    label: const Text('Save record'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _isSaving
                                        ? null
                                        : () => _submitPatient(
                                            generatePdf: false,
                                            startCasePaper: true,
                                          ),
                                    icon: const Icon(Icons.assignment_outlined),
                                    label: const Text(
                                      'Save & start Case Paper 1',
                                    ),
                                  ),
                                  FilledButton.icon(
                                    onPressed: _isSaving
                                        ? null
                                        : () =>
                                              _submitPatient(generatePdf: true),
                                    icon: _isSaving
                                        ? const SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.picture_as_pdf),
                                    label: Text(
                                      _isSaving
                                          ? 'Saving…'
                                          : 'Save & generate PDF',
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDemographicsSection(
    TextTheme textTheme,
    bool isCompact, {
    bool isDesktop = false,
  }) {
    const bloodGroups = ['A+', 'O+', 'B+', 'AB+', 'A-', 'O-', 'B-', 'AB-'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Patient details', style: textTheme.titleLarge),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isCompact) ...[
                  _buildTextField(
                    _mobileController,
                    'Mobile',
                    icon: Icons.phone,
                    isNumber: true,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    _nameController,
                    'Full Name',
                    icon: Icons.person,
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _mobileController,
                          'Mobile',
                          icon: Icons.phone,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          _nameController,
                          'Full Name',
                          icon: Icons.person,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 14),
                if (isCompact) ...[
                  _buildTextField(_ageController, 'Age', isNumber: true),
                  const SizedBox(height: 14),
                  _buildDropdown(
                    'Gender',
                    ['Male', 'Female', 'Other'],
                    _selectedGender,
                    (value) => setState(() => _selectedGender = value),
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown(
                    'Blood group',
                    bloodGroups,
                    _selectedBloodGroup,
                    (value) => setState(() => _selectedBloodGroup = value),
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _ageController,
                          'Age',
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDropdown(
                          'Gender',
                          ['Male', 'Female', 'Other'],
                          _selectedGender,
                          (value) => setState(() => _selectedGender = value),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDropdown(
                          'Blood group',
                          bloodGroups,
                          _selectedBloodGroup,
                          (value) =>
                              setState(() => _selectedBloodGroup = value),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 14),
                _buildTextField(
                  _addressController,
                  'Address (Optional)',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationSection(
    TextTheme textTheme, {
    bool isDesktop = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Consultation', style: textTheme.titleLarge)),
            Text(
              DateFormat('MMM d, yyyy').format(DateTime.now()),
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  _complaintsController,
                  'Chief Complaints / Symptoms',
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                _buildTextField(_diagnosisController, 'Diagnosis / Rubrics'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionSection(
    TextTheme textTheme,
    bool isCompact,
    BuildContext context, {
    bool isDesktop = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Prescription', style: textTheme.titleLarge)),
            TextButton.icon(
              onPressed: _addMedicineField,
              icon: const Icon(Icons.add),
              label: const Text('Add medicine'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_medicines.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'No medicines added. Add one to include it in the prescription.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ..._medicines.asMap().entries.map((entry) {
                  return Padding(
                    key: ValueKey(entry.value['id']),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMedicineFields(entry.key),
                  );
                }),
                if (_medicines.isNotEmpty) const Divider(height: 28),
                _buildTextField(
                  _adviceController,
                  'Dietary / General Advice',
                  maxLines: isCompact ? 2 : 3,
                ),
                const SizedBox(height: 12),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    const Text('Next follow-up:'),
                    TextButton.icon(
                      onPressed: () => _selectFollowUpDate(context),
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        DateFormat('MMM dd, yyyy').format(_followUpDate),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineFields(int index) {
    final medicine = _medicines[index];
    final fields = <Widget>[
      TextFormField(
        initialValue: medicine['name'],
        decoration: const InputDecoration(
          labelText: 'Medicine (e.g. Nux Vomica)',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => medicine['name'] = value,
      ),
      _buildDropdown(
        'Potency',
        ['30C', '200C', '1M', '10M', 'Q'],
        medicine['potency'],
        (value) {
          if (value != null) {
            setState(() => medicine['potency'] = value);
          }
        },
      ),
      TextFormField(
        initialValue: medicine['dosage'],
        decoration: const InputDecoration(
          labelText: 'Dosage (e.g. 3x/day)',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => medicine['dosage'] = value,
      ),
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Medicine ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: 'Remove medicine',
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => setState(() => _medicines.removeAt(index)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          fields[0],
          const SizedBox(height: 12),
          fields[1],
          const SizedBox(height: 12),
          fields[2],
        ],
      ),
    );
  }

  // Helper Widget for Text Fields
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    IconData? icon,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  // Helper Widget for Dropdowns
  Widget _buildDropdown(
    String label,
    List<String> items,
    String? currentValue,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      initialValue: currentValue,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
