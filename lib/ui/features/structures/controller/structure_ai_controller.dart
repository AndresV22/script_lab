import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/ollama_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../ai/services/ai_service.dart';
import '../../ai/views/widgets/model_picker_dialog.dart';
import '../models/structure.dart';
import '../services/structure_ai_service.dart';
import '../views/widgets/structure_ai_input_dialog.dart';
import '../views/widgets/structure_ai_result_dialog.dart';
import '../views/widgets/structure_editor_dialog.dart';

class StructureAiController extends GetxController {
  final isRunning = false.obs;
  final output = ''.obs;
  final error = ''.obs;
  final selectedModel = ''.obs;

  StreamSubscription<String>? _subscription;

  @override
  void onInit() {
    super.onInit();
    selectedModel.value = SettingsService.to.settings.value.defaultModel;
  }

  Future<void> launchGenerate() async {
    final input = await Get.dialog<StructureAiInput>(
      const StructureAiInputDialog(),
    );
    if (input == null) return;
    if (input.description.trim().isEmpty) {
      Get.snackbar(
        'Estructuras',
        'Describe la estructura que quieres crear.',
        snackPosition: SnackPosition.BOTTOM,
        maxWidth: 360,
      );
      return;
    }

    _generate(
      description: input.description.trim(),
      sectionsHint: input.sectionsHint.trim(),
    );
    Get.dialog(const StructureAiResultDialog(), barrierDismissible: false);
  }

  void _generate({required String description, required String sectionsHint}) {
    cancel();
    output.value = '';
    error.value = '';

    final prompt = StructureAiService.generatePrompt(
      description: description,
      sectionsHint: sectionsHint,
    );

    if (selectedModel.value.isEmpty) {
      _requestModel(onReady: () => _start(prompt));
      return;
    }
    _start(prompt);
  }

  void _start(String prompt) {
    isRunning.value = true;
    final stream = OllamaService.to.chat(
      model: selectedModel.value,
      system: AiService.buildSystemPrompt(),
      prompt: prompt,
    );
    _subscription = stream.listen(
      (chunk) => output.value += chunk,
      onError: (Object e) {
        error.value = e.toString();
        isRunning.value = false;
      },
      onDone: () => isRunning.value = false,
    );
  }

  void _requestModel({required VoidCallback onReady}) {
    final ollama = OllamaService.to;
    if (ollama.status.value == OllamaStatus.connected &&
        ollama.models.isNotEmpty) {
      Future.microtask(() => Get.dialog(
            ModelPickerDialog(
              onSelected: (model, saveAsDefault) {
                selectedModel.value = model;
                if (saveAsDefault) {
                  SettingsService.to.settings.value.defaultModel = model;
                  SettingsService.to.saveSettings();
                }
                onReady();
              },
              onCancel: () {
                error.value = 'No se seleccionó ningún modelo.';
              },
            ),
            barrierDismissible: false,
          ));
      return;
    }

    error.value =
        'Sin conexión con Ollama o sin modelos disponibles. Configura la conexión en Ajustes.';
    Future.microtask(() => Get.dialog(
          AlertDialog(
            title: const Text('Ollama no disponible'),
            content: const SizedBox(
              width: 400,
              child: Text(
                'No hay conexión con Ollama o no hay modelos instalados. '
                'Verifica que Ollama esté en ejecución y configura la URL y el modelo en Ajustes.',
              ),
            ),
            actions: [
              TextButton(onPressed: Get.back, child: const Text('Cerrar')),
              FilledButton(
                onPressed: () {
                  Get.back();
                  Get.offAllNamed(AppRoutes.settings);
                },
                child: const Text('Ir a Ajustes'),
              ),
            ],
          ),
        ));
  }

  void cancel() {
    _subscription?.cancel();
    _subscription = null;
    isRunning.value = false;
  }

  StructureGeneration? get parsed =>
      StructureAiService.parseStructure(output.value);

  void applyToEditor(BuildContext context) {
    final generation = parsed;
    if (generation == null) {
      Get.snackbar(
        'Estructuras',
        'No se pudo interpretar la respuesta. Revisa el JSON o vuelve a generar.',
        snackPosition: SnackPosition.BOTTOM,
        maxWidth: 420,
      );
      return;
    }

    final structure = Structure(
      id: const Uuid().v4(),
      name: generation.name,
      steps: generation.steps.map((s) => s.copy()).toList(),
    );

    Navigator.of(context).pop();

    Get.dialog(
      StructureEditorDialog(structure: structure, isNew: true),
    );
  }

  @override
  void onClose() {
    cancel();
    super.onClose();
  }
}
