import 'package:flutter_test/flutter_test.dart';

// Mirrors the exact _papers getter logic from case_papers_page_content.dart
List<Map<String, dynamic>> computePapers({
  required List<Map<String, dynamic>> fetchedPapers,
  required bool isLoadingPapers,
  required Map<String, dynamic> patient,
}) {
  List<Map<String, dynamic>> raw;

  if (fetchedPapers.isNotEmpty) {
    raw = fetchedPapers;
  } else if (isLoadingPapers) {
    return [];
  } else {
    final papers = patient['casePapers'];
    if (papers is! List) return [];
    raw = papers
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  final seen = <String>{};
  final deduped = <Map<String, dynamic>>[];
  for (final paper in raw) {
    final id = (paper['caseId'] ?? paper['_id'] ?? '').toString();
    if (id.isNotEmpty && seen.contains(id)) continue;
    if (id.isNotEmpty) seen.add(id);
    deduped.add(paper);
  }

  deduped.sort((a, b) {
    final dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '');
    final dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '');
    if (dateA != null && dateB != null) return dateB.compareTo(dateA);
    final dataA = a['data'] is Map ? a['data'] as Map : a;
    final dataB = b['data'] is Map ? b['data'] as Map : b;
    return (dataB['date']?.toString() ?? '')
        .compareTo(dataA['date']?.toString() ?? '');
  });

  return deduped;
}

void main() {
  group('_papers getter — duplication scenarios', () {
    // THE REAL SCENARIO:
    // - patient passed from home page has embedded casePapers snapshots
    //   (these have their own Mongoose subdocument _id, plus a caseId field)
    // - fetchedPapers comes from GET /case-papers/patient/:id
    //   (these are standalone CasePaper docs with their own _id)
    // - The snapshot's caseId == the standalone doc's _id
    // - The snapshot's own _id != standalone doc's _id
    // => Without correct handling: 2 papers show as 4 cards

    test('REAL SCENARIO: fetched docs take priority, embedded snapshots ignored', () {
      // Standalone CasePaper docs from /api/case-papers/patient/:id
      final fetchedPapers = [
        {
          '_id': 'casepaper_id_1',
          'caseId': 'casepaper_id_1',
          'paperType': 'Case Paper 1: Original Case Paper (Constitutional)',
          'createdAt': '2026-10-09T10:00:00.000Z',
        },
        {
          '_id': 'casepaper_id_2',
          'caseId': 'casepaper_id_2',
          'paperType': 'Case Paper 2: Acute Case Paper',
          'createdAt': '2026-10-10T10:00:00.000Z',
        },
      ];

      // Embedded snapshots inside patient.casePapers
      // (pushed by server createCasePaper — has its OWN subdoc _id different from casepaper_id_*)
      final patient = {
        'name': 'Test Patient',
        'casePapers': [
          {
            '_id': 'subdoc_id_1', // ← different from casepaper_id_1
            'paperType': '1',
            'caseId': 'casepaper_id_1', // ← links to standalone doc
            'data': {'date': '09/10/2026', 'paperType': 'Case Paper 1: Original Case Paper (Constitutional)'},
          },
          {
            '_id': 'subdoc_id_2',
            'paperType': '2',
            'caseId': 'casepaper_id_2',
            'data': {'date': '10/10/2026', 'paperType': 'Case Paper 2: Acute Case Paper'},
          },
        ],
      };

      final result = computePapers(
        fetchedPapers: fetchedPapers,
        isLoadingPapers: false,
        patient: patient,
      );

      expect(result.length, 2,
          reason: '2 case papers → 2 cards, NOT 4. '
              'fetchedPapers are authoritative; embedded snapshots must be ignored.');
    });

    test('REAL SCENARIO: while loading, returns empty (no flash of embedded)', () {
      final patient = {
        'casePapers': [
          {'_id': 'subdoc1', 'caseId': 'cp1'},
          {'_id': 'subdoc2', 'caseId': 'cp2'},
        ],
      };

      final result = computePapers(
        fetchedPapers: [],
        isLoadingPapers: true, // still loading
        patient: patient,
      );

      expect(result.length, 0,
          reason: 'Should return empty during loading to prevent flash');
    });

    test('Falls back to embedded when fetch returns empty and not loading', () {
      final patient = {
        'casePapers': [
          {'_id': 'subdoc1', 'caseId': 'cp1', 'paperType': '1'},
          {'_id': 'subdoc2', 'caseId': 'cp2', 'paperType': '2'},
        ],
      };

      final result = computePapers(
        fetchedPapers: [],
        isLoadingPapers: false,
        patient: patient,
      );

      expect(result.length, 2,
          reason: 'Falls back to embedded when no fetch result');
    });

    test('Deduplicates within fetchedPapers if server returns duplicates', () {
      final fetchedPapers = [
        {'_id': 'cp1', 'paperType': 'Case Paper 1', 'createdAt': '2026-10-10T10:00:00.000Z'},
        {'_id': 'cp1', 'paperType': 'Case Paper 1', 'createdAt': '2026-10-10T10:00:00.000Z'},
        {'_id': 'cp2', 'paperType': 'Case Paper 2', 'createdAt': '2026-10-09T10:00:00.000Z'},
      ];

      final result = computePapers(
        fetchedPapers: fetchedPapers,
        isLoadingPapers: false,
        patient: {},
      );

      expect(result.length, 2, reason: 'Deduplicates identical _ids');
    });

    test('Sorts newest first by createdAt', () {
      final fetchedPapers = [
        {'_id': 'old', 'createdAt': '2026-10-08T10:00:00.000Z'},
        {'_id': 'newest', 'createdAt': '2026-10-10T10:00:00.000Z'},
        {'_id': 'middle', 'createdAt': '2026-10-09T10:00:00.000Z'},
      ];

      final result = computePapers(
        fetchedPapers: fetchedPapers,
        isLoadingPapers: false,
        patient: {},
      );

      expect(result[0]['_id'], 'newest', reason: 'Newest paper first');
      expect(result[1]['_id'], 'middle');
      expect(result[2]['_id'], 'old', reason: 'Oldest paper last');
    });

    test('Embedded snapshots deduplicated by caseId when falling back', () {
      // Edge case: patient.casePapers has duplicate snapshots
      final patient = {
        'casePapers': [
          {'_id': 'sub1', 'caseId': 'cp1'},
          {'_id': 'sub2', 'caseId': 'cp1'}, // duplicate caseId
          {'_id': 'sub3', 'caseId': 'cp2'},
        ],
      };

      final result = computePapers(
        fetchedPapers: [],
        isLoadingPapers: false,
        patient: patient,
      );

      expect(result.length, 2,
          reason: 'Deduplicates embedded snapshots by caseId');
    });
  });
}
