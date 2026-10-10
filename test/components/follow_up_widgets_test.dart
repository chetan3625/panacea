import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panacea/components/case_paper_components.dart';

void main() {
  group('WhereIsMyTrainTimeline Widget Tests', () {
    testWidgets('shows placeholder when visits list is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhereIsMyTrainTimeline(
              visits: const [],
              onTapVisit: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.text('No follow-up visits recorded yet. Click "+ Log Follow-Up Visit" below.'),
        findsOneWidget,
      );
    });

    testWidgets('triggers onTapVisit callback when visit item is tapped', (tester) async {
      Map<String, dynamic>? tappedVisit;
      final testVisits = [
        {
          'title': 'Follow-Up 1',
          'date': '05/10/2026',
          'time': '10:00 AM',
          'status': 'Better',
          'remedy': 'Arnica 30',
          'isFollowUp': true,
        }
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhereIsMyTrainTimeline(
              visits: testVisits,
              onTapVisit: (v) => tappedVisit = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Follow-Up 1'));
      await tester.pumpAndSettle();

      expect(tappedVisit, isNotNull);
      expect(tappedVisit?['status'], 'Better');
    });
  });

  group('FollowUpGrowthChart Widget Tests', () {
    testWidgets('calculates positive upgradation trend and renders CustomPaint', (tester) async {
      final visits = [
        {'date': '01/10/2026', 'status': 'Initial Intake'},
        {'date': '08/10/2026', 'status': 'Better (+40% Ameliorated)'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              child: FollowUpGrowthChart(visits: visits),
            ),
          ),
        ),
      );

      expect(find.text('Patient Health Growth & Recovery Trend'), findsOneWidget);
      expect(find.textContaining('Upgradation'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('handles downgraded trend when status is Worse / Aggravated', (tester) async {
      final visits = [
        {'date': '01/10/2026', 'status': 'Initial Intake'},
        {'date': '08/10/2026', 'status': 'Worse (-20% Aggravated)'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              child: FollowUpGrowthChart(visits: visits),
            ),
          ),
        ),
      );

      expect(find.textContaining('Downgradation'), findsOneWidget);
    });
  });
}