import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../ai/views/widgets/markdown_output.dart';
import '../../controller/structure_ai_controller.dart';

class StructureAiResultDialog extends StatelessWidget {
  const StructureAiResultDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StructureAiController>();
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 10, 10),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Generando estructura',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Obx(() => controller.isRunning.value
                      ? const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const SizedBox.shrink()),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Cerrar',
                    onPressed: () {
                      controller.cancel();
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  if (controller.error.value.isNotEmpty) {
                    return Text(
                      controller.error.value,
                      style: TextStyle(color: scheme.error),
                    );
                  }
                  if (controller.output.value.isEmpty) {
                    return Text(
                      'Esperando respuesta del modelo…',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    );
                  }
                  return MarkdownOutput(text: controller.output.value);
                }),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Obx(() {
                final running = controller.isRunning.value;
                final hasOutput = controller.output.value.isNotEmpty;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (running)
                      OutlinedButton.icon(
                        onPressed: controller.cancel,
                        icon: const Icon(Icons.stop, size: 16),
                        label: const Text('Detener'),
                      ),
                    if (!running && hasOutput) ...[
                      TextButton(
                        onPressed: () {
                          controller.cancel();
                          Get.back();
                        },
                        child: const Text('Descartar'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => controller.applyToEditor(context),
                        child: const Text('Usar estructura'),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
