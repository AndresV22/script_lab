import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/ai_controller.dart';
import '../../enums/ai_task.dart';
import 'markdown_output.dart';

/// Diálogo con la respuesta en streaming para tareas lanzadas desde el editor
/// o desde la pestaña de información del proyecto.
class AiResultDialog extends StatelessWidget {
  const AiResultDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiController>();
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
                  Obx(() => Text(
                        controller.currentTask.value?.label ?? 'Asistente IA',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      )),
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
                final task = controller.currentTask.value;
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
                        onPressed: controller.copyOutput,
                        child: const Text('Copiar'),
                      ),
                      const SizedBox(width: 8),
                      ..._applyActions(context, controller, task),
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

  static List<Widget> _applyActions(
    BuildContext context,
    AiController controller,
    AiTask? task,
  ) {
    void closeDialog() {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }

    switch (task) {
      case AiTask.titles:
        return [
          OutlinedButton(
            onPressed: () {
              controller.applyTentativeTitle();
              closeDialog();
            },
            child: const Text('Usar como tentativo'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              controller.addTitlesToAlternatives();
              closeDialog();
            },
            child: const Text('Añadir alternativas'),
          ),
        ];
      case AiTask.tentativeTitle:
        return [
          FilledButton(
            onPressed: () {
              controller.applyTentativeTitle();
              closeDialog();
            },
            child: const Text('Usar como tentativo'),
          ),
        ];
      case AiTask.description:
        return [
          FilledButton(
            onPressed: () {
              controller.applyDescription();
              closeDialog();
            },
            child: const Text('Usar como descripción'),
          ),
        ];
      case AiTask.tags:
        return [
          OutlinedButton(
            onPressed: () {
              controller.applyTags(replace: true);
              closeDialog();
            },
            child: const Text('Reemplazar'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              controller.applyTags();
              closeDialog();
            },
            child: const Text('Añadir etiquetas'),
          ),
        ];
      case AiTask.notes:
        return [
          OutlinedButton(
            onPressed: () {
              controller.applyNotes(append: true);
              closeDialog();
            },
            child: const Text('Añadir al final'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              controller.applyNotes();
              closeDialog();
            },
            child: const Text('Reemplazar notas'),
          ),
        ];
      case AiTask.generateSection:
        return [
          FilledButton(
            onPressed: () {
              controller.insertIntoTargetSection();
              closeDialog();
            },
            child: const Text('Insertar en sección'),
          ),
        ];
      case AiTask.sectionCorrection:
        return [
          FilledButton(
            onPressed: () {
              closeDialog();
              controller.reviewSectionCorrection();
            },
            child: const Text('Revisar diferencias'),
          ),
        ];
      default:
        return const [];
    }
  }
}
