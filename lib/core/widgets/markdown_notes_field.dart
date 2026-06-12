import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'copy_field_suffix.dart';

/// Campo de notas con vista previa Markdown y modo edición.
class MarkdownNotesField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration? decoration;
  final int minLines;
  final int maxLines;
  final bool enableCopy;

  const MarkdownNotesField({
    super.key,
    required this.controller,
    this.decoration,
    this.minLines = 5,
    this.maxLines = 14,
    this.enableCopy = false,
  });

  @override
  State<MarkdownNotesField> createState() => _MarkdownNotesFieldState();
}

class _MarkdownNotesFieldState extends State<MarkdownNotesField> {
  late bool editing;

  @override
  void initState() {
    super.initState();
    editing = widget.controller.text.trim().isEmpty;
  }

  MarkdownStyleSheet _styleSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: const TextStyle(fontSize: 14, height: 1.65),
      listBullet: const TextStyle(fontSize: 14, height: 1.65),
      h1: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      h2: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      h3: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
      blockquoteDecoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      code: TextStyle(
        fontSize: 13,
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      ),
    );
  }

  CopyFieldSuffix? get _copyButton => widget.enableCopy
      ? CopyFieldSuffix(
          getText: () => widget.controller.text,
          tooltip: 'Copiar notas',
          snackbarMessage: 'Notas copiadas al portapapeles',
        )
      : null;

  InputDecoration _editDecoration() {
    final base = widget.decoration ?? const InputDecoration();
    if (_copyButton == null) return base;
    return base.copyWith(
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 44, 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final copyButton = _copyButton;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedButton<bool>(
            style: const ButtonStyle(
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 8)),
              textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11)),
            ),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Vista previa'),
                icon: Icon(Icons.visibility_outlined, size: 13),
              ),
              ButtonSegment(
                value: true,
                label: Text('Editar'),
                icon: Icon(Icons.edit_outlined, size: 13),
              ),
            ],
            selected: {editing},
            onSelectionChanged: (selection) =>
                setState(() => editing = selection.first),
          ),
        ),
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final text = widget.controller.text;

            if (editing) {
              final field = TextField(
                controller: widget.controller,
                minLines: widget.minLines,
                maxLines: widget.maxLines,
                decoration: _editDecoration(),
              );
              if (copyButton == null) return field;
              return CopyFieldOverlay(copyButton: copyButton, child: field);
            }

            if (text.trim().isEmpty) {
              final emptyField = InkWell(
                onTap: () => setState(() => editing = true),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.decoration?.hintText ??
                        'Sin notas. Pulsa para escribir…',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
              if (copyButton == null) return emptyField;
              return CopyFieldOverlay(copyButton: copyButton, child: emptyField);
            }

            final preview = SelectionArea(
              child: MarkdownBody(
                data: text,
                styleSheet: _styleSheet(context),
              ),
            );
            if (copyButton == null) return preview;

            return CopyFieldOverlay(
              copyButton: copyButton,
              child: Material(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: preview,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
