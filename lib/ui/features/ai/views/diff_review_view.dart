import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/diff_controller.dart';

/// Comparador entre el texto original y la propuesta de la IA.
/// Permite aceptar todo, rechazar todo o alternar cambios individuales
/// haciendo clic sobre cada fragmento resaltado.
class DiffReviewView extends StatelessWidget {
  final DiffController controller;
  final String title;
  final ValueChanged<String>? onApply;

  const DiffReviewView({
    super.key,
    required this.controller,
    this.title = 'Revisar cambios',
    this.onApply,
  });

  static Future<void> show({
    required String original,
    required String proposed,
    String title = 'Revisar cambios',
    ValueChanged<String>? onApply,
  }) {
    return Get.dialog(
      DiffReviewView(
        controller: DiffController(original: original, proposed: proposed),
        title: title,
        onApply: onApply,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Obx(() => Text(
                        '${controller.acceptedCount} de ${controller.changeCount} cambios aceptados',
                        style: TextStyle(
                            fontSize: 12, color: scheme.onSurfaceVariant),
                      )),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Cerrar',
                    onPressed: Get.back,
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  _Legend(
                      color: Colors.green, label: 'Agregado por la IA'),
                  const SizedBox(width: 16),
                  _Legend(color: Colors.red, label: 'Eliminado del original'),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.acceptAll,
                    child: const Text('Aceptar todo'),
                  ),
                  TextButton(
                    onPressed: controller.rejectAll,
                    child: const Text('Rechazar todo'),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  controller.accepted.length;
                  return _DiffText(controller: controller);
                }),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Haz clic en un cambio para aceptarlo o rechazarlo.',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  TextButton(
                      onPressed: Get.back, child: const Text('Cancelar')),
                  if (onApply != null) ...[
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final result = controller.result;
                        Get.back();
                        onApply!(result);
                      },
                      child: const Text('Aplicar cambios'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.25),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _DiffText extends StatelessWidget {
  final DiffController controller;

  const _DiffText({required this.controller});

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(height: 1.7, fontSize: 14.5);
    final spans = <InlineSpan>[];

    for (var i = 0; i < controller.diffs.length; i++) {
      final diff = controller.diffs[i];
      if (diff.operation == DIFF_EQUAL) {
        spans.add(TextSpan(text: diff.text, style: baseStyle));
        continue;
      }
      final isInsert = diff.operation == DIFF_INSERT;
      final isAccepted = controller.accepted[i] == true;
      final color = isInsert ? Colors.green : Colors.red;
      // Un cambio activo se resalta; uno descartado se atenúa.
      final active = isInsert ? isAccepted : isAccepted;
      spans.add(TextSpan(
        text: diff.text,
        recognizer: TapGestureRecognizer()
          ..onTap = () => controller.toggle(i),
        style: baseStyle?.copyWith(
          backgroundColor: color.withValues(alpha: active ? 0.18 : 0.05),
          color: active ? null : Theme.of(context).disabledColor,
          decoration: isInsert
              ? (active ? null : TextDecoration.lineThrough)
              : (active ? TextDecoration.lineThrough : null),
          decorationColor: color,
        ),
      ));
    }
    return SelectionArea(child: Text.rich(TextSpan(children: spans)));
  }
}
