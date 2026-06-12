import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/helpers/text_stats.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/ollama_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/ollama_model_dropdown.dart';
import '../../projects/services/project_service.dart';
import '../../projects/views/widgets/new_project_dialog.dart';
import '../../projects/views/widgets/status_selector.dart';
import '../../prompts/services/prompt_service.dart';
import '../../settings/controller/settings_controller.dart';
import '../../structures/services/structure_service.dart';
import '../../analytics/views/widgets/stat_card.dart';
import '../../suggestions/services/suggestions_service.dart';
import '../../suggestions/views/widgets/ai_suggestions_carousel.dart';
import '../controller/dashboard_controller.dart';
import 'widgets/dashboard_footer.dart';
import 'widgets/status_bar_chart.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selected: AppSection.dashboard,
      footer: const DashboardFooter(),
      child: Obx(() {
        ProjectService.to.projects.length;
        PromptService.to.prompts.length;
        StructureService.to.structures.length;
        SettingsService.to.settings.value;
        SuggestionsService.to.suggestions.length;
        OllamaService.to.status.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              const SizedBox(height: 24),
              _StatsRow(),
              const SizedBox(height: 24),
              const AiSuggestionsCarousel(),
              const SizedBox(height: 24),
              _TipsCarousel(tips: controller.tips),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 960;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _RecentProjectsPanel()),
                        const SizedBox(width: 16),
                        Expanded(child: _StatusPanel()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _RecentProjectsPanel(),
                      const SizedBox(height: 16),
                      _StatusPanel(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 960;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _OllamaPanel(
                            key: controller.ollamaSectionKey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _RankingsPanel()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _OllamaPanel(key: controller.ollamaSectionKey),
                      const SizedBox(height: 16),
                      _RankingsPanel(),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inicio',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Resumen de tu espacio de trabajo',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: showNewProjectDialog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nuevo proyecto'),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: BackupService.exportBackup,
          icon: const Icon(Icons.download_outlined, size: 17),
          label: const Text('Exportar'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: BackupService.importBackup,
          icon: const Icon(Icons.upload_outlined, size: 17),
          label: const Text('Importar'),
        ),
      ],
    );
  }
}

class _StatsRow extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    final analytics = controller.analytics;
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        StatCard(
          icon: Icons.video_library_outlined,
          label: 'Proyectos',
          value: '${analytics.totalProjects}',
        ),
        StatCard(
          icon: Icons.notes_outlined,
          label: 'Palabras escritas',
          value: '${analytics.totalWords}',
        ),
        StatCard(
          icon: Icons.segment,
          label: 'Secciones',
          value: '${analytics.totalSections}',
        ),
        StatCard(
          icon: Icons.schedule_outlined,
          label: 'Narración estimada',
          value: TextStats.formatDuration(analytics.totalNarration),
        ),
      ],
    );
  }
}

class _TipsCarousel extends StatefulWidget {
  final List<DashboardTip> tips;

  const _TipsCarousel({required this.tips});

  @override
  State<_TipsCarousel> createState() => _TipsCarouselState();
}

class _TipsCarouselState extends State<_TipsCarousel> {
  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.42);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (widget.tips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consejos',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 132,
          child: PageView.builder(
            controller: _pageCtrl,
            padEnds: false,
            itemCount: widget.tips.length,
            itemBuilder: (context, index) {
              final item = widget.tips[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < widget.tips.length - 1 ? 12 : 0,
                ),
                child: Material(
                  color: item.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: item.color.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon, color: item.color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: scheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const _PanelCard({
    required this.title,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                ?action,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _OllamaPanel extends StatelessWidget {
  const _OllamaPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final ollama = OllamaService.to;
    final scheme = Theme.of(context).colorScheme;

    return _PanelCard(
      title: 'Modelo de IA',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: LabeledField(
                  label: 'URL del servidor',
                  child: TextField(
                    controller: settingsCtrl.urlCtrl,
                    decoration: const InputDecoration(
                      hintText: 'http://localhost:11434',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => FilledButton.icon(
                    onPressed: settingsCtrl.testing.value
                        ? null
                        : settingsCtrl.testConnection,
                    icon: settingsCtrl.testing.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_tethering, size: 17),
                    label: const Text('Probar'),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final status = ollama.status.value;
            final (color, label) = switch (status) {
              OllamaStatus.connected => (
                  Colors.green,
                  'Conectado · ${ollama.models.length} modelos'
                ),
              OllamaStatus.checking => (Colors.orange, 'Comprobando…'),
              OllamaStatus.disconnected => (
                  Colors.red,
                  'Sin conexión'
                ),
              OllamaStatus.unknown => (Colors.grey, 'Estado desconocido'),
            };
            return Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 13)),
              ],
            );
          }),
          const SizedBox(height: 12),
          Obx(() {
            if (ollama.models.isEmpty) return const SizedBox.shrink();
            final current = settingsCtrl.settings.settings.value.defaultModel;
            return LabeledField(
              label: 'Modelo predeterminado',
              child: OllamaModelDropdown(
                value: current,
                models: ollama.models,
                onChanged: settingsCtrl.setDefaultModel,
              ),
            );
          }),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Get.offAllNamed(AppRoutes.settings),
              child: Text(
                'Más opciones de IA',
                style: TextStyle(color: scheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      title: 'Estados de proyectos',
      child: StatusBarChart(data: controller.analytics.byStatus),
    );
  }
}

class _RecentProjectsPanel extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final recent = controller.recentProjects;

    return _PanelCard(
      title: 'Últimos proyectos modificados',
      action: TextButton(
        onPressed: () => Get.offAllNamed(AppRoutes.projects),
        child: const Text('Ver todos'),
      ),
      child: recent.isEmpty
          ? Text(
              'Aún no hay proyectos. Crea uno para empezar.',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            )
          : Column(
              children: [
                for (final project in recent)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.movie_outlined,
                        size: 18, color: scheme.onSurfaceVariant),
                    title: Text(
                      project.displayTitle.isEmpty
                          ? 'Sin título'
                          : project.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      project.updatedAt.relative,
                      style: TextStyle(
                          fontSize: 11.5, color: scheme.onSurfaceVariant),
                    ),
                    trailing: ProjectStatusPicker(
                      project: project,
                      compact: true,
                    ),
                    onTap: () =>
                        Get.toNamed(AppRoutes.projectDetailPath(project.id)),
                  ),
              ],
            ),
    );
  }
}

class _RankingsPanel extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final structures = controller.topStructures;
    final prompts = controller.savedPrompts;

    return _PanelCard(
      title: 'Estructuras y prompts',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Estructuras más usadas',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          if (structures.isEmpty)
            Text(
              'Ningún proyecto usa estructuras todavía.',
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
            )
          else
            for (final item in structures)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.structure.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.count}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 16),
          Text(
            'Prompts en biblioteca',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          if (prompts.isEmpty)
            Text(
              'Guarda prompts reutilizables en la sección Prompts.',
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
            )
          else
            for (final prompt in prompts)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_outlined,
                        size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prompt.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    if (prompt.category.isNotEmpty)
                      Text(
                        prompt.category,
                        style: TextStyle(
                            fontSize: 11, color: scheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Get.offAllNamed(AppRoutes.prompts),
              child: const Text('Gestionar prompts'),
            ),
          ),
        ],
      ),
    );
  }
}
