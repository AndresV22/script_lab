import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/generate_full_script_request.dart';

/// Estado del diálogo que pide el prompt y la plantilla del guion completo.
class GenerateFullScriptDialogController extends GetxController {
  GenerateFullScriptDialogController({
    this.initialPrompt = '',
    this.initialStructureId = GenerateFullScriptRequest.projectSections,
  });

  final String initialPrompt;
  final String initialStructureId;
  late final TextEditingController promptCtrl;
  late final RxString selectedStructureId;

  @override
  void onInit() {
    super.onInit();
    promptCtrl = TextEditingController(text: initialPrompt)
      ..selection = TextSelection.collapsed(offset: initialPrompt.length);
    selectedStructureId = initialStructureId.obs;
  }

  void selectStructure(String? structureId) {
    selectedStructureId.value =
        structureId ?? GenerateFullScriptRequest.projectSections;
  }

  void cancel() => Get.back();

  void confirm() {
    Get.back(
      result: GenerateFullScriptRequest(
        prompt: promptCtrl.text.trim(),
        structureId: selectedStructureId.value,
      ),
    );
  }

  @override
  void onClose() {
    promptCtrl.dispose();
    super.onClose();
  }
}
