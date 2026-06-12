import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../script_editor/models/script_section.dart';
import '../../script_editor/models/script_version.dart';
import '../../structures/models/structure.dart';
import '../enums/project_status.dart';
import '../models/project.dart';
import '../services/project_service.dart';

/// Controlador del detalle de un proyecto. Centraliza el autoguardado.
class ProjectDetailController extends GetxController {
  late final Project project;
  final loaded = false.obs;

  final saving = false.obs;
  final lastSaved = Rxn<DateTime>();
  final _dirtyTick = 0.obs;

  // Reactivo para refrescar la UI cuando cambian listas internas del proyecto.
  final revision = 0.obs;

  late final TextEditingController topicCtrl;
  late final TextEditingController titleCtrl;
  late final TextEditingController descriptionCtrl;
  late final TextEditingController notesCtrl;

  final status = ProjectStatus.idea.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.parameters['id'] ?? '';
    final found = ProjectService.to.byId(id);
    if (found == null) {
      Get.offAllNamed('/projects');
      return;
    }
    project = found;
    status.value = project.status;

    topicCtrl = TextEditingController(text: project.topic);
    titleCtrl = TextEditingController(text: project.tentativeTitle);
    descriptionCtrl = TextEditingController(text: project.description);
    notesCtrl = TextEditingController(text: project.notes);

    topicCtrl.addListener(() => _onTextChanged());
    titleCtrl.addListener(() => _onTextChanged());
    descriptionCtrl.addListener(() => _onTextChanged());
    notesCtrl.addListener(() => _onTextChanged());

    debounce(_dirtyTick, (_) => save(),
        time: const Duration(milliseconds: 800));
    loaded.value = true;
  }

  void _onTextChanged() {
    project
      ..topic = topicCtrl.text
      ..tentativeTitle = titleCtrl.text
      ..description = descriptionCtrl.text
      ..notes = notesCtrl.text;
    markDirty();
  }

  /// Marca el proyecto como modificado; el autoguardado se dispara con debounce.
  void markDirty() {
    _dirtyTick.value++;
  }

  void notifyChanged() {
    revision.value++;
    markDirty();
  }

  Future<void> save() async {
    saving.value = true;
    await ProjectService.to.save(project);
    saving.value = false;
    lastSaved.value = DateTime.now();
  }

  // ----- Estado -----

  void setStatus(ProjectStatus newStatus) {
    project.status = newStatus;
    status.value = newStatus;
    markDirty();
  }

  // ----- Títulos alternativos -----

  void addAltTitle(String title) {
    project.altTitles.add(title);
    notifyChanged();
  }

  void removeAltTitle(int index) {
    project.altTitles.removeAt(index);
    notifyChanged();
  }

  /// Convierte una alternativa en el título tentativo (y guarda el anterior).
  void promoteAltTitle(int index) {
    final selected = project.altTitles.removeAt(index);
    final previous = project.tentativeTitle.trim();
    if (previous.isNotEmpty) project.altTitles.add(previous);
    project.tentativeTitle = selected;
    titleCtrl.text = selected;
    notifyChanged();
  }

  // ----- Etiquetas -----

  void addTag(String tag) {
    if (project.tags.contains(tag)) return;
    project.tags.add(tag);
    notifyChanged();
  }

  void removeTag(int index) {
    project.tags.removeAt(index);
    notifyChanged();
  }

  // ----- Miniaturas -----

  Future<void> pickThumbnail({required bool asTentative}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final bytes = result?.files.firstOrNull?.bytes;
    if (bytes == null) return;
    final encoded = base64Encode(bytes);
    if (asTentative) {
      if (project.thumbnail.isNotEmpty) {
        project.altThumbnails.add(project.thumbnail);
      }
      project.thumbnail = encoded;
    } else {
      project.altThumbnails.add(encoded);
    }
    notifyChanged();
  }

  void promoteThumbnail(int index) {
    final selected = project.altThumbnails.removeAt(index);
    if (project.thumbnail.isNotEmpty) {
      project.altThumbnails.add(project.thumbnail);
    }
    project.thumbnail = selected;
    notifyChanged();
  }

  void removeThumbnail({int? altIndex}) {
    if (altIndex == null) {
      project.thumbnail = '';
    } else {
      project.altThumbnails.removeAt(altIndex);
    }
    notifyChanged();
  }

  // ----- Versiones -----

  Future<void> saveVersion(String label) async {
    project.versions.add(ScriptVersion(
      id: const Uuid().v4(),
      label: label.trim().isEmpty ? 'Versión manual' : label.trim(),
      sections: project.orderedSections.map((s) => s.copy()).toList(),
    ));
    notifyChanged();
    await save();
  }

  Future<void> restoreVersion(ScriptVersion version) async {
    await saveVersion('Antes de restaurar');
    project.sections
      ..clear()
      ..addAll(version.sections.map((s) => s.copy()));
    notifyChanged();
    await save();
  }

  Future<void> deleteVersion(ScriptVersion version) async {
    project.versions.removeWhere((v) => v.id == version.id);
    notifyChanged();
    await save();
  }

  // ----- Estructuras -----

  Future<void> applyStructure(Structure structure) async {
    var order = project.sections.length;
    for (final step in structure.steps) {
      project.sections.add(ScriptSection(
        id: const Uuid().v4(),
        title: step.name,
        content: '',
        description: step.description,
        order: order++,
      ));
    }
    project.structureId = structure.id;
    notifyChanged();
    await save();
  }

  @override
  void onClose() {
    topicCtrl.dispose();
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }
}
