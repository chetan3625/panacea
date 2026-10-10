// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:panacea/main.dart';
import 'package:panacea/views/patient_form_page/patient_form_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:panacea/controller/otp_controller.dart';
import 'package:panacea/controller/auth_session.dart';
import 'package:panacea/constants/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost:5000/api');
    Get.testMode = true;
    if (!Get.isRegistered<AuthSession>()) {
      Get.put(AuthSession(), permanent: true);
    }
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('navigates through login, OTP, dashboard, and patient form', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Sign Up'), findsNothing);
    await tester.enterText(find.byType(TextFormField).first, '9876543210');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');

    Get.offAllNamed(
      AppRoutes.otp,
      arguments: {'mobile': '9876543210', 'otp': '1111', 'token': 'test-token'},
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.textContaining('Verify'), findsWidgets);
    final otpController = Get.find<OtpController>();
    for (var index = 0; index < 4; index++) {
      otpController.otpControllers[index].text = '1';
    }
    await tester.pump();
    await tester.ensureVisible(find.text('Verify Code'));
    await tester.tap(find.text('Verify Code'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Dr. Clinic Dashboard'), findsOneWidget);
    final addBtn = find.text('+ Add New Patient');
    await tester.ensureVisible(addBtn);
    await tester.tap(addBtn);
    await tester.pumpAndSettle();
    expect(find.text('New Consultation'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Dr. Clinic Dashboard'), findsOneWidget);
  });

  testWidgets('patient form stays laid out while editing and adding medicine', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: PatientFormPage()));

    final mobileField = find.byType(TextFormField).first;
    await tester.tap(mobileField);
    await tester.enterText(mobileField, '9876543210');
    await tester.pump();

    await tester.ensureVisible(find.text('Add medicine'));
    await tester.tap(find.text('Add medicine'));
    await tester.pumpAndSettle();

    expect(find.text('New Consultation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
