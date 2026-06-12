import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/view_mode_switcher.dart';
import '../controller/projects_controller.dart';
import '../enums/project_status.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import 'widgets/new_project_dialog.dart';
import 'widgets/status_selector.dart';

class ProjectsView extends GetView<ProjectsController> {
  const ProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selected: AppSection.projects,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
            child: Row(
              children: [
                Text(
                  'Proyectos',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: showNewProjectDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nuevo proyecto'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
            child: Row(
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Filtrar proyectos…',
                      prefixIcon: Icon(Icons.search, size: 18),
                      isDense: true,
                    ),
                    onChanged: (v) => controller.query.value = v,
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Wrap(
                    spacing: 6,
                    children: [
                      _StatusFilterChip(
                        label: 'Todos',
                        selected: controller.statusFilter.value == null,
                        onTap: () => controller.statusFilter.value = null,
                      ),
                      for (final status in ProjectStatus.values)
                        _StatusFilterChip(
                          label: status.label,
                          color: status.color,
                          selected: controller.statusFilter.value == status,
                          onTap: () => controller.statusFilter.value = status,
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                Obx(() {
                  SettingsService.to.settings.value;
                  return ViewModeSwitcher(
                    mode: controller.viewMode,
                    cardSize: controller.cardSize,
                    onModeChanged: controller.setViewMode,
                    onSizeChanged: controller.setCardSize,
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              // Toca la lista reactiva para reconstruir al cambiar.
              ProjectService.to.projects.length;
              final projects = controller.filtered;
              if (projects.isEmpty) {
                return EmptyState(
                  icon: Icons.video_library_outlined,
                  title: 'Sin proyectos',
                  subtitle:
                      'Crea tu primer proyecto para empezar a escribir el guion de tu próximo video.',
                  action: FilledButton.icon(
                    onPressed: showNewProjectDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nuevo proyecto'),
                  ),
                );
              }
              SettingsService.to.settings.value;
              if (controller.viewMode == 'list') {
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                  itemCount: projects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _ProjectListRow(project: projects[index]),
                );
              }
              final extents = cardExtents(
                controller.cardSize,
                s: (width: 280, height: 170),
                m: (width: 360, height: 200),
                l: (width: 460, height: 250),
              );
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: extents.width,
                  mainAxisExtent: extents.height,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: projects.length,
                itemBuilder: (context, index) =>
                    _ProjectCard(project: projects[index]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (color != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
    );
  }
}

/// Menú de acciones del proyecto (eliminar), compartido entre cards y lista.
class _ProjectMenu extends StatelessWidget {
  final Project project;

  const _ProjectMenu({required this.project});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = Get.find<ProjectsController>();
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, size: 18, color: scheme.onSurfaceVariant),
      onSelected: (value) async {
        if (value == 'delete') {
          final ok = await showConfirmDialog(
            title: 'Eliminar proyecto',
            message:
                'Se eliminará "${project.displayTitle}" y todo su contenido. Esta acción no se puede deshacer.',
          );
          if (ok) controller.deleteProject(project);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'delete',
          child: Text('Eliminar'),
        ),
      ],
    );
  }
}

/// Fila de proyecto en modo lista.
class _ProjectListRow extends StatelessWidget {
  final Project project;

  const _ProjectListRow({required this.project});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Get.toNamed(AppRoutes.projectDetailPath(project.id)),
                child: Row(
                  children: [
                    if (project.thumbnail.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(
                          base64Decode(project.thumbnail),
                          width: 64,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 64,
                        height: 40,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.movie_outlined,
                            size: 18, color: scheme.onSurfaceVariant),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.displayTitle.isEmpty
                                ? 'Sin título'
                                : project.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (project.tags.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              project.tags.join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            ProjectStatusPicker(project: project, compact: true),
            const SizedBox(width: 14),
            SizedBox(
              width: 90,
              child: Text(
                project.updatedAt.relative,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 4),
            _ProjectMenu(project: project),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                    borderRadius: BorderRadius.circular(8),
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
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        if (project.thumbnail.isNotEmpty)
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                base64Decode(project.thumbnail),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: Text(
                              project.topic.isEmpty
                                  ? 'Sin tema definido'
                                  : project.topic,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                  _ProjectMenu(project: project),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ProjectStatusPicker(project: project, compact: true),
                const Spacer(),
                Text(
                  project.updatedAt.relative,
                  style: TextStyle(
                      fontSize: 11, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
