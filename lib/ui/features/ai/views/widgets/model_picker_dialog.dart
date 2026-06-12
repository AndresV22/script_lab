import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/ollama_service.dart';

/// Diálogo para elegir un modelo de Ollama al vuelo cuando se intenta
/// generar con IA sin un modelo seleccionado.
class ModelPickerDialog extends StatefulWidget {
  final void Function(String model, bool saveAsDefault) onSelected;
  final VoidCallback onCancel;

  const ModelPickerDialog({
    super.key,
    required this.onSelected,
    required this.onCancel,
  });

  @override
  State<ModelPickerDialog> createState() => _ModelPickerDialogState();
}

class _ModelPickerDialogState extends State<ModelPickerDialog> {
  String? selected;
  bool saveAsDefault = true;

  @override
  Widget build(BuildContext context) {
    final models = OllamaService.to.models;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Selecciona un modelo'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No hay un modelo de IA seleccionado. Elige uno para continuar.',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final model in models)
                      RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(model,
                            style: const TextStyle(fontSize: 13.5),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                        value: model,
                        // ignore: deprecated_member_use
                        groupValue: selected,
                        // ignore: deprecated_member_use
                        onChanged: (v) => setState(() => selected = v),
                      ),
                  ],
                ),
              ),
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Guardar como modelo predeterminado',
                  style: TextStyle(fontSize: 13)),
              value: saveAsDefault,
              onChanged: (v) => setState(() => saveAsDefault = v ?? true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            widget.onCancel();
          },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: selected == null
              ? null
              : () {
                  Get.back();
                  widget.onSelected(selected!, saveAsDefault);
                },
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}
