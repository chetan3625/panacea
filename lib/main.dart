import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'controller/auth_session.dart';
import 'constants/theme.dart';
import 'constants/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  if (!Get.isRegistered<AuthSession>()) {
    Get.put(AuthSession(), permanent: true);
  }
  await Get.find<AuthSession>().restore();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthSession>()) {
      Get.put(AuthSession(), permanent: true);
    }
    return GetMaterialApp(
      // Changed from MaterialApp
      title: 'Panacea Clinic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
