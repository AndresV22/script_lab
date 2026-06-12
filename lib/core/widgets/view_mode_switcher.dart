import 'package:flutter/material.dart';

/// Conmutador de vista (cards/lista) con selector de tamaño de card.
class ViewModeSwitcher extends StatelessWidget {
  /// 'grid' | 'list'
  final String mode;

  /// 's' | 'm' | 'l'
  final String cardSize;
  final ValueChanged<String> onModeChanged;
  final ValueChanged<String> onSizeChanged;

  const ViewModeSwitcher({
    super.key,
    required this.mode,
    required this.cardSize,
    required this.onModeChanged,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mode == 'grid') ...[
          SegmentedButton<String>(
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 10)),
            ),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 's', label: Text('S')),
              ButtonSegment(value: 'm', label: Text('M')),
              ButtonSegment(value: 'l', label: Text('L')),
            ],
            selected: {cardSize},
            onSelectionChanged: (selection) => onSizeChanged(selection.first),
          ),
          const SizedBox(width: 10),
        ],
        SegmentedButton<String>(
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding:
                WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
          ),
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: 'grid',
              icon: Icon(Icons.grid_view_outlined, size: 16),
              tooltip: 'Vista de cards',
            ),
            ButtonSegment(
              value: 'list',
              icon: Icon(Icons.view_list_outlined, size: 16),
              tooltip: 'Vista de lista',
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) => onModeChanged(selection.first),
        ),
      ],
    );
  }
}

/// Extents de grid según el tamaño de card seleccionado.
({double width, double height}) cardExtents(
  String size, {
  required ({double width, double height}) s,
  required ({double width, double height}) m,
  required ({double width, double height}) l,
}) =>
    switch (size) {
      's' => s,
      'l' => l,
      _ => m,
    };
