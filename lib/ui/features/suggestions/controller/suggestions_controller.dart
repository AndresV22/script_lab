import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/ollama_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../ai/services/ai_service.dart';
import '../../ai/views/widgets/model_picker_dialog.dart';
import '../../projects/models/project.dart';
import '../../projects/services/project_service.dart';
import '../../prompts/models/prompt_item.dart';
import '../../prompts/services/prompt_service.dart';
import '../../script_editor/models/script_section.dart';
import '../../structures/models/structure.dart';
import '../../structures/services/structure_service.dart';
import '../../structures/views/widgets/structure_editor_dialog.dart';
import '../enums/suggestion_type.dart';
import '../models/ai_suggestion.dart';
import '../services/suggestions_ai_service.dart';
import '../services/suggestions_service.dart';
import '../views/widgets/suggestions_loading_dialog.dart';

class SuggestionsController extends GetxController {
  final isGenerating = false.obs;
  final error = ''.obs;
  final selectedModel = ''.obs;
  final loadingMessage = ''.obs;

  final _buffer = StringBuffer();
  var _loadingDialogOpen = false;

  SuggestionsService get _store => SuggestionsService.to;

  @override
  void onInit() {
    super.onInit();
    selectedModel.value = SettingsService.to.settings.value.defaultModel;
  }

  bool get isUnlocked => ProjectService.to.projects
      .any((p) => p.fullScriptText.trim().isNotEmpty);

  List<Project> get _projectsWithScript => ProjectService.to.projects
      .where((p) => p.fullScriptText.trim().isNotEmpty)
      .toList();

  List<AiSuggestion> byType(SuggestionType type) => _store.byType(type);

  /// Mezcla de sugerencias pendientes para el carrusel del dashboard.
  List<AiSuggestion> get dashboardPreview => _store.pending.take(8).toList();

  Future<void> generateInitial(SuggestionType type) =>
      _generate(type: type, count: SuggestionsAiService.batchSize);

  Future<void> addMore(SuggestionType type) => _generate(
        type: type,
        count: SuggestionsAiService.batchSize,
        avoidLabels: _avoidLabels(type),
      );

  Future<void> generateAll() async {
    if (isGenerating.value) return;
    if (!_ensureUnlocked()) return;

    Future<void> run() async {
      isGenerating.value = true;
      error.value = '';
      _openLoadingDialog();

      var totalAdded = 0;
      var totalRequested = 0;
      const types = SuggestionType.values;

      try {
        for (var i = 0; i < types.length; i++) {
          final type = types[i];
          final count = SuggestionsAiService.mixedBatchSize;
          totalRequested += count;

          loadingMessage.value =
              'Generando ${type.label.toLowerCase()} (${i + 1}/${types.length}). '
              'No cierres ni navegues fuera hasta que termine.';

          totalAdded += await _runGeneration(
            type: type,
            count: count,
            avoidLabels: _avoidLabels(type),
          );
        }

        if (totalAdded == 0) {
          Get.snackbar(
            'Sugerencias',
            'No se pudieron interpretar las sugerencias. Intenta de nuevo.',
            snackPosition: SnackPosition.BOTTOM,
            maxWidth: 420,
          );
        } else if (totalAdded < totalRequested) {
          Get.snackbar(
            'Sugerencias',
            'Se añadieron $totalAdded sugerencias (se pidieron $totalRequested).',
            snackPosition: SnackPosition.BOTTOM,
            maxWidth: 420,
          );
        }
      } catch (e) {
        error.value = e.toString();
        Get.snackbar(
          'Sugerencias',
          'Error al generar: $e',
          snackPosition: SnackPosition.BOTTOM,
          maxWidth: 420,
        );
      } finally {
        isGenerating.value = false;
        _closeLoadingDialog();
      }
    }

    if (selectedModel.value.isEmpty) {
      _requestModel(onReady: run);
      return;
    }
    await run();
  }

  List<String> _avoidLabels(SuggestionType type) =>
      byType(type).map((s) => s.displayTitle).where((t) => t.isNotEmpty).toList();

  Future<void> clearType(SuggestionType type) async {
    if (byType(type).isEmpty) return;
    final ok = await showConfirmDialog(
      title: 'Limpiar sugerencias',
      message:
          'Se eliminarán todas las sugerencias de ${type.label.toLowerCase()}.',
    );
    if (ok) await _store.clearType(type);
  }

  Future<void> clearAll() async {
    if (_store.suggestions.isEmpty) return;
    final ok = await showConfirmDialog(
      title: 'Limpiar todo',
      message:
          '¿Estás seguro de que quieres eliminar todas las sugerencias? '
          'Esta acción no se puede deshacer.',
    );
    if (ok) await _store.clearAll();
  }

  Future<void> dismiss(AiSuggestion suggestion) =>
      _store.delete(suggestion.id);

  Future<void> applyProject(AiSuggestion suggestion) async {
    final project = Project(
      id: const Uuid().v4(),
      topic: suggestion.topic,
      tentativeTitle: suggestion.tentativeTitle,
      altTitles: [...suggestion.altTitles],
      description: suggestion.description,
      tags: [...suggestion.tags],
      notes: suggestion.notes,
      structureId: suggestion.structureId,
    );

    if (suggestion.structureId.isNotEmpty) {
      final structure = StructureService.to.structures
          .firstWhereOrNull((s) => s.id == suggestion.structureId);
      if (structure != null) {
        for (final (i, step) in structure.steps.indexed) {
          project.sections.add(ScriptSection(
            id: const Uuid().v4(),
            title: step.name,
            description: step.description,
            order: i,
          ));
        }
      }
    }

    await ProjectService.to.save(project, touch: false);
    await _store.delete(suggestion.id);
    Get.toNamed(AppRoutes.projectDetailPath(project.id));
  }

  Future<void> applyStructure(AiSuggestion suggestion) async {
    final structure = Structure(
      id: const Uuid().v4(),
      name: suggestion.structureName,
      steps: suggestion.steps.map((s) => s.copy()).toList(),
    );

    Get.dialog(
      StructureEditorDialog(
        structure: structure,
        isNew: true,
        onSaved: () => _store.delete(suggestion.id),
      ),
    );
  }

  Future<void> applyPrompt(AiSuggestion suggestion) async {
    final prompt = PromptItem(
      id: const Uuid().v4(),
      name: suggestion.promptName,
      content: suggestion.promptContent,
      category: suggestion.promptCategory,
    );
    await PromptService.to.save(prompt);
    await _store.delete(suggestion.id);
    Get.snackbar(
      'Prompts',
      'Se guardó "${prompt.name}" en la biblioteca.',
      snackPosition: SnackPosition.BOTTOM,
      maxWidth: 380,
    );
  }

  bool _ensureUnlocked() {
    if (isUnlocked) return true;
    Get.snackbar(
      'Sugerencias',
      'Necesitas al menos un proyecto con guion escrito.',
      snackPosition: SnackPosition.BOTTOM,
      maxWidth: 400,
    );
    return false;
  }

  Future<void> _generate({
    required SuggestionType type,
    required int count,
    List<String> avoidLabels = const [],
  }) async {
    if (isGenerating.value) return;
    if (!_ensureUnlocked()) return;

    Future<void> run() async {
      isGenerating.value = true;
      error.value = '';
      _openLoadingDialog();
      loadingMessage.value =
          'La IA está creando $count sugerencias de ${type.label.toLowerCase()}. '
          'No cierres ni navegues fuera hasta que termine.';

      try {
        final added = await _runGeneration(
          type: type,
          count: count,
          avoidLabels: avoidLabels,
        );

        if (added == 0) {
          Get.snackbar(
            'Sugerencias',
            'No se pudieron interpretar las sugerencias. Intenta de nuevo.',
            snackPosition: SnackPosition.BOTTOM,
            maxWidth: 420,
          );
        } else if (added < count) {
          Get.snackbar(
            'Sugerencias',
            'Se añadieron $added sugerencias (se pidieron $count).',
            snackPosition: SnackPosition.BOTTOM,
            maxWidth: 420,
          );
        }
      } catch (e) {
        error.value = e.toString();
        Get.snackbar(
          'Sugerencias',
          'Error al generar: $e',
          snackPosition: SnackPosition.BOTTOM,
          maxWidth: 420,
        );
      } finally {
        isGenerating.value = false;
        _closeLoadingDialog();
      }
    }

    if (selectedModel.value.isEmpty) {
      _requestModel(onReady: run);
      return;
    }
    await run();
  }

  Future<int> _runGeneration({
    required SuggestionType type,
    required int count,
    List<String> avoidLabels = const [],
  }) async {
    _buffer.clear();

    final prompt = SuggestionsAiService.generatePrompt(
      type: type,
      projectsWithScript: _projectsWithScript,
      structures: StructureService.to.structures,
      prompts: PromptService.to.prompts,
      avoidLabels: avoidLabels,
      count: count,
    );

    final stream = OllamaService.to.chat(
      model: selectedModel.value,
      system: AiService.buildSystemPrompt(),
      prompt: prompt,
    );

    await for (final chunk in stream) {
      _buffer.write(chunk);
    }

    final parsed = SuggestionsAiService.parseSuggestions(
      _buffer.toString(),
      type,
      structures: StructureService.to.structures,
    );

    if (parsed.isEmpty) return 0;

    final toSave = parsed
        .map(
          (s) => AiSuggestion(
            id: const Uuid().v4(),
            type: s.type,
            topic: s.topic,
            tentativeTitle: s.tentativeTitle,
            altTitles: [...s.altTitles],
            description: s.description,
            tags: [...s.tags],
            notes: s.notes,
            structureId: s.structureId,
            structureName: s.structureName,
            steps: s.steps.map((step) => step.copy()).toList(),
            promptName: s.promptName,
            promptContent: s.promptContent,
            promptCategory: s.promptCategory,
          ),
        )
        .toList();

    await _store.saveAll(toSave);
    return parsed.length;
  }

  void _openLoadingDialog() {
    if (_loadingDialogOpen) return;
    _loadingDialogOpen = true;
    Get.dialog(
      Obx(
        () => SuggestionsLoadingDialog(message: loadingMessage.value),
      ),
      barrierDismissible: false,
    );
  }

  void _closeLoadingDialog() {
    if (!_loadingDialogOpen) return;
    _loadingDialogOpen = false;
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  void _requestModel({required VoidCallback onReady}) {
    final ollama = OllamaService.to;
    if (ollama.status.value == OllamaStatus.connected &&
        ollama.models.isNotEmpty) {
      Get.dialog(
        ModelPickerDialog(
          onSelected: (model, saveAsDefault) {
            selectedModel.value = model;
            if (saveAsDefault) {
              SettingsService.to.settings.value.defaultModel = model;
              SettingsService.to.saveSettings();
            }
            onReady();
          },
          onCancel: () {},
        ),
        barrierDismissible: false,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Ollama no disponible'),
        content: const SizedBox(
          width: 400,
          child: Text(
            'No hay conexión con Ollama o no hay modelos instalados. '
            'Configura la conexión en Ajustes.',
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
    );
  }
}
