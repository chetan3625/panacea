import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PrescriptionPdfService {
  static Future<void> generateAndPrintPdf({
    required String patientName,
    required String age,
    required String gender,
    required String mobile,
    String address = '',
    String bloodGroup = '',
    required String complaints,
    required String diagnosis,
    required List<Map<String, String>> medicines,
    required String advice,
    required DateTime followUpDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(),
        footer: (context) => _buildFooter(),
        build: (context) => [
          _buildPatientDetails(
            patientName,
            age,
            gender,
            mobile,
            address,
            bloodGroup,
          ),
          pw.Divider(thickness: 1, color: PdfColors.grey400),
          pw.SizedBox(height: 16),

          // Clinical Notes
          _buildSectionTitle('Clinical Notes'),
          _buildTextRow('Chief Complaints:', complaints),
          _buildTextRow('Diagnosis / Rubrics:', diagnosis),
          pw.SizedBox(height: 24),

          // Rx Symbol and Medicines
          pw.Text(
            'Rx',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildMedicinesTable(medicines),

          pw.SizedBox(height: 24),

          // Advice & Follow up
          if (advice.isNotEmpty) ...[
            _buildSectionTitle('General Advice / Diet'),
            pw.Text(advice, style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 16),
          ],

          _buildSectionTitle('Next Follow-up'),
          pw.Text(
            DateFormat('EEEE, MMM dd, yyyy').format(followUpDate),
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    // This opens the native Print/Share preview on both Desktop and Mobile
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Prescription_${patientName.replaceAll(' ', '_')}.pdf',
    );
  }

  // --- PDF Layout Components ---

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Dr. Homeopath Clinic',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  'Dr. Firstname Lastname, BHMS, MD',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Reg No: 123456789',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  '123 Health Avenue, City Center',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Nashik, Maharashtra 422001',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Phone: +91 9876543210',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Divider(thickness: 2, color: PdfColors.blue800),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildPatientDetails(
    String name,
    String age,
    String gender,
    String mobile,
    String address,
    String bloodGroup,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Patient Name: $name',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Age/Gender: $age Yrs / $gender',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.Text('Mobile: $mobile', style: const pw.TextStyle(fontSize: 12)),
            if (bloodGroup.isNotEmpty)
              pw.Text(
                'Blood group: $bloodGroup',
                style: const pw.TextStyle(fontSize: 12),
              ),
            if (address.isNotEmpty)
              pw.SizedBox(
                width: 280,
                child: pw.Text(
                  'Address: $address',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue800,
        ),
      ),
    );
  }

  static pw.Widget _buildTextRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? 'N/A' : value,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMedicinesTable(List<Map<String, String>> medicines) {
    if (medicines.isEmpty) {
      return pw.Text(
        'No medicines prescribed.',
        style: const pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
      );
    }

    return pw.TableHelper.fromTextArray(
      context: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      headerHeight: 25,
      cellHeight: 30,
      headerStyle: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 12),
      headers: ['Sr.', 'Medicine Name', 'Potency', 'Dosage / Instructions'],
      data: List<List<String>>.generate(
        medicines.length,
        (index) => [
          '${index + 1}',
          medicines[index]['name'] ?? '',
          medicines[index]['potency'] ?? '',
          medicines[index]['dosage'] ?? '',
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.SizedBox(height: 40),
        pw.Divider(thickness: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Text(
          'Doctor\'s Signature',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Generated by Clinic App',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ],
    );
  }
}
