import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/extensions/date_extensions.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../models/project.dart';
import 'project_menu.dart';
import 'status_selector.dart';

class KanbanProjectCard extends StatelessWidget {
  final Project project;
  final bool dragging;
  final bool enableDrag;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  const KanbanProjectCard({
    super.key,
    required this.project,
    this.dragging = false,
    this.enableDrag = true,
    this.onDragStarted,
    this.onDragEnded,
  });

  @override
  Widget build(BuildContext context) {
    return _CardContent(
      project: project,
      scheme: Theme.of(context).colorScheme,
      opacity: dragging ? 0.85 : 1,
      enableDrag: enableDrag,
      onDragStarted: onDragStarted,
      onDragEnded: onDragEnded,
    );
  }
}

class _CardContent extends StatelessWidget {
  final Project project;
  final ColorScheme scheme;
  final double opacity;
  final bool enableDrag;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  const _CardContent({
    required this.project,
    required this.scheme,
    required this.opacity,
    required this.enableDrag,
    this.onDragStarted,
    this.onDragEnded,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: project.status.color, width: 3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (enableDrag)
                      _DragHandle(
                        project: project,
                        onDragStarted: onDragStarted,
                        onDragEnded: onDragEnded,
                      ),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () =>
                            Get.toNamed(AppRoutes.projectDetailPath(project.id)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.displayTitle.isEmpty
                                  ? 'Sin título'
                                  : project.displayTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (project.estimatedLaunchDate != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.event_outlined,
                                      size: 13,
                                      color: scheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    project.estimatedLaunchDate!.shortDate,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    ProjectMenu(project: project),
                  ],
                ),
                if (project.thumbnail.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(
                      base64Decode(project.thumbnail),
                      height: 56,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                StatusBadge(status: project.status, compact: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  final Project project;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  const _DragHandle({
    required this.project,
    this.onDragStarted,
    this.onDragEnded,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Draggable<Project>(
      data: project,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      maxSimultaneousDrags: 1,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnded?.call(),
      onDraggableCanceled: (_, _) => onDragEnded?.call(),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 260,
          child: KanbanProjectCard(
            project: project,
            enableDrag: false,
            dragging: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: MouseRegion(
          cursor: SystemMouseCursors.grabbing,
          child: Icon(
            Icons.drag_indicator,
            size: 20,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Padding(
          padding: const EdgeInsets.only(right: 6, top: 2),
          child: Icon(
            Icons.drag_indicator,
            size: 20,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
