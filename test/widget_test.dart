// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:panacea/main.dart';
import 'package:panacea/views/patient_form_page.dart';

void main() {
  testWidgets('navigates through login, OTP, dashboard, and patient form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Sign Up'), findsNothing);
    await tester.enterText(find.byType(TextFormField).first, '9876543210');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Verify Account'), findsOneWidget);
    for (var index = 0; index < 4; index++) {
      final otpField = find.byType(TextFormField).at(index);
      await tester.tap(otpField);
      await tester.enterText(otpField, '1');
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Verify Code'));
    await tester.tap(find.text('Verify Code'));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Clinic Dashboard'), findsOneWidget);
    await tester.tap(find.text('+ Add New Patient'));
    await tester.pumpAndSettle();
    expect(find.text('New Consultation'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('View / Edit').first);
    await tester.pumpAndSettle();
    expect(find.text('New Consultation'), findsOneWidget);
  });

  testWidgets('patient form stays laid out while editing and adding medicine', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PatientFormPage()),
    );

    final mobileField = find.byType(TextFormField).first;
    await tester.tap(mobileField);
    await tester.enterText(mobileField, '9876543210');
    await tester.pump();

    await tester.ensureVisible(find.text('Add Medicine'));
    await tester.tap(find.text('Add Medicine'));
    await tester.pumpAndSettle();

    expect(find.text('New Consultation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
