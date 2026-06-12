import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helpers/text_stats.dart';
import '../../../../../core/services/settings_service.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../ai/controller/ai_controller.dart';
import '../../controller/script_editor_controller.dart';
import '../../models/script_section.dart';

/// Tarjeta de una sección del guion: reordenable, plegable y editable.
class SectionTile extends StatelessWidget {
  final int index;
  final ScriptSection section;

  const SectionTile({super.key, required this.index, required this.section});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScriptEditorController>();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Obx(() {
          controller.sections.length; // reactividad de expand/colapso
          final expanded = section.expanded;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(Icons.drag_indicator,
                              size: 18, color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        expanded ? Icons.expand_more : Icons.chevron_right,
                        size: 20,
                      ),
                      tooltip: expanded ? 'Contraer' : 'Expandir',
                      onPressed: () => controller.toggleExpanded(section),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller.titleCtrl(section),
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: 'Título de la sección',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (section.aiGenerated)
                      Tooltip(
                        message: 'Generada por IA',
                        child: Icon(Icons.auto_awesome,
                            size: 15, color: scheme.primary),
                      ),
                    const SizedBox(width: 8),
                    Obx(() {
                      controller.editTick.value;
                      final words = TextStats.words(section.content);
                      final wpm = SettingsService
                          .to.settings.value.wordsPerMinute;
                      return Text(
                        '$words palabras · ${TextStats.formatDuration(TextStats.narrationTime(words, wpm))}',
                        style: TextStyle(
                            fontSize: 11.5, color: scheme.onSurfaceVariant),
                      );
                    }),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz,
                          size: 18, color: scheme.onSurfaceVariant),
                      onSelected: (value) async {
                        final ai = Get.find<AiController>();
                        switch (value) {
                          case 'generate':
                            ai.generateSectionDialog(section);
                          case 'correct':
                            ai.correctSectionDialog(section);
                          case 'delete':
                            final ok = await showConfirmDialog(
                              title: 'Eliminar sección',
                              message:
                                  'Se eliminará la sección "${section.title}" y su contenido.',
                            );
                            if (ok) controller.removeSection(section);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'generate',
                          child: Text('Generar con IA'),
                        ),
                        PopupMenuItem(
                          value: 'correct',
                          child: Text('Corregir con IA'),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (expanded) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tooltip(
                        message:
                            'Descripción opcional: contexto extra que la IA usará al generar o corregir esta sección.',
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(Icons.info_outline,
                              size: 15, color: scheme.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller.descriptionCtrl(section),
                          minLines: 1,
                          maxLines: 4,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                            color: scheme.onSurfaceVariant,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                'Descripción para la IA (opcional): qué debe cubrir esta sección, tono, datos…',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                  child: TextField(
                    controller: controller.contentCtrl(section),
                    minLines: 4,
                    maxLines: null,
                    style: const TextStyle(fontSize: 14.5, height: 1.65),
                    decoration: const InputDecoration(
                      hintText: 'Escribe el contenido de esta sección…',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}
