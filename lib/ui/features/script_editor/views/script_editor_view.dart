import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../structures/models/structure.dart';
import '../../structures/services/structure_service.dart';
import '../controller/script_editor_controller.dart';
import 'widgets/section_tile.dart';

class ScriptEditorView extends StatelessWidget {
  const ScriptEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScriptEditorController>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => controller.addSection(),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Añadir sección'),
              ),
              const SizedBox(width: 10),
              _ApplyStructureButton(controller: controller),
              const Spacer(),
              Obx(() {
                final hasContent = controller.sections
                    .any((s) => s.content.trim().isNotEmpty);
                return Tooltip(
                  message: hasContent
                      ? 'Leer el guion a pantalla completa'
                      : 'Escribe contenido en el guion para usar el teleprompter',
                  child: OutlinedButton.icon(
                    onPressed: hasContent
                        ? () => Get.toNamed(AppRoutes.teleprompterPath(
                            controller.detail.project.id))
                        : null,
                    icon: const Icon(Icons.subtitles_outlined, size: 17),
                    label: const Text('Teleprompter'),
                  ),
                );
              }),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _showSaveVersionDialog(controller),
                icon: const Icon(Icons.history, size: 17),
                label: const Text('Guardar versión'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.sections.isEmpty) {
              return EmptyState(
                icon: Icons.notes_outlined,
                title: 'El guion está vacío',
                subtitle:
                    'Añade secciones manualmente o aplica una estructura reutilizable.',
                action: FilledButton.icon(
                  onPressed: () => controller.addSection(title: 'Hook inicial'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Primera sección'),
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                  buildDefaultDragHandles: false,
                  itemCount: controller.sections.length,
                  onReorder: controller.reorder,
                  itemBuilder: (context, index) {
                    final section = controller.sections[index];
                    return SectionTile(
                      key: ValueKey(section.id),
                      index: index,
                      section: section,
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showSaveVersionDialog(ScriptEditorController controller) {
    final labelCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Guardar versión'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: labelCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Etiqueta',
              hintText: 'Ej. Primer borrador completo',
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.detail.saveVersion(labelCtrl.text);
              Get.snackbar('Versiones', 'Versión guardada correctamente',
                  snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _ApplyStructureButton extends StatelessWidget {
  final ScriptEditorController controller;

  const _ApplyStructureButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Structure>(
      tooltip: 'Aplicar estructura',
      onSelected: (structure) async {
        await controller.detail.applyStructure(structure);
        controller.sync();
        Get.snackbar(
            'Estructura', 'Se aplicó la estructura "${structure.name}"',
            snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
      },
      itemBuilder: (_) {
        final structures = StructureService.to.structures;
        if (structures.isEmpty) {
          return [
            const PopupMenuItem(
              enabled: false,
              child: Text('No hay estructuras guardadas'),
            ),
          ];
        }
        return [
          for (final structure in structures)
            PopupMenuItem(
              value: structure,
              child: Text(
                  '${structure.name} (${structure.steps.length} secciones)'),
            ),
        ];
      },
      child: IgnorePointer(
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.account_tree_outlined, size: 17),
          label: const Text('Aplicar estructura'),
        ),
      ),
    );
  }
}
