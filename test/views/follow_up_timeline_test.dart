import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:panacea/components/case_paper_components.dart';
import 'package:panacea/controller/case_paper_controller.dart';
import 'package:panacea/views/case_papers_page/case_papers_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  final mockPatient = {
    '_id': 'patient-101',
    'name': 'Rahul Sharma',
    'gender': 'Male',
    'casePapers': [
      {
        '_id': 'paper-1',
        'paperType': 'Case Paper 1: Original Case Paper (Constitutional)',
        'data': {
          'date': '01/10/2026',
          'time': '10:00 AM',
          'paperType': 'Case Paper 1 (Original)',
          'chiefComplaint': 'Chronic Migraine & Acidity',
          'remedy': 'Natrum Mur 200C',
          'isFollowUp': false,
        },
      },
      {
        '_id': 'paper-2',
        'paperType': 'Follow-Up Visit',
        'data': {
          'date': '08/10/2026',
          'time': '11:15 AM',
          'paperType': 'Follow-Up Visit',
          'chiefComplaint': 'Headaches decreased in intensity',
          'status': 'Better (+40% Ameliorated)',
          'remedy': 'Sac Lac 30',
          'isFollowUp': true,
        },
      },
    ],
  };

  testWidgets('renders WhereIsMyTrain vertical timeline with visit cards', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;

    Get.put(CasePaperController());

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold()),
          GetPage(
            name: '/case-papers',
            page: () => const CasePapersPage(),
          ),
        ],
      ),
    );

    Get.toNamed(
      '/case-papers',
      arguments: {'token': 'test-token', 'patient': mockPatient},
    );
    await tester.pumpAndSettle();

    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('Patient Visit & Follow-Up Timeline'), findsOneWidget);
    expect(find.byType(WhereIsMyTrainTimeline), findsOneWidget);
    expect(find.text('Case Paper 1 (Original)'), findsOneWidget);
    expect(find.text('Follow-Up Visit'), findsOneWidget);
    expect(find.textContaining('Ameliorated'), findsWidgets);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('logs a new consolidated follow-up visit and appends to the timeline', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;

    Get.put(CasePaperController());

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold()),
          GetPage(
            name: '/case-papers',
            page: () => const CasePapersPage(),
          ),
        ],
      ),
    );

    Get.toNamed(
      '/case-papers',
      arguments: {'token': 'test-token', 'patient': mockPatient},
    );
    await tester.pumpAndSettle();

    final logButton = find.text('Log Follow-Up Visit');
    expect(logButton, findsOneWidget);
    await tester.tap(logButton);
    await tester.pumpAndSettle();

    expect(find.text('Log Consolidated Follow-Up'), findsOneWidget);

    final chip70 = find.text('Better (+70% Ameliorated)');
    expect(chip70, findsOneWidget);
    await tester.tap(chip70);
    await tester.pumpAndSettle();

    final notesInput = find.widgetWithText(TextFormField, 'Clinical Notes & Symptom Changes');
    await tester.enterText(notesInput, 'Acidity completely resolved; mild headache remains');
    await tester.pump();

    await tester.tap(find.text('Save Follow-Up'));
    await tester.pumpAndSettle();

    expect(find.text('Acidity completely resolved; mild headache remains'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('tapping visit card opens modal with recovery chart and switches segments', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;

    Get.put(CasePaperController());

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold()),
          GetPage(
            name: '/case-papers',
            page: () => const CasePapersPage(),
          ),
        ],
      ),
    );

    Get.toNamed(
      '/case-papers',
      arguments: {'token': 'test-token', 'patient': mockPatient},
    );
    await tester.pumpAndSettle();

    final visitCard = find.text('Follow-Up Visit').first;
    expect(visitCard, findsOneWidget);
    await tester.tap(visitCard);
    await tester.pumpAndSettle();

    expect(find.text('Growth & Recovery Graph'), findsOneWidget);
    expect(find.text('Gathered Details & Notes'), findsOneWidget);
    expect(find.byType(FollowUpGrowthChart), findsOneWidget);

    await tester.tap(find.text('Gathered Details & Notes'));
    await tester.pumpAndSettle();

    expect(find.text('Remedy & Posology Plan'), findsOneWidget);

    await tester.tap(find.text('Close Follow-Up Record'));
    await tester.pumpAndSettle();
    expect(find.text('Gathered Details & Notes'), findsNothing);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}