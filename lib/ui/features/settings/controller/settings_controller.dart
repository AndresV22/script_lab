import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/ollama_service.dart';
import '../../../../core/services/settings_service.dart';
import '../models/style_sample.dart';

class SettingsController extends GetxController {
  final settings = SettingsService.to;
  final ollama = OllamaService.to;

  late final TextEditingController urlCtrl;
  late final TextEditingController channelNameCtrl;
  late final TextEditingController greetingCtrl;
  late final TextEditingController audienceCtrl;
  late final TextEditingController styleCtrl;
  late final TextEditingController avoidCtrl;
  late final TextEditingController durationCtrl;
  late final TextEditingController defaultDescriptionCtrl;
  late final TextEditingController defaultNotesCtrl;

  final testing = false.obs;

  @override
  void onInit() {
    super.onInit();
    urlCtrl = TextEditingController(text: settings.settings.value.ollamaUrl);
    final channel = settings.channel.value;
    channelNameCtrl = TextEditingController(text: channel.channelName);
    greetingCtrl = TextEditingController(text: channel.greeting);
    audienceCtrl = TextEditingController(text: channel.audience);
    styleCtrl = TextEditingController(text: channel.style);
    avoidCtrl = TextEditingController(text: channel.avoid);
    durationCtrl = TextEditingController(text: channel.avgDuration);

    channelNameCtrl.addListener(_saveChannel);
    greetingCtrl.addListener(_saveChannel);
    audienceCtrl.addListener(_saveChannel);
    styleCtrl.addListener(_saveChannel);
    avoidCtrl.addListener(_saveChannel);
    durationCtrl.addListener(_saveChannel);

    final defaults = settings.projectDefaults.value;
    defaultDescriptionCtrl =
        TextEditingController(text: defaults.description);
    defaultNotesCtrl = TextEditingController(text: defaults.notes);
    defaultDescriptionCtrl.addListener(_saveDefaultsText);
    defaultNotesCtrl.addListener(_saveDefaultsText);
  }

  void _saveChannel() {
    settings.channel.value
      ..channelName = channelNameCtrl.text
      ..greeting = greetingCtrl.text
      ..audience = audienceCtrl.text
      ..style = styleCtrl.text
      ..avoid = avoidCtrl.text
      ..avgDuration = durationCtrl.text;
    settings.saveChannel();
  }

  void _saveDefaultsText() {
    settings.projectDefaults.value
      ..description = defaultDescriptionCtrl.text
      ..notes = defaultNotesCtrl.text;
    settings.saveProjectDefaults();
  }

  void addDefaultTag(String tag) {
    final defaults = settings.projectDefaults.value;
    if (defaults.tags.contains(tag)) return;
    defaults.tags.add(tag);
    settings.saveProjectDefaults();
  }

  void removeDefaultTag(int index) {
    settings.projectDefaults.value.tags.removeAt(index);
    settings.saveProjectDefaults();
  }

  void setDefaultStructure(String? structureId) {
    settings.projectDefaults.value.structureId = structureId ?? '';
    settings.saveProjectDefaults();
  }

  Future<void> testConnection() async {
    settings.settings.value.ollamaUrl = urlCtrl.text.trim();
    await settings.saveSettings();
    testing.value = true;
    final ok = await ollama.checkConnection();
    testing.value = false;
    Get.snackbar(
      'Ollama',
      ok
          ? 'Conexión exitosa: ${ollama.models.length} modelos disponibles'
          : 'No se pudo conectar: ${ollama.lastError.value}',
      snackPosition: SnackPosition.BOTTOM,
      maxWidth: 420,
    );
  }

  Future<void> setDefaultModel(String? model) async {
    settings.settings.value.defaultModel = model ?? '';
    await settings.saveSettings();
  }

  Future<void> setThinkMode(String mode) async {
    settings.settings.value.thinkMode = mode;
    await settings.saveSettings();
  }

  Future<void> setWordsPerMinute(int wpm) async {
    settings.settings.value.wordsPerMinute = wpm;
    await settings.saveSettings();
  }

  // ----- Entrenamiento de estilo -----

  Future<void> importStyleSamples() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'markdown'],
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    var imported = 0;
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) continue;
      String content;
      try {
        content = utf8.decode(bytes);
      } catch (_) {
        content = latin1.decode(bytes);
      }
      if (content.trim().isEmpty) continue;
      await settings.addStyleSample(StyleSample(
        id: const Uuid().v4(),
        name: file.name,
        content: content,
      ));
      imported++;
    }
    if (imported > 0) {
      Get.snackbar('Estilo',
          'Se importaron $imported transcripciones para entrenar el estilo.',
          snackPosition: SnackPosition.BOTTOM, maxWidth: 420);
    }
  }

  Future<void> deleteStyleSample(StyleSample sample) =>
      settings.deleteStyleSample(sample.id);

  @override
  void onClose() {
    urlCtrl.dispose();
    channelNameCtrl.dispose();
    greetingCtrl.dispose();
    audienceCtrl.dispose();
    styleCtrl.dispose();
    avoidCtrl.dispose();
    durationCtrl.dispose();
    defaultDescriptionCtrl.dispose();
    defaultNotesCtrl.dispose();
    super.onClose();
  }
}
