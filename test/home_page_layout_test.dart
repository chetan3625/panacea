import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:panacea/controller/auth_session.dart';
import 'package:panacea/views/home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('desktop dashboard lays out without render exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    Get.testMode = true;
    Get.put(AuthSession(), permanent: true).token.value = 'test-token';

    await tester.pumpWidget(const GetMaterialApp(home: HomePage()));
    await tester.pump();

    expect(find.text('Clinic dashboard'), findsOneWidget);
    expect(find.text('Patient directory').first, findsOneWidget);
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
}
