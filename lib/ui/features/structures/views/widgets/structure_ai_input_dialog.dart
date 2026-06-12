import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StructureAiInput {
  final String description;
  final String sectionsHint;

  const StructureAiInput({
    required this.description,
    required this.sectionsHint,
  });
}

/// Pide al usuario una descripción de la estructura y las secciones deseadas.
class StructureAiInputDialog extends StatefulWidget {
  const StructureAiInputDialog({super.key});

  @override
  State<StructureAiInputDialog> createState() => _StructureAiInputDialogState();
}

class _StructureAiInputDialogState extends State<StructureAiInputDialog> {
  final descriptionCtrl = TextEditingController();
  final sectionsCtrl = TextEditingController();

  @override
  void dispose() {
    descriptionCtrl.dispose();
    sectionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Crear estructura con IA'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Describe la plantilla y las secciones que necesitas. '
              'La IA generará nombres y descripciones para guiar la escritura del guion.',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionCtrl,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción de la estructura',
                hintText:
                    'Ej. Plantilla para reviews de relojes de lujo, tono entusiasta…',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: sectionsCtrl,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Secciones deseadas (opcional)',
                hintText:
                    'Ej. Hook, Presentación del reloj, Diseño, Movimiento, Veredicto…',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancelar')),
        FilledButton.icon(
          onPressed: () => Get.back(
            result: StructureAiInput(
              description: descriptionCtrl.text,
              sectionsHint: sectionsCtrl.text,
            ),
          ),
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const Text('Generar'),
        ),
      ],
    );
  }
}
