import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/copy_field_suffix.dart';
import '../../../../../core/widgets/editable_chips.dart';
import '../../../../../core/widgets/labeled_field.dart';
import '../../../../../core/widgets/markdown_notes_field.dart';
import '../../../ai/controller/ai_controller.dart';
import '../../../ai/enums/ai_task.dart';
import '../../controller/project_detail_controller.dart';
import 'status_selector.dart';

/// Pestaña con la información principal del proyecto.
class ProjectInfoTab extends StatelessWidget {
  const ProjectInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectDetailController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionCard(
                title: 'Información básica',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LabeledField(
                      label: 'Tema del video',
                      child: TextField(
                        controller: controller.topicCtrl,
                        decoration: const InputDecoration(hintText: '¿De qué trata este video?'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const LabeledField(
                      label: 'Estado del proyecto',
                      child: Align(alignment: Alignment.centerLeft, child: StatusSelector()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Títulos',
                action: _TitlesAiMenu(),
                child: Obx(() {
                  controller.revision.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LabeledField(
                        label: 'Título tentativo',
                        child: TextFieldWithCopy(
                          controller: controller.titleCtrl,
                          getCopyText: () => controller.titleCtrl.text,
                          copyTooltip: 'Copiar título',
                          copySnackbarMessage: 'Título copiado al portapapeles',
                          decoration: const InputDecoration(hintText: 'El título sobre el que trabajas'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      LabeledField(
                        label: 'Alternativas de título',
                        helper: 'Haz clic en una alternativa para convertirla en el título tentativo.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (controller.project.altTitles.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (var i = 0; i < controller.project.altTitles.length; i++)
                                      InputChip(
                                        label: Text(controller.project.altTitles[i]),
                                        onPressed: () => controller.promoteAltTitle(i),
                                        onDeleted: () => controller.removeAltTitle(i),
                                        deleteIcon: const Icon(Icons.close, size: 14),
                                      ),
                                  ],
                                ),
                              ),
                            _AddInline(hint: 'Añadir alternativa de título…', onAdd: controller.addAltTitle),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Miniaturas',
                child: Obx(() {
                  controller.revision.value;
                  return _ThumbnailsSection(controller: controller);
                }),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Descripción del video',
                action: _AiGenerateButton(task: AiTask.description),
                child: TextFieldWithCopy(
                  controller: controller.descriptionCtrl,
                  minLines: 4,
                  maxLines: 10,
                  getCopyText: () => controller.descriptionCtrl.text,
                  copyTooltip: 'Copiar descripción',
                  copySnackbarMessage: 'Descripción copiada al portapapeles',
                  decoration: const InputDecoration(hintText: 'Texto que acompañará al video en YouTube…'),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Etiquetas',
                action: _AiGenerateButton(task: AiTask.tags),
                child: Obx(() {
                  controller.revision.value;
                  return EditableChips(
                    values: controller.project.tags,
                    hint: 'Añadir etiqueta… (separa con comas)',
                    onAdd: controller.addTag,
                    onRemove: controller.removeTag,
                    addOnComma: true,
                    getCopyText: () => controller.project.tags.join(', '),
                    copyTooltip: 'Copiar etiquetas',
                    copySnackbarMessage: 'Etiquetas copiadas al portapapeles',
                  );
                }),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Notas',
                action: _AiGenerateButton(task: AiTask.notes),
                child: MarkdownNotesField(
                  controller: controller.notesCtrl,
                  enableCopy: true,
                  minLines: 5,
                  maxLines: 14,
                  decoration: const InputDecoration(hintText: 'Espacio libre para ideas, referencias…'),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;

  const _SectionCard({required this.title, this.action, required this.child});

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
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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

class _AiGenerateButton extends StatelessWidget {
  final AiTask task;

  const _AiGenerateButton({required this.task});

  @override
  Widget build(BuildContext context) {
    final ai = Get.find<AiController>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final busy = ai.isRunning.value && ai.currentTask.value == task;
      return TextButton.icon(
        onPressed: busy ? null : () => ai.launchMetadataTask(task),
        icon: busy
            ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary))
            : Icon(Icons.auto_awesome, size: 15, color: scheme.primary),
        label: Text('Generar con IA', style: TextStyle(fontSize: 12.5, color: scheme.primary)),
      );
    });
  }
}

class _TitlesAiMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ai = Get.find<AiController>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final busy =
          ai.isRunning.value &&
          (ai.currentTask.value == AiTask.titles || ai.currentTask.value == AiTask.tentativeTitle);
      return PopupMenuButton<AiTask>(
        tooltip: 'Generar con IA',
        enabled: !busy,
        onSelected: ai.launchMetadataTask,
        itemBuilder: (_) => [
          const PopupMenuItem(value: AiTask.tentativeTitle, child: Text('Generar título tentativo')),
          const PopupMenuItem(value: AiTask.titles, child: Text('Generar alternativas')),
        ],
        child: IgnorePointer(
          child: TextButton.icon(
            onPressed: () {},
            icon: busy
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
                  )
                : Icon(Icons.auto_awesome, size: 15, color: scheme.primary),
            label: Text('Generar con IA', style: TextStyle(fontSize: 12.5, color: scheme.primary)),
          ),
        ),
      );
    });
  }
}

class _AddInline extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onAdd;

  const _AddInline({required this.hint, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();

    void submit(String value) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        onAdd(trimmed);
        ctrl.clear();
      }
    }

    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        suffixIcon: IconButton(
          icon: const Icon(Icons.add, size: 18),
          tooltip: 'Añadir',
          onPressed: () => submit(ctrl.text),
        ),
      ),
      onSubmitted: submit,
    );
  }
}

class _ThumbnailsSection extends StatelessWidget {
  final ProjectDetailController controller;

  const _ThumbnailsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final project = controller.project;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: 'Miniatura tentativa',
          child: project.thumbnail.isEmpty
              ? OutlinedButton.icon(
                  onPressed: () => controller.pickThumbnail(asTentative: true),
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: const Text('Subir miniatura principal'),
                )
              : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(base64Decode(project.thumbnail), width: 320, height: 180, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Row(
                        children: [
                          _ThumbAction(
                            icon: Icons.sync,
                            tooltip: 'Reemplazar',
                            onTap: () => controller.pickThumbnail(asTentative: true),
                          ),
                          const SizedBox(width: 6),
                          _ThumbAction(
                            icon: Icons.delete_outline,
                            tooltip: 'Quitar',
                            onTap: () => controller.removeThumbnail(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 18),
        LabeledField(
          label: 'Alternativas de miniatura',
          helper: 'Pasa el cursor sobre una alternativa para promoverla o eliminarla.',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < project.altThumbnails.length; i++)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(project.altThumbnails[i]),
                        width: 160,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Row(
                        children: [
                          _ThumbAction(
                            icon: Icons.star_outline,
                            tooltip: 'Usar como tentativa',
                            onTap: () => controller.promoteThumbnail(i),
                          ),
                          const SizedBox(width: 4),
                          _ThumbAction(
                            icon: Icons.delete_outline,
                            tooltip: 'Eliminar',
                            onTap: () => controller.removeThumbnail(altIndex: i),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              SizedBox(
                width: 160,
                height: 90,
                child: OutlinedButton(
                  onPressed: () => controller.pickThumbnail(asTentative: false),
                  child: Icon(Icons.add_photo_alternate_outlined, color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThumbAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ThumbAction({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(icon, size: 15, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
