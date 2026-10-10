import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shared/case_paper_form_page_content.dart';
import '../../../controller/case_paper_controller.dart';

class CasePaperFormPageMobile extends StatelessWidget {
  const CasePaperFormPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CasePaperController>();

    Future<void> handleSave() async {
      final success = await controller.saveCasePaper();
      if (success) {
        Get.back(result: true);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.selectedCasePaperType.value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      // Renders the shared content with vertically stacked children (isCompact: true)
      body: const Padding(
        padding: EdgeInsets.only(bottom: 96),
        child: CasePaperFormPageContent(isCompact: true),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE4E9F1)))),
          child: Row(children: [
            IconButton(tooltip: 'Back', onPressed: Get.back, icon: const Icon(Icons.arrow_back)),
            const SizedBox(width: 8),
            Expanded(child: Obx(() => FilledButton.icon(
              onPressed: controller.isSaving.value ? null : handleSave,
              icon: controller.isSaving.value ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
              label: Text(controller.isSaving.value ? 'Saving…' : 'Save Case Paper', maxLines: 1, overflow: TextOverflow.ellipsis),
            ))),
          ]),
        ),
      ),
    );
  }
}
