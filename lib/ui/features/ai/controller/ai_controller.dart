import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/services/ollama_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../projects/controller/project_detail_controller.dart';
import '../../projects/models/project.dart';
import '../../prompts/models/prompt_item.dart';
import '../../script_editor/controller/script_editor_controller.dart';
import '../../script_editor/models/script_section.dart';
import '../../../../core/routes/app_routes.dart';
import '../enums/ai_task.dart';
import '../services/ai_service.dart';
import '../views/diff_review_view.dart';
import '../views/widgets/ai_instructions_dialog.dart';
import '../views/widgets/ai_result_dialog.dart';
import '../views/widgets/model_picker_dialog.dart';

/// Orquesta las tareas de IA sobre el proyecto abierto.
class AiController extends GetxController {
  final detail = Get.find<ProjectDetailController>();

  final isRunning = false.obs;
  final output = ''.obs;
  final error = ''.obs;
  final currentTask = Rxn<AiTask>();
  final selectedModel = ''.obs;

  ScriptSection? targetSection;
  StreamSubscription<String>? _subscription;

  Project get project => detail.project;

  ScriptEditorController get _editor => Get.find<ScriptEditorController>();

  @override
  void onInit() {
    super.onInit();
    selectedModel.value = SettingsService.to.settings.value.defaultModel;
  }

  // ----- Ejecución -----

  void _run(AiTask task, String prompt, {ScriptSection? section}) {
    cancel();
    targetSection = section;
    currentTask.value = task;
    output.value = '';
    error.value = '';

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

  /// Pide al usuario elegir un modelo cuando no hay ninguno seleccionado.
  /// Si hay conexión y modelos, abre el selector; si no, ofrece ir a Ajustes.
  ///
  /// Los diálogos se abren en un microtask para que queden POR ENCIMA del
  /// diálogo de resultado, que algunos flujos abren justo después de lanzar
  /// la tarea (p. ej. [launchMetadataTask] o [generateSectionDialog]).
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
                  'Verifica que Ollama esté en ejecución y configura la URL y el modelo en Ajustes.'),
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

  String get cleanedOutput => AiService.cleanOutput(output.value);

  // ----- Tareas desde el panel -----

  void runCorrection() => _run(AiTask.correction, AiService.correctionPrompt(project));

  void runAnalysis() => _run(AiTask.analysis, AiService.analysisPrompt(project));

  void runTitles({String extra = ''}) =>
      _run(AiTask.titles, AiService.titlesPrompt(project, extra: extra));

  void runTentativeTitle({String extra = ''}) => _run(AiTask.tentativeTitle,
      AiService.tentativeTitlePrompt(project, extra: extra));

  void runTags({String extra = ''}) =>
      _run(AiTask.tags, AiService.tagsPrompt(project, extra: extra));

  void runNotes({String extra = ''}) =>
      _run(AiTask.notes, AiService.notesPrompt(project, extra: extra));

  void runThumbnails({String extra = ''}) =>
      _run(AiTask.thumbnails, AiService.thumbnailsPrompt(project, extra: extra));

  void runHooks({String extra = ''}) =>
      _run(AiTask.hooks, AiService.hooksPrompt(project, extra: extra));

  void runDescription({String extra = ''}) =>
      _run(AiTask.description, AiService.descriptionPrompt(project, extra: extra));

  void runGenerateFull() =>
      _run(AiTask.generateFull, AiService.generateFullPrompt(project));

  void runGenerateSection(ScriptSection section) => _run(
        AiTask.generateSection,
        AiService.generateSectionPrompt(project, section),
        section: section,
      );

  void runSectionCorrection(ScriptSection section) => _run(
        AiTask.sectionCorrection,
        AiService.sectionCorrectionPrompt(project, section),
        section: section,
      );

  void runCustomPrompt(PromptItem prompt) =>
      _run(AiTask.custom, AiService.customPrompt(project, prompt.content));

  /// Pide indicaciones opcionales y ejecuta la tarea (null = canceló).
  Future<String?> _askInstructions(AiTask task) =>
      Get.dialog<String>(AiInstructionsDialog(task: task));

  /// Lanza la tarea con indicaciones opcionales según su tipo.
  void _dispatch(AiTask task, String extra) {
    switch (task) {
      case AiTask.titles:
        runTitles(extra: extra);
      case AiTask.tentativeTitle:
        runTentativeTitle(extra: extra);
      case AiTask.description:
        runDescription(extra: extra);
      case AiTask.tags:
        runTags(extra: extra);
      case AiTask.notes:
        runNotes(extra: extra);
      case AiTask.thumbnails:
        runThumbnails(extra: extra);
      case AiTask.hooks:
        runHooks(extra: extra);
      default:
        return;
    }
  }

  /// Desde el panel de IA: pide indicaciones opcionales y muestra la
  /// respuesta en el área de salida del panel.
  Future<void> promptAndRun(AiTask task) async {
    final extra = await _askInstructions(task);
    if (extra == null) return;
    _dispatch(task, extra.trim());
  }

  /// Lanza una tarea de metadatos del proyecto (con indicaciones opcionales)
  /// y abre el diálogo de resultado.
  Future<void> launchMetadataTask(AiTask task) async {
    if (!_hasMinimalContext) {
      Get.snackbar(
        'Asistente IA',
        'Añade al menos el tema del video o escribe algo en el guion.',
        snackPosition: SnackPosition.BOTTOM,
        maxWidth: 400,
      );
      return;
    }
    final extra = await _askInstructions(task);
    if (extra == null) return;
    _dispatch(task, extra.trim());
    Get.dialog(const AiResultDialog(), barrierDismissible: false);
  }

  bool get _hasMinimalContext =>
      project.topic.trim().isNotEmpty ||
      project.tentativeTitle.trim().isNotEmpty ||
      project.fullScriptText.trim().isNotEmpty;

  // ----- Diálogos desde el editor de guion -----

  void generateSectionDialog(ScriptSection section) {
    runGenerateSection(section);
    Get.dialog(const AiResultDialog(), barrierDismissible: false);
  }

  void correctSectionDialog(ScriptSection section) {
    if (section.content.trim().isEmpty) {
      Get.snackbar('Asistente IA', 'La sección está vacía: no hay nada que corregir.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 380);
      return;
    }
    runSectionCorrection(section);
    Get.dialog(const AiResultDialog(), barrierDismissible: false);
  }

  // ----- Acciones de aplicación -----

  Future<void> copyOutput() async {
    await Clipboard.setData(ClipboardData(text: cleanedOutput));
    Get.snackbar('Asistente IA', 'Respuesta copiada al portapapeles',
        snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
  }

  void addTitlesToAlternatives() {
    final titles = cleanedOutput.parsedListItems;
    if (titles.isEmpty) {
      Get.snackbar('Asistente IA', 'No se detectaron títulos en la respuesta.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
      return;
    }
    for (final title in titles) {
      if (!project.altTitles.contains(title)) {
        project.altTitles.add(title);
      }
    }
    detail.notifyChanged();
    Get.snackbar('Títulos',
        'Se añadieron ${titles.length} alternativas de título al proyecto.',
        snackPosition: SnackPosition.BOTTOM, maxWidth: 380);
  }

  void applyTentativeTitle() {
    final title = AiService.parseSingleTitle(cleanedOutput);
    if (title.isEmpty) {
      Get.snackbar('Asistente IA', 'No se detectó un título en la respuesta.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
      return;
    }
    final previous = project.tentativeTitle.trim();
    if (previous.isNotEmpty && previous != title) {
      project.altTitles.add(previous);
    }
    project.tentativeTitle = title;
    detail.titleCtrl.text = title;
    detail.notifyChanged();
    Get.snackbar('Título', 'Título tentativo actualizado.',
        snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
  }

  void applyDescription() {
    detail.descriptionCtrl.text = cleanedOutput;
    detail.markDirty();
    Get.snackbar('Descripción', 'Descripción del video actualizada.',
        snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
  }

  void applyTags({bool replace = false}) {
    final tags = AiService.parseTags(cleanedOutput);
    if (tags.isEmpty) {
      Get.snackbar('Asistente IA', 'No se detectaron etiquetas en la respuesta.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
      return;
    }
    if (replace) project.tags.clear();
    var added = 0;
    for (final tag in tags) {
      if (!project.tags.contains(tag)) {
        project.tags.add(tag);
        added++;
      }
    }
    detail.notifyChanged();
    Get.snackbar('Etiquetas',
        replace
            ? 'Se aplicaron ${tags.length} etiquetas.'
            : 'Se añadieron $added etiquetas nuevas.',
        snackPosition: SnackPosition.BOTTOM, maxWidth: 380);
  }

  void applyNotes({bool append = false}) {
    final notes = cleanedOutput.trim();
    if (notes.isEmpty) {
      Get.snackbar('Asistente IA', 'La respuesta está vacía.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
      return;
    }
    if (append && project.notes.trim().isNotEmpty) {
      detail.notesCtrl.text = '${project.notes.trim()}\n\n$notes';
    } else {
      detail.notesCtrl.text = notes;
    }
    detail.markDirty();
    Get.snackbar('Notas', append ? 'Notas añadidas al final.' : 'Notas actualizadas.',
        snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
  }

  void insertIntoTargetSection() {
    final section = targetSection;
    if (section == null) return;
    section.content = cleanedOutput;
    section.aiGenerated = true;
    _editor.refreshControllers();
    detail.markDirty();
  }

  void reviewSectionCorrection() {
    final section = targetSection;
    if (section == null) return;
    DiffReviewView.show(
      title: 'Corrección de "${section.title}"',
      original: section.content,
      proposed: cleanedOutput,
      onApply: (result) {
        section.content = result;
        _editor.refreshControllers();
        detail.markDirty();
      },
    );
  }

  void reviewFullCorrection() {
    DiffReviewView.show(
      title: 'Corrección del guion completo',
      original: project.fullScriptText,
      proposed: cleanedOutput,
      onApply: applyFullScript,
    );
  }

  /// Aplica un guion con encabezados "## Sección" al proyecto,
  /// reemplazando todas las secciones existentes por las generadas.
  Future<void> applyFullScript(String text) async {
    final parsed = AiService.parseSections(text);
    if (parsed.isEmpty) {
      Get.snackbar('Asistente IA',
          'No se encontraron secciones con formato "## Título" en la respuesta.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 400);
      return;
    }
    if (project.fullScriptText.trim().isNotEmpty) {
      await detail.saveVersion('Antes de aplicar IA');
    }

    project.sections.clear();
    for (final (i, (title, content)) in parsed.indexed) {
      project.sections.add(ScriptSection(
        id: const Uuid().v4(),
        title: title,
        content: content,
        order: i,
        aiGenerated: true,
      ));
    }
    _editor.sync();
    detail.notifyChanged();
    Get.snackbar('Guion', 'El guion se actualizó con la propuesta de la IA.',
        snackPosition: SnackPosition.BOTTOM, maxWidth: 380);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
