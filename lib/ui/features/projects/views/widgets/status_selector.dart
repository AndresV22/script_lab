import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/project_detail_controller.dart';
import '../../controller/projects_controller.dart';
import '../../enums/project_status.dart';
import '../../models/project.dart';

/// Pastilla de estado clicable para cambiar el estado desde la lista de proyectos.
class ProjectStatusPicker extends StatelessWidget {
  final Project project;
  final bool compact;

  const ProjectStatusPicker({
    super.key,
    required this.project,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectsController>();
    return PopupMenuButton<ProjectStatus>(
      tooltip: 'Cambiar estado',
      onSelected: (status) => controller.setStatus(project, status),
      itemBuilder: (_) => [
        for (final status in ProjectStatus.values)
          PopupMenuItem(
            value: status,
            child: Row(
              children: [
                Expanded(child: StatusMenuRow(status: status)),
                if (status == project.status)
                  const Icon(Icons.check, size: 16),
              ],
            ),
          ),
      ],
      child: StatusBadge(
        status: project.status,
        showChevron: true,
        compact: compact,
      ),
    );
  }
}

/// Pastilla con el estado del proyecto abierto; al pulsarla muestra un menú
/// para cambiarlo. Se usa en el AppBar del detalle y en la pestaña Información.
class StatusSelector extends StatelessWidget {
  const StatusSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectDetailController>();
    return Obx(() {
      final current = controller.status.value;
      return PopupMenuButton<ProjectStatus>(
        tooltip: 'Cambiar estado',
        onSelected: controller.setStatus,
        itemBuilder: (_) => [
          for (final status in ProjectStatus.values)
            PopupMenuItem(
              value: status,
              child: StatusMenuRow(status: status),
            ),
        ],
        child: StatusBadge(status: current, showChevron: true),
      );
    });
  }
}

/// Fila de menú con el punto de color y el nombre del estado.
class StatusMenuRow extends StatelessWidget {
  final ProjectStatus status;

  const StatusMenuRow({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: status.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(status.label),
      ],
    );
  }
}

/// Pastilla de estado con color, usada como etiqueta o como disparador.
class StatusBadge extends StatelessWidget {
  final ProjectStatus status;
  final bool showChevron;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.showChevron = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 7 : 8,
            height: compact ? 7 : 8,
            decoration:
                BoxDecoration(color: status.color, shape: BoxShape.circle),
          ),
          SizedBox(width: compact ? 6 : 8),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
          if (showChevron) ...[
            const SizedBox(width: 2),
            Icon(Icons.expand_more, size: compact ? 14 : 16, color: status.color),
          ],
        ],
      ),
    );
  }
}
