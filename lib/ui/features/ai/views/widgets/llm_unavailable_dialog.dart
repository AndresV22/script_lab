import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/llm_provider.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/services/settings_service.dart';

/// Aviso cuando no hay proveedor ni modelos para generar.
class LlmUnavailableDialog extends StatelessWidget {
  const LlmUnavailableDialog({super.key});

  static void show() {
    Get.dialog(const LlmUnavailableDialog());
  }

  void close() => Get.back();

  void openSettings() {
    Get.back();
    Get.offAllNamed(AppRoutes.settings);
  }

  @override
  Widget build(BuildContext context) {
    final provider = SettingsService.to.settings.value.llmProvider;
    return AlertDialog(
      title: Text(LlmProvider.unavailableTitle(provider)),
      content: SizedBox(
        width: 400,
        child: Text(LlmProvider.unavailableMessage(provider)),
      ),
      actions: [
        TextButton(onPressed: close, child: const Text('Cerrar')),
        FilledButton(onPressed: openSettings, child: const Text('Ir a Ajustes')),
      ],
    );
  }
}
