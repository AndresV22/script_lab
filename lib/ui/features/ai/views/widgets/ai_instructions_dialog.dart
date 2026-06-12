import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../enums/ai_task.dart';

/// Pide indicaciones adicionales opcionales antes de lanzar una tarea de IA.
/// Devuelve el texto ('' si se omite) o null si el usuario cancela.
class AiInstructionsDialog extends StatefulWidget {
  final AiTask task;

  const AiInstructionsDialog({super.key, required this.task});

  @override
  State<AiInstructionsDialog> createState() => _AiInstructionsDialogState();
}

class _AiInstructionsDialogState extends State<AiInstructionsDialog> {
  final ctrl = TextEditingController();

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.task.label),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Si quieres, añade indicaciones para guiar al modelo. '
              'Puedes dejarlo vacío.',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText:
                    'Ej. "tono más serio", "menciona el sorteo", "enfócate en principiantes"…',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () => Get.back(result: ctrl.text),
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const Text('Generar'),
        ),
      ],
    );
  }
}
