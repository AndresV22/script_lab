import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/generate_section_request.dart';

/// Estado del diálogo que pide el prompt de una sección.
class GenerateSectionDialogController extends GetxController {
  GenerateSectionDialogController({this.initialPrompt = ''});

  final String initialPrompt;
  late final TextEditingController promptCtrl;

  @override
  void onInit() {
    super.onInit();
    promptCtrl = TextEditingController(text: initialPrompt)
      ..selection = TextSelection.collapsed(offset: initialPrompt.length);
  }

  void cancel() => Get.back();

  void confirm() {
    Get.back(
      result: GenerateSectionRequest(prompt: promptCtrl.text.trim()),
    );
  }

  @override
  void onClose() {
    promptCtrl.dispose();
    super.onClose();
  }
}
