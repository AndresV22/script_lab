import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/services/export_service.dart';
import '../../ai/views/ai_panel.dart';
import '../../ai/views/chat_view.dart';
import '../../analytics/views/project_stats_view.dart';
import '../../script_editor/views/script_editor_view.dart';
import '../../script_editor/views/versions_view.dart';
import '../controller/project_detail_controller.dart';
import 'widgets/project_info_tab.dart';
import 'widgets/status_selector.dart';

class ProjectDetailView extends GetView<ProjectDetailController> {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.loaded.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return DefaultTabController(
        length: 6,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              tooltip: 'Volver',
              onPressed: Get.back,
            ),
            title: Obx(() {
              controller.revision.value;
              final title = controller.project.displayTitle;
              return Text(title.isEmpty ? 'Sin título' : title);
            }),
            actions: [
              const _SaveIndicator(),
              const SizedBox(width: 16),
              const StatusSelector(),
              const SizedBox(width: 8),
              _ExportMenu(controller: controller),
              const SizedBox(width: 16),
            ],
            bottom: const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Información'),
                Tab(text: 'Guion'),
                Tab(text: 'Asistente IA'),
                Tab(text: 'Chat'),
                Tab(text: 'Versiones'),
                Tab(text: 'Estadísticas'),
              ],
            ),
          ),
          body: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              ProjectInfoTab(),
              ScriptEditorView(),
              AiPanel(),
              ChatView(),
              VersionsView(),
              ProjectStatsView(),
            ],
          ),
        ),
      );
    });
  }
}

class _SaveIndicator extends StatelessWidget {
  const _SaveIndicator();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectDetailController>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      if (controller.saving.value) {
        return Row(
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text('Guardando…',
                style:
                    TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ],
        );
      }
      final saved = controller.lastSaved.value;
      if (saved == null) return const SizedBox.shrink();
      return Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            'Guardado ${saved.relative}',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      );
    });
  }
}

class _ExportMenu extends StatelessWidget {
  final ProjectDetailController controller;

  const _ExportMenu({required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Exportar',
      icon: const Icon(Icons.ios_share, size: 19),
      onSelected: (format) async {
        final project = controller.project;
        switch (format) {
          case 'txt':
            await ExportService.exportTxt(project);
          case 'md':
            await ExportService.exportMarkdown(project);
          case 'pdf':
            await ExportService.exportPdf(project);
          case 'json':
            await ExportService.exportJson(project);
        }
        Get.snackbar('Exportación', 'Guion exportado en formato $format',
            snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'txt', child: Text('Exportar como TXT')),
        PopupMenuItem(value: 'md', child: Text('Exportar como Markdown')),
        PopupMenuItem(value: 'pdf', child: Text('Exportar como PDF')),
        PopupMenuItem(value: 'json', child: Text('Exportar como JSON')),
      ],
    );
  }
}
