import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/settings_service.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/view_mode_switcher.dart';
import '../controller/structure_ai_controller.dart';
import '../controller/structures_controller.dart';
import '../models/structure.dart';
import '../services/structure_service.dart';
import 'widgets/structure_editor_dialog.dart';

class StructuresView extends GetView<StructuresController> {
  const StructuresView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selected: AppSection.structures,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
            child: Row(
              children: [
                Text(
                  'Estructuras',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
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
                const SizedBox(width: 14),
                OutlinedButton.icon(
                  onPressed: controller.import,
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Importar'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () =>
                      Get.find<StructureAiController>().launchGenerate(),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                  label: const Text('Crear con IA'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () => _edit(context, null),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nueva estructura'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final structures = StructureService.to.structures;
              if (structures.isEmpty) {
                return EmptyState(
                  icon: Icons.account_tree_outlined,
                  title: 'Sin estructuras',
                  subtitle:
                      'Las estructuras son plantillas reutilizables de secciones\nque puedes aplicar a cualquier proyecto.',
                  action: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            Get.find<StructureAiController>().launchGenerate(),
                        icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                        label: const Text('Crear con IA'),
                      ),
                      FilledButton.icon(
                        onPressed: () => _edit(context, null),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nueva estructura'),
                      ),
                    ],
                  ),
                );
              }
              SettingsService.to.settings.value;
              if (controller.viewMode == 'list') {
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
                  itemCount: structures.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _StructureListRow(structure: structures[index]),
                );
              }
              final extents = cardExtents(
                controller.cardSize,
                s: (width: 300, height: 190),
                m: (width: 380, height: 230),
                l: (width: 460, height: 270),
              );
              final maxSteps = switch (controller.cardSize) {
                's' => 3,
                'l' => 7,
                _ => 5,
              };
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: extents.width,
                  mainAxisExtent: extents.height,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: structures.length,
                itemBuilder: (context, index) => _StructureCard(
                  structure: structures[index],
                  maxSteps: maxSteps,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  static void _edit(BuildContext context, Structure? structure) {
    Get.dialog(StructureEditorDialog(
      structure: structure ?? Structure(id: const Uuid().v4()),
      isNew: structure == null,
    ));
  }
}

/// Menú de acciones de la estructura, compartido entre cards y lista.
class _StructureMenu extends StatelessWidget {
  final Structure structure;

  const _StructureMenu({required this.structure});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StructuresController>();
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, size: 18, color: scheme.onSurfaceVariant),
      onSelected: (value) async {
        switch (value) {
          case 'duplicate':
            controller.duplicate(structure);
          case 'export':
            controller.export(structure);
          case 'delete':
            final ok = await showConfirmDialog(
              title: 'Eliminar estructura',
              message: 'Se eliminará la estructura "${structure.name}".',
            );
            if (ok) controller.delete(structure);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'duplicate', child: Text('Duplicar')),
        PopupMenuItem(value: 'export', child: Text('Exportar JSON')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'delete', child: Text('Eliminar')),
      ],
    );
  }
}

class _StructureCard extends StatelessWidget {
  final Structure structure;
  final int maxSteps;

  const _StructureCard({required this.structure, this.maxSteps = 4});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => StructuresView._edit(context, structure),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      structure.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  _StructureMenu(structure: structure),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ClipRect(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (i, step)
                          in structure.steps.take(maxSteps).indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${i + 1}. ${step.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.5,
                                color: scheme.onSurfaceVariant),
                          ),
                        ),
                      if (structure.steps.length > maxSteps)
                        Text(
                          '+${structure.steps.length - maxSteps} más…',
                          style: TextStyle(
                              fontSize: 12, color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ),
              Text(
                '${structure.steps.length} secciones',
                style: TextStyle(
                    fontSize: 11.5, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila de estructura en modo lista.
class _StructureListRow extends StatelessWidget {
  final Structure structure;

  const _StructureListRow({required this.structure});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => StructuresView._edit(context, structure),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.account_tree_outlined,
                  size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  structure.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '${structure.steps.length} secciones',
                style:
                    TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 4),
              _StructureMenu(structure: structure),
            ],
          ),
        ),
      ),
    );
  }
}
