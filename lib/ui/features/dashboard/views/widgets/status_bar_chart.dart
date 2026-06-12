import 'package:flutter/material.dart';

import '../../../projects/enums/project_status.dart';

class StatusBarChart extends StatelessWidget {
  final Map<ProjectStatus, int> data;

  const StatusBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (data.isEmpty) {
      return Text(
        'Sin proyectos todavía.',
        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
      );
    }

    final maxCount = data.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final status in ProjectStatus.values)
          if (data.containsKey(status)) ...[
            _BarRow(
              status: status,
              count: data[status]!,
              maxCount: maxCount,
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  final ProjectStatus status;
  final int count;
  final int maxCount;

  const _BarRow({
    required this.status,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fraction = maxCount == 0 ? 0.0 : count / maxCount;

    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 10,
              backgroundColor: scheme.surfaceContainerHighest,
              color: status.color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
