import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../projects/controller/project_detail_controller.dart';
import '../models/script_section.dart';

/// Controla las secciones del guion del proyecto abierto.
class ScriptEditorController extends GetxController {
  final detail = Get.find<ProjectDetailController>();

  final sections = <ScriptSection>[].obs;

  /// Se incrementa con cada edición para refrescar contadores en vivo.
  final editTick = 0.obs;

  final _contentCtrls = <String, TextEditingController>{};
  final _titleCtrls = <String, TextEditingController>{};
  final _descriptionCtrls = <String, TextEditingController>{};

  @override
  void onInit() {
    super.onInit();
    sync();
  }

  /// Sincroniza la lista local con el proyecto (tras aplicar estructura,
  /// restaurar versión o aplicar cambios de IA).
  void sync() {
    sections.assignAll(detail.project.orderedSections);
    for (final section in sections) {
      contentCtrl(section);
      titleCtrl(section);
      descriptionCtrl(section);
    }
    refreshControllers();
  }

  /// Vuelca el contenido del modelo a los TextEditingControllers.
  void refreshControllers() {
    for (final section in sections) {
      final cCtrl = _contentCtrls[section.id];
      if (cCtrl != null && cCtrl.text != section.content) {
        cCtrl.text = section.content;
      }
      final tCtrl = _titleCtrls[section.id];
      if (tCtrl != null && tCtrl.text != section.title) {
        tCtrl.text = section.title;
      }
      final dCtrl = _descriptionCtrls[section.id];
      if (dCtrl != null && dCtrl.text != section.description) {
        dCtrl.text = section.description;
      }
    }
    editTick.value++;
  }

  TextEditingController contentCtrl(ScriptSection section) {
    return _contentCtrls.putIfAbsent(section.id, () {
      final ctrl = TextEditingController(text: section.content);
      ctrl.addListener(() {
        if (section.content == ctrl.text) return;
        section.content = ctrl.text;
        section.aiGenerated = false;
        editTick.value++;
        detail.markDirty();
      });
      return ctrl;
    });
  }

  TextEditingController titleCtrl(ScriptSection section) {
    return _titleCtrls.putIfAbsent(section.id, () {
      final ctrl = TextEditingController(text: section.title);
      ctrl.addListener(() {
        if (section.title == ctrl.text) return;
        section.title = ctrl.text;
        detail.markDirty();
      });
      return ctrl;
    });
  }

  TextEditingController descriptionCtrl(ScriptSection section) {
    return _descriptionCtrls.putIfAbsent(section.id, () {
      final ctrl = TextEditingController(text: section.description);
      ctrl.addListener(() {
        if (section.description == ctrl.text) return;
        section.description = ctrl.text;
        detail.markDirty();
      });
      return ctrl;
    });
  }

  void addSection({String title = ''}) {
    final section = ScriptSection(
      id: const Uuid().v4(),
      title: title.isEmpty ? 'Nueva sección' : title,
      order: detail.project.sections.length,
    );
    detail.project.sections.add(section);
    sync();
    detail.markDirty();
  }

  Future<void> removeSection(ScriptSection section) async {
    detail.project.sections.removeWhere((s) => s.id == section.id);
    _contentCtrls.remove(section.id)?.dispose();
    _titleCtrls.remove(section.id)?.dispose();
    _descriptionCtrls.remove(section.id)?.dispose();
    _normalizeOrder();
    sync();
    detail.markDirty();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final list = [...sections];
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    for (var i = 0; i < list.length; i++) {
      list[i].order = i;
    }
    sync();
    detail.markDirty();
  }

  void toggleExpanded(ScriptSection section) {
    section.expanded = !section.expanded;
    sections.refresh();
    detail.markDirty();
  }

  void _normalizeOrder() {
    final ordered = detail.project.orderedSections;
    for (var i = 0; i < ordered.length; i++) {
      ordered[i].order = i;
    }
  }

  @override
  void onClose() {
    for (final ctrl in _contentCtrls.values) {
      ctrl.dispose();
    }
    for (final ctrl in _titleCtrls.values) {
      ctrl.dispose();
    }
    for (final ctrl in _descriptionCtrls.values) {
      ctrl.dispose();
    }
    super.onClose();
  }
}
