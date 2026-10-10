import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/case_paper_controller.dart';
import 'desktop/case_paper_form_page_desktop.dart';
import 'mobile/case_paper_form_page_mobile.dart';

class CasePaperFormPage extends StatelessWidget {
  const CasePaperFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller once for the entire form lifecycle
    Get.put(CasePaperController());

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return const CasePaperFormPageDesktop();
        } else {
          return const CasePaperFormPageMobile();
        }
      },
    );
  }
}
