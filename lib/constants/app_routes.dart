import 'package:get/get.dart';
import '../views/login_page/login_page.dart';
import '../views/otp_screen/otp_screen.dart';
import '../views/home_page/home_page.dart';
import '../views/patient_form_page/patient_form_page.dart';
import '../views/case_papers_page/case_papers_page.dart';
import '../views/case_paper_form_page/case_paper_form_page.dart';
import '../controller/case_paper_controller.dart';
import '../views/splash_screen/splash_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const otp = '/otp';
  static const home = '/home';
  static const patientForm = '/patient-form';
  static const casePapers = '/case-papers';
  static const casePaperForm = '/case-paper-form';

  static final pages = [
    GetPage(name: splash, page: () => const SplashScreenPage()),
    GetPage(name: login, page: () => const LoginPage()),
    // FIX: Removed the mobileNumber parameter since GetX handles it via arguments now
    GetPage(name: otp, page: () => const OtpPage()),
    GetPage(name: home, page: () => const HomePage()),
    GetPage(name: patientForm, page: () => const PatientFormPage()),
    GetPage(name: casePapers, page: () => const CasePapersPage()),
    GetPage(
      name: casePaperForm,
      page: () => const CasePaperFormPage(),
      binding: BindingsBuilder(() {
        Get.put(CasePaperController());
      }),
    ),
  ];
}
