import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Muestra la salida del modelo renderizada como Markdown, con un
/// conmutador para ver el texto en crudo.
class MarkdownOutput extends StatefulWidget {
  final String text;

  /// Padding del contenido (el toggle queda alineado a la derecha encima).
  final EdgeInsets padding;

  const MarkdownOutput({
    super.key,
    required this.text,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<MarkdownOutput> createState() => _MarkdownOutputState();
}

class _MarkdownOutputState extends State<MarkdownOutput> {
  bool raw = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(widget.padding.left, 0, widget.padding.right, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SegmentedButton<bool>(
                style: const ButtonStyle(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 8)),
                  textStyle:
                      WidgetStatePropertyAll(TextStyle(fontSize: 11)),
                ),
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Estilizado'),
                    icon: Icon(Icons.text_fields, size: 13),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Markdown'),
                    icon: Icon(Icons.code, size: 13),
                  ),
                ],
                selected: {raw},
                onSelectionChanged: (selection) =>
                    setState(() => raw = selection.first),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: widget.padding,
          child: raw
              ? SelectionArea(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      fontFamily: 'monospace',
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              : SelectionArea(
                  child: MarkdownBody(
                    data: widget.text,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                      p: const TextStyle(fontSize: 14, height: 1.65),
                      listBullet: const TextStyle(fontSize: 14, height: 1.65),
                      h1: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w700),
                      h2: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                      h3: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w700),
                      blockquoteDecoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      code: TextStyle(
                        fontSize: 13,
                        backgroundColor: scheme.surfaceContainerHighest
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
