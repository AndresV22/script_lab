import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/projects_controller.dart';
import '../../enums/project_status.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import 'kanban_project_card.dart';

class KanbanColumn extends StatefulWidget {
  final ProjectStatus status;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  @override
  State<KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<KanbanColumn> {
  bool _highlighted = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = Get.find<ProjectsController>();

    return DragTarget<Project>(
      onWillAcceptWithDetails: (details) {
        final accepted = details.data.status != widget.status;
        if (_highlighted != accepted) {
          setState(() => _highlighted = accepted);
        }
        return accepted;
      },
      onLeave: (_) {
        if (_highlighted) setState(() => _highlighted = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _highlighted = false);
        controller.setStatus(details.data, widget.status);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 280,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: _highlighted
                ? scheme.primaryContainer.withValues(alpha: 0.35)
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _highlighted
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.status.label,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Obx(() {
                      ProjectService.to.projects.length;
                      controller.query.value;
                      controller.statusFilter.value;
                      final count =
                          controller.projectsByStatus(widget.status).length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  ProjectService.to.projects.length;
                  controller.query.value;
                  controller.statusFilter.value;
                  final projects =
                      controller.projectsByStatus(widget.status);

                  if (projects.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Arrastra proyectos aquí',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                    itemCount: projects.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) => KanbanProjectCard(
                      project: projects[index],
                      onDragStarted: widget.onDragStarted,
                      onDragEnded: widget.onDragEnded,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
