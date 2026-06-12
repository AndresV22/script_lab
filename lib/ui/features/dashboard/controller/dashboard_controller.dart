import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/ollama_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../analytics/controller/analytics_controller.dart';
import '../../projects/models/project.dart';
import '../../projects/services/project_service.dart';
import '../../projects/views/widgets/new_project_dialog.dart';
import '../views/widgets/theme_picker_dialog.dart';
import '../../prompts/models/prompt_item.dart';
import '../../prompts/services/prompt_service.dart';
import '../../structures/models/structure.dart';
import '../../structures/services/structure_service.dart';

class StructureUsage {
  final Structure structure;
  final int count;

  const StructureUsage({required this.structure, required this.count});
}

class DashboardTip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class DashboardController extends GetxController {
  final ollamaSectionKey = GlobalKey();

  AnalyticsController get analytics => Get.find<AnalyticsController>();

  void scrollToOllama() {
    final ctx = ollamaSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Project> get recentProjects =>
      ProjectService.to.projects.take(6).toList();

  List<StructureUsage> get topStructures {
    final counts = <String, int>{};
    for (final project in ProjectService.to.projects) {
      if (project.structureId.isEmpty) continue;
      counts.update(project.structureId, (v) => v + 1, ifAbsent: () => 1);
    }
    final structures = StructureService.to.structures;
    final usage = <StructureUsage>[];
    for (final entry in counts.entries) {
      final structure =
          structures.firstWhereOrNull((s) => s.id == entry.key);
      if (structure != null) {
        usage.add(StructureUsage(structure: structure, count: entry.value));
      }
    }
    usage.sort((a, b) => b.count.compareTo(a.count));
    return usage.take(5).toList();
  }

  /// Sin contador de uso persistido: muestra los prompts guardados en biblioteca.
  List<PromptItem> get savedPrompts =>
      PromptService.to.prompts.take(5).toList();

  List<DashboardTip> get tips {
    final settings = SettingsService.to;
    final ollama = OllamaService.to;
    final items = <DashboardTip>[];

    if (settings.channel.value.isEmpty) {
      items.add(DashboardTip(
        title: 'Añadir información del canal',
        description:
            'Configura nombre, audiencia y estilo para que la IA escriba como tú.',
        icon: Icons.campaign_outlined,
        color: const Color(0xFF5E6AD2),
        onTap: () => Get.offAllNamed(AppRoutes.settings),
      ));
    }

    items.add(DashboardTip(
      title: 'Cambiar tema de la aplicación',
      description: 'Alterna entre modo claro, oscuro o el del sistema.',
      icon: Icons.palette_outlined,
      color: const Color(0xFF9B5ED2),
      onTap: showThemePickerDialog,
    ));

    if (settings.styleSamples.isEmpty) {
      items.add(DashboardTip(
        title: 'Entrenamiento de estilo del modelo',
        description:
            'Importa transcripciones tuyas para que la IA imite tu forma de escribir.',
        icon: Icons.record_voice_over_outlined,
        color: const Color(0xFF4CA970),
        onTap: () => Get.offAllNamed(AppRoutes.settings),
      ));
    }

    if (ollama.status.value != OllamaStatus.connected) {
      items.add(DashboardTip(
        title: 'Conectar Ollama',
        description:
            'Verifica la URL del servidor y elige un modelo para usar la IA.',
        icon: Icons.smart_toy_outlined,
        color: const Color(0xFFD2A65E),
        onTap: scrollToOllama,
      ));
    }

    if (ProjectService.to.projects.isEmpty) {
      items.add(DashboardTip(
        title: 'Crea tu primer proyecto',
        description: 'Empieza a planificar y escribir el guion de un video.',
        icon: Icons.add_circle_outline,
        color: const Color(0xFF5E6AD2),
        onTap: showNewProjectDialog,
      ));
    }

    return items;
  }
}
