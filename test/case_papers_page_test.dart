import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:panacea/constants/app_routes.dart';
import 'package:panacea/controller/case_paper_controller.dart';
import 'package:panacea/views/case_paper_form_page.dart';
import 'package:panacea/views/case_papers_page.dart';
import 'package:panacea/views/patient_form_page.dart';
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

    expect(find.text('New Case Paper 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('New Case Paper 1'));
    await tester.pumpAndSettle();

    expect(find.byType(CasePaperFormPage), findsOneWidget);
    expect(
      MediaQuery.sizeOf(tester.element(find.byType(CasePaperFormPage))).width,
      390,
    );
    expect(find.byType(ExpansionTile), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
    final frameFive = find.text(CasePaperController.frames[4]);
    await tester.scrollUntilVisible(
      frameFive,
      260,
      scrollable: _verticalScrollable,
    );
    await tester.tap(frameFive);
    await tester.pumpAndSettle();
    expect(find.text('Animals'), findsOneWidget);
    final frameSix = find.text(CasePaperController.frames[5]);
    await tester.scrollUntilVisible(
      frameSix,
      260,
      scrollable: _verticalScrollable,
    );
    await tester.tap(frameSix);
    await tester.pumpAndSettle();
    expect(find.text('Flow character'), findsOneWidget);
    expect(find.text('Headache'), findsOneWidget);
    final frameThree = find.text(CasePaperController.frames[2]);
    await tester.scrollUntilVisible(
      frameThree,
      260,
      scrollable: _verticalScrollable,
    );
    await tester.tap(frameThree);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Typhoid'));
    await tester.pumpAndSettle();
    expect(find.text('Add to timeline'), findsOneWidget);
    await tester.tap(find.text('Add to timeline'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Typhoid'), findsWidgets);
    final frameOneAgain = find.text(CasePaperController.frames[0]);
    await tester.scrollUntilVisible(
      frameOneAgain,
      -260,
      scrollable: _verticalScrollable,
    );
    await tester.tap(frameOneAgain);
    await tester.pumpAndSettle();
    final patientNameField = find.byType(TextFormField).at(1);
    await tester.ensureVisible(patientNameField);
    await tester.enterText(patientNameField, 'Ada Lovelace');
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('panacea.casePaperDraft.patient-1.new'),
      contains('Ada Lovelace'),
    );
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
    await tester.tap(find.text('New Case Paper 1'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .initialValue,
      'Ada Lovelace',
    );

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

    expect(find.text('Save & start Case Paper 1'), findsOneWidget);
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

    expect(find.text('New Case Paper 1'), findsOneWidget);
    await tester.tap(find.text('New Case Paper 1'));
    await tester.pumpAndSettle();
    expect(find.byType(CasePaperFormPage), findsOneWidget);
    expect(find.textContaining('/8 completed'), findsOneWidget);
    expect(find.textContaining('Draft'), findsWidgets);
    expect(find.text('Switch Case Paper'), findsOneWidget);
    expect(find.text('Export Detailed PDF'), findsOneWidget);
    expect(find.text('Save Draft'), findsOneWidget);
    final patientNameField = find.byType(TextFormField).at(1);
    await tester.ensureVisible(patientNameField);
    await tester.enterText(patientNameField, 'Ada Lovelace');
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('Draft Auto-saved'), findsOneWidget);
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
    binding: BindingsBuilder(() => Get.put(CasePaperController())),
  ),
];

Finder get _verticalScrollable => find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;
