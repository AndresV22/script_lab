import 'package:flutter/material.dart';

class DashboardFooter extends StatelessWidget {
  const DashboardFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
        color: scheme.surfaceContainerLowest,
      ),
      alignment: Alignment.center,
      child: Text('Creado por AndresV22 © 2026', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
    );
  }
}
