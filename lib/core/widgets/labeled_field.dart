import 'package:flutter/material.dart';

/// Campo con etiqueta superior, estilo formulario sobrio.
class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? helper;

  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 2),
          Text(
            helper!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant, fontSize: 11.5),
          ),
        ],
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
