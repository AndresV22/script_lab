import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/export_service.dart';
import '../../../../core/services/settings_service.dart';
import '../models/structure.dart';
import '../services/structure_service.dart';

class StructuresController extends GetxController {
  List<Structure> get structures => StructureService.to.structures;

  Future<void> save(Structure structure) => StructureService.to.save(structure);

  Future<void> delete(Structure structure) =>
      StructureService.to.delete(structure.id);

  Future<void> duplicate(Structure structure) async {
    final copy = Structure(
      id: const Uuid().v4(),
      name: '${structure.name} (copia)',
      steps: structure.steps.map((s) => s.copy()).toList(),
    );
    await StructureService.to.save(copy);
  }

  Future<void> export(Structure structure) async {
    final json = const JsonEncoder.withIndent('  ').convert(structure.toJson());
    final filename = structure.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9áéíóúñü ]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    await ExportService.exportRaw(
        'estructura_$filename.json', json, 'application/json');
  }

  Future<void> import() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = result?.files.firstOrNull?.bytes;
    if (bytes == null) return;
    try {
      final data =
          jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final structure = Structure.fromJson(data, const Uuid().v4());
      if (structure.name.isEmpty || structure.steps.isEmpty) {
        throw const FormatException('Estructura incompleta');
      }
      await StructureService.to.save(structure);
      Get.snackbar('Estructuras', 'Se importó "${structure.name}"',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
    } catch (_) {
      Get.snackbar('Estructuras',
          'El archivo no tiene un formato de estructura válido.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 380);
    }
  }

  // ----- Vista -----

  String get viewMode => SettingsService.to.settings.value.structuresViewMode;

  String get cardSize => SettingsService.to.settings.value.cardSize;

  Future<void> setViewMode(String mode) async {
    SettingsService.to.settings.value.structuresViewMode = mode;
    await SettingsService.to.saveSettings();
  }

  Future<void> setCardSize(String size) async {
    SettingsService.to.settings.value.cardSize = size;
    await SettingsService.to.saveSettings();
  }
}
