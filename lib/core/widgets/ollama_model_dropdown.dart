import 'package:flutter/material.dart';

/// Selector de modelo Ollama que trunca nombres largos en espacios estrechos.
class OllamaModelDropdown extends StatelessWidget {
  final String? value;
  final List<String> models;
  final ValueChanged<String?> onChanged;
  final String hint;
  final bool isDense;

  const OllamaModelDropdown({
    super.key,
    required this.value,
    required this.models,
    required this.onChanged,
    this.hint = 'Selecciona un modelo',
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    final selected = models.contains(value) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      isDense: isDense,
      hint: Text(hint, overflow: TextOverflow.ellipsis, maxLines: 1),
      style: TextStyle(
        fontSize: isDense ? 13 : null,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      selectedItemBuilder: (context) => [
        for (final model in models) _modelLabel(model),
      ],
      items: [
        for (final model in models)
          DropdownMenuItem(value: model, child: _modelLabel(model)),
      ],
      onChanged: onChanged,
    );
  }

  static Widget _modelLabel(String model) => Text(
        model,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
}
