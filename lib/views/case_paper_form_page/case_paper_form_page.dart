import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/case_paper_controller.dart';
import 'desktop/case_paper_form_page_desktop.dart';
import 'mobile/case_paper_form_page_mobile.dart';

class CasePaperFormPage extends StatefulWidget {
  const CasePaperFormPage({super.key});

  @override
  State<CasePaperFormPage> createState() => _CasePaperFormPageState();
}

class _CasePaperFormPageState extends State<CasePaperFormPage> {
  late final CasePaperController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CasePaperController>()
        ? Get.find<CasePaperController>()
        : Get.put(CasePaperController());

    final args = Get.arguments;
    if (args is Map) {
      final patient = args['patient'];
      final patientId = args['patientId']?.toString() ??
          (patient is Map ? patient['_id']?.toString() : null) ??
          '';
      final paper = args['paper'];
      final casePaperId = args['casePaperId']?.toString() ??
          (paper is Map
              ? (paper['_id']?.toString() ?? paper['caseId']?.toString())
              : null);
      final paperType = args['paperType']?.toString();

      if (casePaperId != null && casePaperId.isNotEmpty) {
        if (paper is Map && paper.length > 3) {
          controller.loadCasePaper(Map<String, dynamic>.from(paper), patientId);
        } else {
          controller.currentPatientId.value = patientId;
          controller.fetchCasePaperById(casePaperId);
        }
      } else {
        controller.resetForm(patientId, paperType: paperType);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return const CasePaperFormPageDesktop();
        } else {
          return const CasePaperFormPageMobile();
        }
      },
    );
  }
}
