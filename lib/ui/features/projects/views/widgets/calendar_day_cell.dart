import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/extensions/date_extensions.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../controller/projects_controller.dart';
import '../../models/project.dart';

class CalendarDayCell extends StatefulWidget {
  final DateTime day;
  final bool isCurrentMonth;
  final bool isToday;
  final List<Project> projects;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isCurrentMonth,
    required this.isToday,
    required this.projects,
  });

  @override
  State<CalendarDayCell> createState() => _CalendarDayCellState();
}

class _CalendarDayCellState extends State<CalendarDayCell> {
  bool _highlighted = false;
  static const _maxVisible = 3;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = Get.find<ProjectsController>();

    return DragTarget<Project>(
      onWillAcceptWithDetails: (_) {
        if (!_highlighted) setState(() => _highlighted = true);
        return true;
      },
      onLeave: (_) {
        if (_highlighted) setState(() => _highlighted = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _highlighted = false);
        final current = details.data.estimatedLaunchDate;
        if (current == null || !current.isSameDay(widget.day)) {
          controller.setLaunchDate(details.data, widget.day);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: _highlighted
                ? scheme.primaryContainer.withValues(alpha: 0.4)
                : widget.isToday
                    ? scheme.primaryContainer.withValues(alpha: 0.2)
                    : null,
            border: Border.all(
              color: _highlighted
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.day.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      widget.isToday ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isCurrentMonth
                      ? scheme.onSurface
                      : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: widget.projects.isEmpty
                    ? const SizedBox.shrink()
                    : ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          for (final project
                              in widget.projects.take(_maxVisible))
                            _CalendarProjectChip(project: project),
                          if (widget.projects.length > _maxVisible)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '+${widget.projects.length - _maxVisible} más',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CalendarProjectChip extends StatelessWidget {
  final Project project;

  const _CalendarProjectChip({required this.project});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: LongPressDraggable<Project>(
        data: project,
        feedback: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(4),
          child: Opacity(
            opacity: 0.9,
            child: _ChipContent(project: project, scheme: scheme),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _ChipContent(project: project, scheme: scheme),
        ),
        child: _ChipContent(project: project, scheme: scheme),
      ),
    );
  }
}

class _ChipContent extends StatelessWidget {
  final Project project;
  final ColorScheme scheme;

  const _ChipContent({required this.project, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: project.status.color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => Get.toNamed(AppRoutes.projectDetailPath(project.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: project.status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  project.displayTitle.isEmpty
                      ? 'Sin título'
                      : project.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
