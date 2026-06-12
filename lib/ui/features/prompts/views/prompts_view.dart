import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controller/prompts_controller.dart';
import '../models/prompt_item.dart';
import '../services/prompt_service.dart';

class PromptsView extends GetView<PromptsController> {
  const PromptsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selected: AppSection.prompts,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biblioteca de prompts',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Instrucciones reutilizables para la IA. Se ejecutan desde la pestaña '
                        '"Asistente IA" de cualquier proyecto, usando su contexto completo '
                        '(tema, guion, variables del canal y tu estilo).',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: controller.addPresets,
                  icon: const Icon(Icons.auto_awesome_outlined, size: 17),
                  label: const Text('Añadir ejemplos'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () => _edit(null),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nuevo prompt'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final prompts = PromptService.to.prompts;
              if (prompts.isEmpty) {
                return EmptyState(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Sin prompts guardados',
                  subtitle:
                      'Un prompt es una instrucción que le das a la IA y que quieres reutilizar en varios videos.\n'
                      'Por ejemplo: "Mejorar hook", "Detectar contradicciones" o "Crear títulos con alto CTR".\n'
                      'Empieza con los ejemplos y adáptalos a tu canal.',
                  action: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: controller.addPresets,
                        icon: const Icon(Icons.auto_awesome_outlined,
                            size: 17),
                        label: const Text('Añadir ejemplos'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: () => _edit(null),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nuevo prompt'),
                      ),
                    ],
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 170,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: prompts.length,
                itemBuilder: (context, index) =>
                    _PromptCard(prompt: prompts[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  static void _edit(PromptItem? prompt) {
    final isNew = prompt == null;
    final item = prompt ?? PromptItem(id: const Uuid().v4());
    final nameCtrl = TextEditingController(text: item.name);
    final categoryCtrl = TextEditingController(text: item.category);
    final contentCtrl = TextEditingController(text: item.content);
    Get.dialog(
      AlertDialog(
        title: Text(isNew ? 'Nuevo prompt' : 'Editar prompt'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(builder: (context) {
                return Text(
                  'La instrucción se enviará a la IA junto con el contexto del proyecto '
                  'desde el que la ejecutes. Escríbela como si le pidieras algo a un '
                  'guionista: "Reescribe el hook para generar más curiosidad y propón 3 versiones".',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              }),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: isNew,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej. Mejorar hook',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Categoría (opcional)',
                  hintText: 'Ej. Títulos, Redacción…',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: contentCtrl,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Instrucción',
                  hintText:
                      'Ej. Reescribe el hook para generar más curiosidad…',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty ||
                  contentCtrl.text.trim().isEmpty) {
                return;
              }
              item
                ..name = nameCtrl.text.trim()
                ..category = categoryCtrl.text.trim()
                ..content = contentCtrl.text.trim();
              Get.find<PromptsController>().save(item);
              Get.back();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final PromptItem prompt;

  const _PromptCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PromptsController>();
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => PromptsView._edit(prompt),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      prompt.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    tooltip: 'Eliminar',
                    onPressed: () async {
                      final ok = await showConfirmDialog(
                        title: 'Eliminar prompt',
                        message: 'Se eliminará el prompt "${prompt.name}".',
                      );
                      if (ok) controller.delete(prompt);
                    },
                  ),
                ],
              ),
              if (prompt.category.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Text(prompt.category,
                      style: const TextStyle(fontSize: 11)),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  prompt.content.truncate(160),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.5, color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
