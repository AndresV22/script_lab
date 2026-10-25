import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/labeled_field.dart';
import '../../controller/generate_section_dialog_controller.dart';
import '../../models/generate_section_request.dart';

/// Pide el prompt para generar el texto de una sección.
class GenerateSectionDialog extends StatelessWidget {
  const GenerateSectionDialog({super.key, required this.sectionTitle});

  final String sectionTitle;

  static Future<GenerateSectionRequest?> show({
    required String sectionTitle,
    String initialPrompt = '',
  }) {
    Get.put(GenerateSectionDialogController(initialPrompt: initialPrompt));
    return Get.dialog<GenerateSectionRequest>(
      GenerateSectionDialog(sectionTitle: sectionTitle),
    ).whenComplete(Get.delete<GenerateSectionDialogController>);
  }

  void _cancel() => Get.find<GenerateSectionDialogController>().cancel();

  void _confirm() => Get.find<GenerateSectionDialogController>().confirm();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GenerateSectionDialogController>();
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text('Generar "$sectionTitle"'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'El prompt se guarda para esta sección. Puedes generar de nuevo '
              'sin volver a escribirlo.',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'Prompt',
              helper:
                  'Si lo escribes, el texto de la sección se crea desde cero '
                  'con este prompt. Puedes dejarlo vacío.',
              child: TextField(
                controller: controller.promptCtrl,
                autofocus: true,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText:
                      'Ej. Explica el precio con un ejemplo y cierra con una duda para el espectador.',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _cancel, child: const Text('Cancelar')),
        FilledButton.icon(
          onPressed: _confirm,
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const Text('Generar'),
        ),
      ],
    );
  }
}
