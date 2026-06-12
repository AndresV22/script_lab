import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helpers/text_stats.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../projects/services/project_service.dart';
import '../controller/analytics_controller.dart';
import 'widgets/stat_card.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppShell(
      selected: AppSection.analytics,
      child: Obx(() {
        ProjectService.to.projects.length;
        if (controller.totalProjects == 0) {
          return const EmptyState(
            icon: Icons.bar_chart_outlined,
            title: 'Sin datos todavía',
            subtitle:
                'Crea proyectos y escribe guiones para ver estadísticas aquí.',
          );
        }
        final wpm = SettingsService.to.settings.value.wordsPerMinute;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estadísticas',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  StatCard(
                    icon: Icons.video_library_outlined,
                    label: 'Proyectos',
                    value: '${controller.totalProjects}',
                  ),
                  StatCard(
                    icon: Icons.notes_outlined,
                    label: 'Palabras escritas',
                    value: '${controller.totalWords}',
                  ),
                  StatCard(
                    icon: Icons.segment,
                    label: 'Secciones',
                    value: '${controller.totalSections}',
                  ),
                  StatCard(
                    icon: Icons.schedule_outlined,
                    label: 'Narración estimada',
                    value:
                        TextStats.formatDuration(controller.totalNarration),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Por estado',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final entry in controller.byStatus.entries)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: entry.key.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: entry.key.color.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${entry.key.label}: ${entry.value}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: entry.key.color,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Proyectos',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    for (final project in controller.projects)
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.description_outlined,
                            size: 18, color: scheme.onSurfaceVariant),
                        title: Text(
                          project.displayTitle.isEmpty
                              ? 'Sin título'
                              : project.displayTitle,
                          style: const TextStyle(fontSize: 13.5),
                        ),
                        trailing: Text(
                          '${TextStats.words(project.fullScriptText)} palabras · '
                          '${project.sections.length} secciones · '
                          '${TextStats.formatDuration(TextStats.narrationTime(TextStats.words(project.fullScriptText), wpm))}',
                          style: TextStyle(
                              fontSize: 12, color: scheme.onSurfaceVariant),
                        ),
                        onTap: () => Get.toNamed(
                            AppRoutes.projectDetailPath(project.id)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
