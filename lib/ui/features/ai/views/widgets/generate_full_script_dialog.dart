import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/labeled_field.dart';
import '../../../structures/services/structure_service.dart';
import '../../controller/generate_full_script_dialog_controller.dart';
import '../../models/generate_full_script_request.dart';

/// Pide el prompt y la plantilla de estructura antes de generar el guion.
class GenerateFullScriptDialog extends StatelessWidget {
  const GenerateFullScriptDialog({super.key});

  static Future<GenerateFullScriptRequest?> show() {
    Get.put(GenerateFullScriptDialogController());
    return Get.dialog<GenerateFullScriptRequest>(
      const GenerateFullScriptDialog(),
    ).whenComplete(Get.delete<GenerateFullScriptDialogController>);
  }

  void _cancel() =>
      Get.find<GenerateFullScriptDialogController>().cancel();

  void _confirm() =>
      Get.find<GenerateFullScriptDialogController>().confirm();

  String _structureHelper(String current) {
    if (current == GenerateFullScriptRequest.projectSections) {
      return 'El guion sigue las secciones que el proyecto ya tiene. '
          'El prompt se aplica dentro de cada una.';
    }
    if (current.isEmpty) {
      return 'El guion sigue el prompt. Si ahí pides secciones, '
          'esas serán las del guion.';
    }
    return 'El guion sigue el orden de la plantilla. '
        'El prompt se aplica dentro de cada sección.';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GenerateFullScriptDialogController>();
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Generar guion completo'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'El prompt guía el guion. Puedes seguir las secciones '
                'actuales del proyecto, dejar la estructura libre o elegir '
                'una plantilla guardada.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Prompt',
                helper:
                    'Si lo escribes, el guion se crea desde cero con este texto. '
                    'Puedes dejarlo vacío.',
                child: TextField(
                  controller: controller.promptCtrl,
                  autofocus: true,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText:
                        'Ej. Empieza con el precio, compara tres modelos y cierra con una recomendación para principiantes.',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Obx(() {
                final structures = StructureService.to.structures;
                final selected = controller.selectedStructureId.value;
                final hasTemplate =
                    structures.any((structure) => structure.id == selected);
                final current = hasTemplate ||
                        selected == GenerateFullScriptRequest.projectSections ||
                        selected.isEmpty
                    ? selected
                    : GenerateFullScriptRequest.projectSections;
                return LabeledField(
                  label: 'Estructura',
                  helper: _structureHelper(current),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(current),
                    initialValue: current,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: GenerateFullScriptRequest.projectSections,
                        child: Text('Secciones actuales del proyecto'),
                      ),
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Ninguna'),
                      ),
                      for (final structure in structures)
                        DropdownMenuItem(
                          value: structure.id,
                          child: Text(
                            structure.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                    ],
                    onChanged: controller.selectStructure,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _cancel, child: const Text('Cancelar')),
        FilledButton.icon(
          onPressed: _confirm,
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const Text('Generar'),
        ),
      ],
    );
  }
}
