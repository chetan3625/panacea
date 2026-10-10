import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CasePaperPdfService {
  static const _sections = <String, List<String>>{
    'Frame 1: Demographics & core registry': [
      'date',
      'caseId',
      'name',
      'age',
      'occupation',
      'maritalStatus',
      'mobile',
      'address',
      'referredBy',
      'gender',
    ],
    'Frame 2: Chief complaints & causation journey': [
      'chiefComplaint',
      'complaintLocation',
      'complaintSensation',
      'complaintModalities',
      'complaintConcomitants',
      'onsetAndJourney',
      'causation',
      'pathologyJourney',
      'endocrineHistory',
      'medicineHistory',
      'complaintDiagnosis',
      'conclusion1',
    ],
    'Frame 3: Past history & chronic disease timeline': [
      'pastDiseases',
      'timeline',
      'pastHistoryNotes',
      'conclusion2',
    ],
    'Frame 4: Family history & diathesis': [
      'familyDiseases',
      'relatives',
      'similarFamilyTrouble',
      'conclusion3',
    ],
    'Frame 5: Physical generals & dreams': [
      'foodDesires',
      'foodAversions',
      'foodAggravations',
      'foodAmeliorations',
      'appetiteTime',
      'appetiteTolerance',
      'sweat',
      'stools',
      'urine',
      'sleepAndOther',
      'seasonalAggravation',
      'coveringsAndBathing',
      'thermal',
      'thirst',
      'foodTemperature',
      'appetiteTiming',
      'sweatIntensity',
      'modalities',
      'dreamTypes',
      'conclusion4',
    ],
    'Frame 6: Female / menstrual / hormonal lifecycle': [
      'menarcheAge',
      'lastMenstrualPeriod',
      'menarcheComplaints',
      'cycle',
      'periodDays',
      'flowCharacter',
      'staining',
      'menstrualSmell',
      'cycleInterventions',
      'leucorrhoea',
      'leucorrhoeaFactors',
      'pregnancyHistory',
      'ocPills',
      'lactation',
      'hormonalPhases',
      'flowTraits',
      'menstrualConcomitants',
      'menstrualTiming',
      'peculiarDuringMenses',
      'conclusion5',
    ],
    'Frame 7: Physical & objective examination': [
      'respiratory',
      'cvs',
      'git',
      'bloodPressure',
      'pulse',
      'build',
      'weight',
      'height',
      'eyes',
      'ears',
      'nose',
      'tongue',
      'nails',
      'hair',
      'throat',
      'lymphNodes',
      'joints',
      'objectiveFindings',
      'conclusion6',
    ],
    'Frame 8: Mind, rubrics & doctor conclusions': [
      'mentalNarrative',
      'mindThemes',
      'rubrics',
      'relationshipAndHobbies',
      'memoryAndAmbitions',
      'symptomOrder',
      'caseAnalysis',
      'remedyGiven',
      'followUp',
      'doctorConclusion8',
    ],
  };

  static Future<void> generateAndPrint({
    required String patientName,
    required Map<String, dynamic> caseData,
  }) async {
    final document = pw.Document();
    final content = <pw.Widget>[
      pw.Text(
        'CASE PAPER 1',
        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 6),
      pw.Text('Patient: $patientName', style: const pw.TextStyle(fontSize: 12)),
      pw.Divider(color: PdfColors.blueGrey700),
      pw.SizedBox(height: 8),
    ];

    for (final section in _sections.entries) {
      final rows = <MapEntry<String, String>>[];
      for (final key in section.value) {
        final value = _formatValue(caseData[key]);
        if (value.isNotEmpty) rows.add(MapEntry(_label(key), value));
      }
      if (rows.isEmpty) continue;
      content.add(
        pw.Container(
          width: double.infinity,
          margin: const pw.EdgeInsets.only(top: 10, bottom: 6),
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: PdfColors.blueGrey800,
          child: pw.Text(
            section.key,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      for (final row in rows) {
        content.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 145,
                  child: pw.Text(
                    row.key,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    row.value,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => content,
      ),
    );

    final fileName = patientName.trim().replaceAll(RegExp(r'\s+'), '_');
    await Printing.layoutPdf(
      onLayout: (_) async => document.save(),
      name: 'Case_Paper_1_${fileName.isEmpty ? 'Patient' : fileName}.pdf',
    );
  }

  static String _label(String key) {
    final words = key.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match[1]} ${match[2]}',
    );
    return '${words[0].toUpperCase()}${words.substring(1)}';
  }

  static String _formatValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is Iterable) {
      return value
          .map(_formatValue)
          .where((item) => item.isNotEmpty)
          .join(', ');
    }
    if (value is Map) {
      return value.entries
          .map((entry) {
            final content = _formatValue(entry.value);
            if (content.isEmpty) return '';
            return '${_label(entry.key.toString())}: $content';
          })
          .where((item) => item.isNotEmpty)
          .join('\n');
    }
    return value.toString();
  }
}
