import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/structure.dart';
import '../../services/structure_service.dart';

/// Editor de una estructura: nombre y pasos reordenables.
/// Stateful porque mantiene estado local de edición hasta guardar.
class StructureEditorDialog extends StatefulWidget {
  final Structure structure;
  final bool isNew;
  final VoidCallback? onSaved;

  const StructureEditorDialog({
    super.key,
    required this.structure,
    required this.isNew,
    this.onSaved,
  });

  @override
  State<StructureEditorDialog> createState() => _StructureEditorDialogState();
}

class _StructureEditorDialogState extends State<StructureEditorDialog> {
  late final TextEditingController nameCtrl;
  late final List<StructureStep> steps;
  final stepCtrls = <TextEditingController>[];
  final descCtrls = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.structure.name);
    steps = widget.structure.steps.map((s) => s.copy()).toList();
    for (final step in steps) {
      stepCtrls.add(TextEditingController(text: step.name));
      descCtrls.add(TextEditingController(text: step.description));
    }
    if (steps.isEmpty) _addStep();
  }

  void _addStep() {
    setState(() {
      steps.add(StructureStep());
      stepCtrls.add(TextEditingController());
      descCtrls.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    setState(() {
      steps.removeAt(index);
      stepCtrls.removeAt(index).dispose();
      descCtrls.removeAt(index).dispose();
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      steps.insert(newIndex, steps.removeAt(oldIndex));
      stepCtrls.insert(newIndex, stepCtrls.removeAt(oldIndex));
      descCtrls.insert(newIndex, descCtrls.removeAt(oldIndex));
    });
  }

  Future<void> _save() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Estructuras', 'La estructura necesita un nombre.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
      return;
    }
    final validSteps = <StructureStep>[];
    for (var i = 0; i < steps.length; i++) {
      final stepName = stepCtrls[i].text.trim();
      if (stepName.isNotEmpty) {
        validSteps.add(StructureStep(
          name: stepName,
          description: descCtrls[i].text.trim(),
        ));
      }
    }
    if (validSteps.isEmpty) {
      Get.snackbar('Estructuras', 'Añade al menos una sección.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
      return;
    }
    widget.structure
      ..name = name
      ..steps = validSteps;
    await StructureService.to.save(widget.structure);
    widget.onSaved?.call();
    Get.back();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    for (final ctrl in stepCtrls) {
      ctrl.dispose();
    }
    for (final ctrl in descCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  Text(
                    widget.isNew ? 'Nueva estructura' : 'Editar estructura',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: Get.back,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                controller: nameCtrl,
                autofocus: widget.isNew,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej. Review de relojes',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Text(
                    'SECCIONES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addStep,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Añadir'),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: steps.length,
                onReorder: _reorder,
                itemBuilder: (context, index) => Padding(
                  key: ValueKey('step_$index'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(Icons.drag_indicator,
                                size: 18, color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('${index + 1}.',
                            style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            TextField(
                              controller: stepCtrls[index],
                              decoration: const InputDecoration(
                                hintText: 'Nombre de la sección',
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: descCtrls[index],
                              minLines: 1,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                                color: scheme.onSurfaceVariant,
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Descripción para la IA (opcional): qué debe cubrir esta sección…',
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        tooltip: 'Eliminar',
                        onPressed: () => _removeStep(index),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: Get.back, child: const Text('Cancelar')),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _save, child: const Text('Guardar')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
