import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helpers/text_stats.dart';
import '../../../../core/services/settings_service.dart';
import '../../projects/controller/project_detail_controller.dart';
import '../../script_editor/controller/script_editor_controller.dart';
import 'widgets/stat_card.dart';

/// Estadísticas del proyecto abierto (pestaña dentro del detalle).
class ProjectStatsView extends StatelessWidget {
  const ProjectStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final detail = Get.find<ProjectDetailController>();
    final editor = Get.find<ScriptEditorController>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      editor.editTick.value;
      detail.revision.value;
      final project = detail.project;
      final fullText = project.fullScriptText;
      final words = TextStats.words(fullText);
      final chars = TextStats.chars(
          project.orderedSections.map((s) => s.content).join());
      final wpm = SettingsService.to.settings.value.wordsPerMinute;
      final narration = TextStats.narrationTime(words, wpm);

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    StatCard(
                      icon: Icons.notes_outlined,
                      label: 'Palabras',
                      value: '$words',
                    ),
                    StatCard(
                      icon: Icons.text_fields,
                      label: 'Caracteres',
                      value: '$chars',
                    ),
                    StatCard(
                      icon: Icons.schedule_outlined,
                      label: 'Narración estimada ($wpm ppm)',
                      value: TextStats.formatDuration(narration),
                    ),
                    StatCard(
                      icon: Icons.segment,
                      label: 'Secciones',
                      value: '${project.sections.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Por sección',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      if (project.sections.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'El guion aún no tiene secciones.',
                            style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant),
                          ),
                        )
                      else
                        for (final section in project.orderedSections)
                          ListTile(
                            dense: true,
                            title: Text(section.title,
                                style: const TextStyle(fontSize: 13.5)),
                            trailing: Text(
                              '${TextStats.words(section.content)} palabras · '
                              '${TextStats.formatDuration(TextStats.narrationTime(TextStats.words(section.content), wpm))}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
