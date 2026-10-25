import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/llm_provider.dart';
import '../../controller/settings_controller.dart';

/// Selector del proveedor de modelo.
class LlmProviderSelector extends StatelessWidget {
  const LlmProviderSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return Obx(() {
      final current = controller.settings.settings.value.llmProvider;
      final selected =
          LlmProvider.values.contains(current) ? current : LlmProvider.ollama;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<String>(
          showSelectedIcon: false,
          segments: [
            for (final id in LlmProvider.values)
              ButtonSegment(value: id, label: Text(LlmProvider.label(id))),
          ],
          selected: {selected},
          onSelectionChanged: controller.onProviderSelected,
        ),
      );
    });
  }
}
