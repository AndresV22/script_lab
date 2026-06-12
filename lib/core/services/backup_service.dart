import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../ui/features/suggestions/models/ai_suggestion.dart';
import '../../ui/features/suggestions/services/suggestions_service.dart';
import '../../ui/features/projects/models/project.dart';
import '../../ui/features/projects/services/project_service.dart';
import '../../ui/features/prompts/models/prompt_item.dart';
import '../../ui/features/prompts/services/prompt_service.dart';
import '../../ui/features/settings/models/app_settings.dart';
import '../../ui/features/settings/models/channel_variables.dart';
import '../../ui/features/settings/models/project_defaults.dart';
import '../../ui/features/settings/models/style_sample.dart';
import '../../ui/features/structures/models/structure.dart';
import '../../ui/features/structures/services/structure_service.dart';
import '../constants/app_constants.dart';
import '../theme/theme_controller.dart';
import 'export_service.dart';
import 'settings_service.dart';
import 'storage_service.dart';

/// Exporta e importa un respaldo completo de la aplicación en JSON.
abstract class BackupService {
  static const backupVersion = 1;

  static Map<String, dynamic> buildBackup() => {
        'app': AppConstants.appName,
        'version': backupVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'projects': StorageService.projects.values
            .map((p) => p.toBackupJson())
            .toList(),
        'structures': StorageService.structures.values
            .map((s) => s.toBackupJson())
            .toList(),
        'prompts': StorageService.prompts.values
            .map((p) => p.toBackupJson())
            .toList(),
        'styleSamples': StorageService.styleSamples.values
            .map((s) => s.toBackupJson())
            .toList(),
        'settings': SettingsService.to.settings.value.toBackupJson(),
        'channel': SettingsService.to.channel.value.toBackupJson(),
        'projectDefaults':
            SettingsService.to.projectDefaults.value.toBackupJson(),
        'projectSuggestions': StorageService.suggestions.values
            .map((s) => s.toBackupJson())
            .toList(),
      };

  static Future<void> exportBackup() async {
    final now = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    await ExportService.exportRaw(
      'script_lab_backup_$date.json',
      const JsonEncoder.withIndent('  ').convert(buildBackup()),
      'application/json',
    );
    Get.snackbar('Respaldo', 'Respaldo exportado correctamente.',
        snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
  }

  /// Restaura un respaldo: reemplaza TODOS los datos actuales.
  static Future<void> restore(Map<String, dynamic> data) async {
    final version = (data['version'] as num?)?.toInt();
    if (version == null || version > backupVersion) {
      throw const FormatException('Versión de respaldo no compatible');
    }

    List<Map<String, dynamic>> items(String key) => ((data[key] as List?) ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    await StorageService.projects.clear();
    for (final json in items('projects')) {
      final project = Project.fromBackupJson(json);
      await StorageService.projects.put(project.id, project);
    }

    await StorageService.structures.clear();
    for (final json in items('structures')) {
      final structure = Structure.fromBackupJson(json);
      await StorageService.structures.put(structure.id, structure);
    }

    await StorageService.prompts.clear();
    for (final json in items('prompts')) {
      final prompt = PromptItem.fromBackupJson(json);
      await StorageService.prompts.put(prompt.id, prompt);
    }

    await StorageService.styleSamples.clear();
    for (final json in items('styleSamples')) {
      final sample = StyleSample.fromBackupJson(json);
      await StorageService.styleSamples.put(sample.id, sample);
    }

    if (data['settings'] is Map) {
      await StorageService.app.put(
        AppConstants.settingsKey,
        AppSettings.fromBackupJson(
            Map<String, dynamic>.from(data['settings'] as Map)),
      );
    }
    if (data['channel'] is Map) {
      await StorageService.app.put(
        AppConstants.channelKey,
        ChannelVariables.fromBackupJson(
            Map<String, dynamic>.from(data['channel'] as Map)),
      );
    }
    if (data['projectDefaults'] is Map) {
      await StorageService.app.put(
        AppConstants.projectDefaultsKey,
        ProjectDefaults.fromBackupJson(
            Map<String, dynamic>.from(data['projectDefaults'] as Map)),
      );
    }

    await StorageService.suggestions.clear();
    for (final json in items('projectSuggestions')) {
      final suggestion = AiSuggestion.fromBackupJson(json);
      await StorageService.suggestions.put(suggestion.id, suggestion);
    }

    // Refresca todos los servicios reactivos con los datos restaurados.
    SettingsService.to.reloadFromStorage();
    ProjectService.to.reload();
    SuggestionsService.to.reload();
    StructureService.to.reload();
    PromptService.to.reload();
    ThemeController.to.applyStoredMode();
  }

  /// Selecciona un archivo de respaldo, confirma y restaura.
  static Future<void> importBackup() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = result?.files.firstOrNull?.bytes;
    if (bytes == null) return;

    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(
          jsonDecode(utf8.decode(bytes)) as Map);
      if (data['version'] == null) {
        throw const FormatException('Falta la versión del respaldo');
      }
    } catch (_) {
      Get.snackbar(
          'Respaldo', 'El archivo no es un respaldo válido de Script Lab.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 400);
      return;
    }

    final projectCount = ((data['projects'] as List?) ?? []).length;
    final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Restaurar respaldo'),
            content: SizedBox(
              width: 420,
              child: Text(
                  'Se reemplazarán TODOS los datos actuales por el contenido '
                  'del respaldo ($projectCount proyectos). Esta acción no se '
                  'puede deshacer.\n\n¿Quieres continuar?'),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Restaurar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    try {
      await restore(data);
      Get.snackbar('Respaldo', 'Datos restaurados correctamente.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 360);
    } catch (e) {
      Get.snackbar('Respaldo', 'Error al restaurar: $e',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 420);
    }
  }
}
