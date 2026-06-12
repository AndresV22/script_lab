import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/ollama_service.dart';
import '../../../../core/widgets/ollama_model_dropdown.dart';
import '../../prompts/services/prompt_service.dart';
import '../../script_editor/controller/script_editor_controller.dart';
import '../controller/ai_controller.dart';
import '../enums/ai_task.dart';
import 'widgets/markdown_output.dart';

/// Pestaña del asistente de IA dentro del detalle de un proyecto.
class AiPanel extends StatelessWidget {
  const AiPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiController>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 12, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ConnectionCard(),
                const SizedBox(height: 16),
                const _CorrectionGroup(),
                _ActionGroup(
                  title: 'Análisis',
                  actions: [
                    _AiAction(
                        'Analizar guion (contradicciones, repeticiones, secciones débiles)',
                        Icons.troubleshoot_outlined,
                        controller.runAnalysis),
                  ],
                ),
                _ActionGroup(
                  title: 'Metadatos del proyecto',
                  actions: [
                    _AiAction('Alternativas de título', Icons.title,
                        () => controller.promptAndRun(AiTask.titles)),
                    _AiAction('Título tentativo', Icons.title_outlined,
                        () => controller.promptAndRun(AiTask.tentativeTitle)),
                    _AiAction('Descripción del video', Icons.notes_outlined,
                        () => controller.promptAndRun(AiTask.description)),
                    _AiAction('Etiquetas', Icons.label_outline,
                        () => controller.promptAndRun(AiTask.tags)),
                    _AiAction('Notas del proyecto', Icons.sticky_note_2_outlined,
                        () => controller.promptAndRun(AiTask.notes)),
                  ],
                ),
                _ActionGroup(
                  title: 'Sugerencias',
                  actions: [
                    _AiAction('Ideas de miniatura', Icons.image_outlined,
                        () => controller.promptAndRun(AiTask.thumbnails)),
                    _AiAction('Hooks más fuertes', Icons.bolt_outlined,
                        () => controller.promptAndRun(AiTask.hooks)),
                  ],
                ),
                _ActionGroup(
                  title: 'Generación',
                  actions: [
                    _AiAction('Generar guion completo',
                        Icons.auto_awesome, controller.runGenerateFull),
                  ],
                ),
                const _SectionGeneration(),
                const SizedBox(height: 8),
                const _PromptLibraryRunner(),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        const Expanded(child: _OutputArea()),
      ],
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard();

  @override
  Widget build(BuildContext context) {
    final ollama = OllamaService.to;
    final controller = Get.find<AiController>();
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Obx(() {
          final status = ollama.status.value;
          final (color, label) = switch (status) {
            OllamaStatus.connected => (Colors.green, 'Ollama conectado'),
            OllamaStatus.checking => (Colors.orange, 'Comprobando…'),
            _ => (Colors.red, 'Sin conexión con Ollama'),
          };
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 16),
                    tooltip: 'Probar conexión',
                    onPressed: ollama.checkConnection,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (ollama.models.isEmpty)
                Text(
                  'Configura la conexión en Ajustes.',
                  style: TextStyle(
                      fontSize: 12, color: scheme.onSurfaceVariant),
                )
              else
                OllamaModelDropdown(
                  value: controller.selectedModel.value,
                  models: ollama.models,
                  hint: 'Modelo',
                  isDense: true,
                  onChanged: (v) =>
                      controller.selectedModel.value = v ?? '',
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _AiAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AiAction(this.label, this.icon, this.onTap);
}

/// Grupo desplegable del panel de IA. Colapsado por defecto para no
/// saturar la barra lateral.
class _CollapsibleGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CollapsibleGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          dense: true,
          visualDensity: VisualDensity.compact,
          iconColor: scheme.onSurfaceVariant,
          collapsedIconColor: scheme.onSurfaceVariant,
          title: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}

class _ActionGroup extends StatelessWidget {
  final String title;
  final List<_AiAction> actions;

  const _ActionGroup({required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiController>();
    final scheme = Theme.of(context).colorScheme;
    return _CollapsibleGroup(
      title: title,
      children: [
        for (final action in actions)
          Obx(() => ListTile(
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                leading: Icon(action.icon,
                    size: 17, color: scheme.onSurfaceVariant),
                title: Text(action.label,
                    style: const TextStyle(fontSize: 13)),
                enabled: !controller.isRunning.value,
                onTap: action.onTap,
              )),
      ],
    );
  }
}

/// Corrección del guion completo o de cada sección por separado.
/// La IA recibe el guion completo como contexto en ambos casos.
class _CorrectionGroup extends StatelessWidget {
  const _CorrectionGroup();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiController>();
    final editor = Get.find<ScriptEditorController>();
    final scheme = Theme.of(context).colorScheme;
    return _CollapsibleGroup(
      title: 'Corrección',
      children: [
        Obx(() {
            editor.editTick.value;
            final withContent = editor.sections
                .where((s) => s.content.trim().isNotEmpty)
                .toList();
            if (withContent.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Escribe contenido en el guion para poder corregirlo.',
                  style:
                      TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              );
            }
            return Column(
              children: [
                if (withContent.length > 1)
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    leading: Icon(Icons.spellcheck,
                        size: 17, color: scheme.onSurfaceVariant),
                    title: const Text('Corregir guion completo',
                        style: TextStyle(fontSize: 13)),
                    enabled: !controller.isRunning.value,
                    onTap: controller.runCorrection,
                  ),
                for (final section in withContent)
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    leading: Icon(Icons.edit_note,
                        size: 17, color: scheme.onSurfaceVariant),
                    title: Text(
                      'Corregir "${section.title}"',
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    enabled: !controller.isRunning.value,
                    onTap: () => controller.runSectionCorrection(section),
                  ),
              ],
            );
          }),
      ],
    );
  }
}

class _SectionGeneration extends StatelessWidget {
  const _SectionGeneration();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiController>();
    final editor = Get.find<ScriptEditorController>();
    final scheme = Theme.of(context).colorScheme;
    return _CollapsibleGroup(
      title: 'Generación parcial',
      children: [
        Obx(() {
          if (editor.sections.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Añade secciones al guion para generarlas con IA.',
                style:
                    TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            );
          }
          return Column(
            children: [
              for (final section in editor.sections)
                ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  leading: Icon(Icons.segment,
                      size: 17, color: scheme.onSurfaceVariant),
                  title: Text(
                    'Generar "${section.title}"',
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  enabled: !controller.isRunning.value,
                  onTap: () => controller.runGenerateSection(section),
                ),
            ],
          );
        }),
      ],
    );
  }
}

class _PromptLibraryRunner extends StatelessWidget {
  const _PromptLibraryRunner();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiController>();
    final scheme = Theme.of(context).colorScheme;
    return _CollapsibleGroup(
      title: 'Biblioteca de prompts',
      children: [
        Obx(() {
          final prompts = PromptService.to.prompts;
          if (prompts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Guarda prompts reutilizables en la sección Prompts.',
                style:
                    TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            );
          }
          return Column(
            children: [
              for (final prompt in prompts)
                ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  leading: Icon(Icons.play_arrow_outlined,
                      size: 17, color: scheme.onSurfaceVariant),
                  title: Text(
                    prompt.name,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  enabled: !controller.isRunning.value,
                  onTap: () => controller.runCustomPrompt(prompt),
                ),
            ],
          );
        }),
      ],
    );
  }
}

class _OutputArea extends StatelessWidget {
  const _OutputArea();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiController>();
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: Obx(() {
            final task = controller.currentTask.value;
            return Row(
              children: [
                Icon(Icons.auto_awesome, size: 17, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  task?.label ?? 'Asistente IA',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (controller.isRunning.value) ...[
                  const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: controller.cancel,
                    icon: const Icon(Icons.stop, size: 15),
                    label: const Text('Detener'),
                  ),
                ],
              ],
            );
          }),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(() {
            if (controller.error.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SelectableText(
                  controller.error.value,
                  style: TextStyle(color: scheme.error, fontSize: 13.5),
                ),
              );
            }
            if (controller.output.value.isEmpty) {
              return Center(
                child: Text(
                  controller.isRunning.value
                      ? 'Esperando respuesta del modelo…'
                      : 'Elige una acción del panel izquierdo.\nLa IA usará el contexto completo del proyecto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: scheme.onSurfaceVariant, fontSize: 13.5),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: MarkdownOutput(text: controller.output.value),
            );
          }),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Obx(() {
            final hasOutput = controller.output.value.isNotEmpty &&
                !controller.isRunning.value;
            if (!hasOutput) return const SizedBox(height: 36);
            final task = controller.currentTask.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: controller.copyOutput,
                  child: const Text('Copiar'),
                ),
                const SizedBox(width: 8),
                switch (task) {
                  AiTask.correction => FilledButton(
                      onPressed: controller.reviewFullCorrection,
                      child: const Text('Revisar diferencias'),
                    ),
                  AiTask.sectionCorrection => FilledButton(
                      onPressed: controller.reviewSectionCorrection,
                      child: const Text('Revisar diferencias'),
                    ),
                  AiTask.titles => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: controller.applyTentativeTitle,
                          child: const Text('Usar como tentativo'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: controller.addTitlesToAlternatives,
                          child: const Text('Añadir alternativas'),
                        ),
                      ],
                    ),
                  AiTask.tentativeTitle => FilledButton(
                      onPressed: controller.applyTentativeTitle,
                      child: const Text('Usar como tentativo'),
                    ),
                  AiTask.description => FilledButton(
                      onPressed: controller.applyDescription,
                      child: const Text('Usar como descripción'),
                    ),
                  AiTask.tags => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: () => controller.applyTags(replace: true),
                          child: const Text('Reemplazar'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: controller.applyTags,
                          child: const Text('Añadir etiquetas'),
                        ),
                      ],
                    ),
                  AiTask.notes => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: () => controller.applyNotes(append: true),
                          child: const Text('Añadir al final'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: controller.applyNotes,
                          child: const Text('Reemplazar notas'),
                        ),
                      ],
                    ),
                  AiTask.generateSection => FilledButton(
                      onPressed: controller.insertIntoTargetSection,
                      child: const Text('Insertar en sección'),
                    ),
                  AiTask.generateFull => FilledButton(
                      onPressed: () => controller
                          .applyFullScript(controller.cleanedOutput),
                      child: const Text('Aplicar al guion'),
                    ),
                  _ => const SizedBox.shrink(),
                },
              ],
            );
          }),
        ),
      ],
    );
  }
}
