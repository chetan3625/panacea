import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:panacea/constants/app_routes.dart';
import 'package:panacea/controller/case_paper_controller.dart';
import 'package:panacea/views/case_paper_form_page/case_paper_form_page.dart';
import 'package:panacea/views/case_papers_page/case_papers_page.dart';
import 'package:panacea/views/patient_form_page/patient_form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('case paper frames render and expand on a phone viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    Get.testMode = true;

    await tester.pumpWidget(
      GetMaterialApp(initialRoute: '/', getPages: _routes('/case-papers-test')),
    );
    Get.toNamed(
      '/case-papers-test',
      arguments: {
        'token': 'test-token',
        'patient': {'_id': 'patient-1', 'name': 'Ada', 'gender': 'Female'},
      },
    );
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(find.text('New Case Paper'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('New Case Paper'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Case Paper 1').first);
    await tester.pumpAndSettle();

    expect(find.byType(CasePaperFormPage), findsOneWidget);
    expect(
      MediaQuery.sizeOf(tester.element(find.byType(CasePaperFormPage))).width,
      390,
    );
    expect(find.byType(ExpansionTile), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
    final scrollable = find.byType(Scrollable).first;
    final frameFive = find.textContaining('5. Physical Generals');
    await tester.scrollUntilVisible(frameFive, 150, scrollable: scrollable);
    await tester.tap(frameFive);
    await tester.pumpAndSettle();
    expect(find.text('Animals/Dogs/Snakes'), findsOneWidget);

    final frameSix = find.textContaining('6. Female History');
    await tester.scrollUntilVisible(frameSix, 150, scrollable: scrollable);
    await tester.tap(frameSix);
    await tester.pumpAndSettle();
    expect(find.text('Menses Concomitants'), findsOneWidget);

    final frameThree = find.textContaining('3. Past');
    await tester.scrollUntilVisible(frameThree, -150, scrollable: scrollable);
    await tester.tap(frameThree);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Typhoid'));
    await tester.pumpAndSettle();

    await tester.drag(scrollable, const Offset(0, 1500));
    await tester.pumpAndSettle();
    expect(find.byType(CasePaperFormPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    Get.back();
    await tester.pumpAndSettle();
    Get.toNamed(
      '/case-papers-test',
      arguments: {
        'token': 'test-token',
        'patient': {'_id': 'patient-1', 'name': 'Ada', 'gender': 'Female'},
      },
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Case Paper'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Case Paper 1').first);
    await tester.pumpAndSettle();
    expect(find.byType(CasePaperFormPage), findsOneWidget);

    final exceptions = <Object>[];
    Object? exception;
    while ((exception = tester.takeException()) != null) {
      exceptions.add(exception!);
    }
    expect(exceptions, isEmpty);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    Get.reset();
  });

  testWidgets('patient registration offers a case paper shortcut', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    Get.testMode = true;

    await tester.pumpWidget(const GetMaterialApp(home: PatientFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Save & start Case Paper'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    Get.reset();
  });

  testWidgets('case paper form builds eight mobile accordions directly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    Get.testMode = true;
    Get.put(CasePaperController());

    await tester.pumpWidget(const MaterialApp(home: CasePaperFormPage()));
    await tester.pumpAndSettle();

    expect(find.byType(ExpansionTile), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    Get.reset();
  });

  testWidgets('case paper list opens the editor on a desktop viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    Get.testMode = true;

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/',
        getPages: _routes('/case-papers-desktop-test'),
      ),
    );
    Get.toNamed(
      '/case-papers-desktop-test',
      arguments: {
        'token': 'test-token',
        'patient': {'_id': 'patient-1', 'name': 'Ada'},
      },
    );
    await tester.pumpAndSettle();

    expect(find.text('New Case Paper'), findsOneWidget);
    await tester.tap(find.text('New Case Paper'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Case Paper 1').first);
    await tester.pumpAndSettle();
    expect(find.byType(CasePaperFormPage), findsOneWidget);
    expect(find.textContaining('Case Paper 1'), findsWidgets);
    expect(find.text('Save Case Paper'), findsOneWidget);
    final patientNameField = find.byType(TextFormField).first;
    await tester.ensureVisible(patientNameField);
    await tester.enterText(patientNameField, 'Ada Lovelace');
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(CasePaperFormPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    Get.reset();
  });
}

List<GetPage<dynamic>> _routes(String listRoute) => [
  GetPage(name: '/', page: () => const Scaffold()),
  GetPage(name: listRoute, page: () => const CasePapersPage()),
  GetPage(
    name: AppRoutes.casePaperForm,
    page: () => const CasePaperFormPage(),
    binding: BindingsBuilder(() {
      Get.put(CasePaperController());
    }),
  ),
];
