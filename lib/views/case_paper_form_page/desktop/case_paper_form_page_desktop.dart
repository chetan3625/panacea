import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shared/case_paper_form_page_content.dart';
import '../../../controller/case_paper_controller.dart';

class CasePaperFormPageDesktop extends StatelessWidget {
  const CasePaperFormPageDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CasePaperController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          'Case Paper 1: Constitutional Intake',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          FilledButton.tonalIcon(
            onPressed: controller.saveCasePaper,
            icon: const Icon(Icons.save_rounded, size: 18),
            label: const Text('Save Draft'),
          ),
          const SizedBox(width: 24),
        ],
      ),
      // Renders the shared content with horizontal rows (isCompact: false)
      body: const CasePaperFormPageContent(isCompact: false),
    );
  }
}
