import 'package:flutter/material.dart';

import 'copy_field_suffix.dart';

/// Lista editable de chips (etiquetas, títulos alternativos, etc.).
class EditableChips extends StatefulWidget {
  final List<String> values;
  final String hint;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  /// Si se define, muestra un botón para copiar este texto al portapapeles.
  final String Function()? getCopyText;
  final String copyTooltip;
  final String copySnackbarMessage;

  /// Si es true, escribir una coma añade el chip automáticamente
  /// (y pegar "a, b, c" añade varios de una vez).
  final bool addOnComma;

  const EditableChips({
    super.key,
    required this.values,
    required this.hint,
    required this.onAdd,
    required this.onRemove,
    this.getCopyText,
    this.copyTooltip = 'Copiar',
    this.copySnackbarMessage = 'Copiado al portapapeles',
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

  Widget _buildInputField() {
    final addButton = IconButton(
      icon: const Icon(Icons.add, size: 18),
      tooltip: 'Añadir',
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: () => _submit(controller.text),
    );

    if (widget.getCopyText != null) {
      return TextFieldWithCopy(
        controller: controller,
        getCopyText: widget.getCopyText!,
        copyTooltip: widget.copyTooltip,
        copySnackbarMessage: widget.copySnackbarMessage,
        topRightActions: [addButton],
        onChanged: _onChanged,
        onSubmitted: _submit,
        decoration: InputDecoration(
          hintText: widget.hint,
          contentPadding: const EdgeInsets.fromLTRB(12, 0, 80, 0),
        ),
      );
    }

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: widget.hint,
        suffixIcon: addButton,
      ),
      onChanged: _onChanged,
      onSubmitted: _submit,
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
        _buildInputField(),
      ],
    );
  }
}
