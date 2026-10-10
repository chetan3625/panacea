import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shared/case_paper_form_page_content.dart';
import '../../../controller/case_paper_controller.dart';

class CasePaperFormPageMobile extends StatelessWidget {
  const CasePaperFormPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CasePaperController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          'Case Intake',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: controller.saveCasePaper,
            tooltip: 'Save Draft',
          ),
        ],
      ),
      // Renders the shared content with vertically stacked children (isCompact: true)
      body: const CasePaperFormPageContent(isCompact: true),
    );
  }
}
