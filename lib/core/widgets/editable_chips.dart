import 'package:flutter/material.dart';

/// Lista editable de chips (etiquetas, títulos alternativos, etc.).
class EditableChips extends StatefulWidget {
  final List<String> values;
  final String hint;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  /// Si es true, escribir una coma añade el chip automáticamente
  /// (y pegar "a, b, c" añade varios de una vez).
  final bool addOnComma;

  const EditableChips({
    super.key,
    required this.values,
    required this.hint,
    required this.onAdd,
    required this.onRemove,
    this.addOnComma = false,
  });

  @override
  State<EditableChips> createState() => _EditableChipsState();
}

class _EditableChipsState extends State<EditableChips> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      widget.onAdd(trimmed);
      controller.clear();
    }
  }

  void _onChanged(String value) {
    if (!widget.addOnComma || !value.contains(',')) return;
    final parts = value.split(',');
    // Lo que sigue a la última coma se queda en el campo para seguir escribiendo.
    final remainder = parts.removeLast();
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty) widget.onAdd(trimmed);
    }
    controller.value = TextEditingValue(
      text: remainder,
      selection: TextSelection.collapsed(offset: remainder.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.values.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < widget.values.length; i++)
                  Chip(
                    label: Text(widget.values[i]),
                    onDeleted: () => widget.onRemove(i),
                    deleteIcon: const Icon(Icons.close, size: 14),
                  ),
              ],
            ),
          ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add, size: 18),
              tooltip: 'Añadir',
              onPressed: () => _submit(controller.text),
            ),
          ),
          onChanged: _onChanged,
          onSubmitted: _submit,
        ),
      ],
    );
  }
}
