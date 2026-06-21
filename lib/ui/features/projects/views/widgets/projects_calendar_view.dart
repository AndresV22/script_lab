import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../../../core/extensions/date_extensions.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../controller/projects_controller.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import 'calendar_day_cell.dart';

class ProjectsCalendarView extends StatefulWidget {
  const ProjectsCalendarView({super.key});

  @override
  State<ProjectsCalendarView> createState() => _ProjectsCalendarViewState();
}

class _ProjectsCalendarViewState extends State<ProjectsCalendarView> {
  bool _localeReady = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es').then((_) {
      if (mounted) setState(() => _localeReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final controller = Get.find<ProjectsController>();
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      ProjectService.to.projects.length;
      controller.query.value;
      controller.statusFilter.value;
      final month = controller.calendarMonth.value;
      final monthLabel =
          DateFormat('MMMM yyyy', 'es').format(month);
      final capitalized =
          monthLabel[0].toUpperCase() + monthLabel.substring(1);

      final firstOfMonth = DateTime(month.year, month.month);
      final daysInMonth =
          DateTime(month.year, month.month + 1, 0).day;
      // Lunes = 0 … Domingo = 6
      final startWeekday = (firstOfMonth.weekday - 1) % 7;
      final totalCells = ((startWeekday + daysInMonth + 6) ~/ 7) * 7;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 12),
            child: Row(
              children: [
                Text(
                  capitalized,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton(
                  onPressed: controller.goToTodayCalendar,
                  child: const Text('Hoy'),
                ),
                IconButton(
                  tooltip: 'Mes anterior',
                  onPressed: controller.previousCalendarMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: 'Mes siguiente',
                  onPressed: controller.nextCalendarMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              children: [
                for (final day in ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'])
                  Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.1,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  final dayOffset = index - startWeekday + 1;
                  if (dayOffset < 1 || dayOffset > daysInMonth) {
                    final overflowDay = dayOffset < 1
                        ? DateTime(month.year, month.month, dayOffset)
                        : DateTime(month.year, month.month + 1,
                            dayOffset - daysInMonth);
                    return CalendarDayCell(
                      day: overflowDay.dateOnly,
                      isCurrentMonth: false,
                      isToday: overflowDay.isSameDay(DateTime.now()),
                      projects: const [],
                    );
                  }
                  final day = DateTime(month.year, month.month, dayOffset);
                  return CalendarDayCell(
                    day: day.dateOnly,
                    isCurrentMonth: true,
                    isToday: day.isSameDay(DateTime.now()),
                    projects: controller.projectsForDay(day),
                  );
                },
              ),
            ),
          ),
          _UnscheduledPanel(
            projects: controller.unscheduledProjects,
            controller: controller,
          ),
        ],
      );
    });
  }
}

class _UnscheduledPanel extends StatefulWidget {
  final List<Project> projects;
  final ProjectsController controller;

  const _UnscheduledPanel({
    required this.projects,
    required this.controller,
  });

  @override
  State<_UnscheduledPanel> createState() => _UnscheduledPanelState();
}

class _UnscheduledPanelState extends State<_UnscheduledPanel> {
  bool _highlighted = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DragTarget<Project>(
      onWillAcceptWithDetails: (details) {
        final accepted = details.data.estimatedLaunchDate != null;
        if (_highlighted != accepted) setState(() => _highlighted = accepted);
        return accepted;
      },
      onLeave: (_) {
        if (_highlighted) setState(() => _highlighted = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _highlighted = false);
        widget.controller.setLaunchDate(details.data, null);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.fromLTRB(28, 8, 28, 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _highlighted
                ? scheme.primaryContainer.withValues(alpha: 0.35)
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _highlighted
                  ? scheme.primary
                  : scheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sin programar (${widget.projects.length})',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (widget.projects.isEmpty)
                Text(
                  'Arrastra aquí para quitar la fecha de lanzamiento',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final project in widget.projects)
                      _UnscheduledChip(project: project),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _UnscheduledChip extends StatelessWidget {
  final Project project;

  const _UnscheduledChip({required this.project});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LongPressDraggable<Project>(
      data: project,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: _chip(scheme, opacity: 0.9),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _chip(scheme)),
      child: _chip(scheme),
    );
  }

  Widget _chip(ColorScheme scheme, {double opacity = 1}) {
    return Opacity(
      opacity: opacity,
      child: ActionChip(
        label: Text(
          project.displayTitle.isEmpty ? 'Sin título' : project.displayTitle,
          style: const TextStyle(fontSize: 12),
        ),
        avatar: Icon(Icons.drag_indicator,
            size: 16, color: scheme.onSurfaceVariant),
        onPressed: () => Get.toNamed(AppRoutes.projectDetailPath(project.id)),
      ),
    );
  }
}
