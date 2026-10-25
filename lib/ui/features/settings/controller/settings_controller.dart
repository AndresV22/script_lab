import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/llm_provider.dart';
import '../../../../core/services/llm_service.dart';
import '../../../../core/services/settings_service.dart';
import '../models/style_sample.dart';

class SettingsController extends GetxController {
  final settings = SettingsService.to;
  final llm = LlmService.to;

  late final TextEditingController urlCtrl;
  late final TextEditingController deepseekUrlCtrl;
  late final TextEditingController deepseekKeyCtrl;
  late final TextEditingController hiveUrlCtrl;
  late final TextEditingController hiveKeyCtrl;
  late final TextEditingController openaiUrlCtrl;
  late final TextEditingController openaiKeyCtrl;
  late final TextEditingController claudeUrlCtrl;
  late final TextEditingController claudeKeyCtrl;
  late final TextEditingController customModelCtrl;

  final hideDeepseekKey = true.obs;
  final hideHiveKey = true.obs;
  final hideOpenaiKey = true.obs;
  final hideClaudeKey = true.obs;
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
    final stored = settings.settings.value;
    urlCtrl = TextEditingController(text: stored.ollamaUrl);
    deepseekUrlCtrl = TextEditingController(text: stored.deepseekBaseUrl);
    deepseekKeyCtrl = TextEditingController(text: stored.deepseekApiKey);
    hiveUrlCtrl = TextEditingController(text: stored.hiveBaseUrl);
    hiveKeyCtrl = TextEditingController(text: stored.hiveApiKey);
    openaiUrlCtrl = TextEditingController(text: stored.openaiBaseUrl);
    openaiKeyCtrl = TextEditingController(text: stored.openaiApiKey);
    claudeUrlCtrl = TextEditingController(text: stored.claudeBaseUrl);
    claudeKeyCtrl = TextEditingController(text: stored.claudeApiKey);
    customModelCtrl = TextEditingController(text: stored.defaultModel);
    deepseekUrlCtrl.addListener(_saveExternal);
    deepseekKeyCtrl.addListener(_saveExternal);
    hiveUrlCtrl.addListener(_saveExternal);
    hiveKeyCtrl.addListener(_saveExternal);
    openaiUrlCtrl.addListener(_saveExternal);
    openaiKeyCtrl.addListener(_saveExternal);
    claudeUrlCtrl.addListener(_saveExternal);
    claudeKeyCtrl.addListener(_saveExternal);
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

  void _saveExternal() {
    final stored = settings.settings.value;
    stored
      ..deepseekBaseUrl = deepseekUrlCtrl.text.trim()
      ..deepseekApiKey = deepseekKeyCtrl.text.trim()
      ..hiveBaseUrl = hiveUrlCtrl.text.trim()
      ..hiveApiKey = hiveKeyCtrl.text.trim()
      ..openaiBaseUrl = openaiUrlCtrl.text.trim()
      ..openaiApiKey = openaiKeyCtrl.text.trim()
      ..claudeBaseUrl = claudeUrlCtrl.text.trim()
      ..claudeApiKey = claudeKeyCtrl.text.trim();
    settings.saveSettings();
  }

  void toggleDeepseekKeyVisibility() => hideDeepseekKey.toggle();

  void toggleHiveKeyVisibility() => hideHiveKey.toggle();

  void toggleOpenaiKeyVisibility() => hideOpenaiKey.toggle();

  void toggleClaudeKeyVisibility() => hideClaudeKey.toggle();

  void onProviderSelected(Set<String> selection) {
    unawaited(setLlmProvider(selection.first));
  }

  void onDeepseekVersionSelected(Set<String> selection) {
    unawaited(setProviderApiVersion(LlmProvider.deepseek, selection.first));
  }

  void onHiveVersionSelected(Set<String> selection) {
    unawaited(setProviderApiVersion(LlmProvider.hive, selection.first));
  }

  void onOpenaiVersionSelected(Set<String> selection) {
    unawaited(setProviderApiVersion(LlmProvider.openai, selection.first));
  }

  void onClaudeVersionSelected(Set<String> selection) {
    unawaited(setProviderApiVersion(LlmProvider.claude, selection.first));
  }

  void onTestDeepseek() {
    unawaited(testProvider(LlmProvider.deepseek));
  }

  void onTestHive() {
    unawaited(testProvider(LlmProvider.hive));
  }

  void onTestOpenai() {
    unawaited(testProvider(LlmProvider.openai));
  }

  void onTestClaude() {
    unawaited(testProvider(LlmProvider.claude));
  }

  Future<void> setLlmProvider(String provider) async {
    if (!LlmProvider.values.contains(provider)) return;
    settings.settings.value.llmProvider = provider;
    await settings.saveSettings();
    await llm.checkConnection();
  }

  Future<void> setProviderApiVersion(String provider, String version) async {
    if (!LlmProvider.apiVersions.contains(version)) return;
    final stored = settings.settings.value;
    switch (provider) {
      case LlmProvider.hive:
        stored.hiveApiVersion = version;
        _applyVersion(hiveUrlCtrl, provider, version);
      case LlmProvider.openai:
        stored.openaiApiVersion = version;
        _applyVersion(openaiUrlCtrl, provider, version);
      case LlmProvider.claude:
        stored.claudeApiVersion = version;
        _applyVersion(claudeUrlCtrl, provider, version);
      case LlmProvider.deepseek:
        stored.deepseekApiVersion = version;
        _applyVersion(deepseekUrlCtrl, provider, version);
      default:
        return;
    }
    await settings.saveSettings();
  }

  Future<void> testProvider(String provider) async {
    settings.settings.value.llmProvider = provider;
    await testConnection();
  }

  void _applyVersion(
    TextEditingController controller,
    String provider,
    String version,
  ) {
    final current = controller.text.trim();
    if (current.isEmpty || LlmProvider.isPreset(current)) {
      controller.text = LlmProvider.presetBaseUrl(provider, version);
      return;
    }
    final updated = LlmProvider.replaceApiVersion(current, provider, version);
    if (updated != current) controller.text = updated;
  }

  Future<void> testConnection() async {
    settings.settings.value.ollamaUrl = urlCtrl.text.trim();
    _saveExternal();
    await settings.saveSettings();
    testing.value = true;
    final ok = await llm.checkConnection();
    testing.value = false;
    final name = LlmProvider.label(settings.settings.value.llmProvider);
    final success = llm.usedCatalog
        ? 'El servidor no lista modelos. Se cargó el catálogo documentado.'
        : 'Conexión exitosa: ${llm.models.length} modelos disponibles';
    Get.snackbar(
      name,
      ok ? success : 'No se pudo conectar: ${llm.lastError.value}',
      snackPosition: SnackPosition.BOTTOM,
      maxWidth: 460,
    );
  }

  Future<void> useCustomModel() async {
    final id = customModelCtrl.text.trim();
    if (id.isEmpty) return;
    if (!llm.models.contains(id)) llm.models.add(id);
    await setDefaultModel(id);
  }

  Future<void> setDefaultModel(String? model) async {
    final value = model ?? '';
    settings.settings.value.defaultModel = value;
    if (customModelCtrl.text != value) customModelCtrl.text = value;
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
    channelNameCtrl.removeListener(_saveChannel);
    greetingCtrl.removeListener(_saveChannel);
    audienceCtrl.removeListener(_saveChannel);
    styleCtrl.removeListener(_saveChannel);
    avoidCtrl.removeListener(_saveChannel);
    durationCtrl.removeListener(_saveChannel);
    defaultDescriptionCtrl.removeListener(_saveDefaultsText);
    defaultNotesCtrl.removeListener(_saveDefaultsText);
    deepseekUrlCtrl.removeListener(_saveExternal);
    deepseekKeyCtrl.removeListener(_saveExternal);
    hiveUrlCtrl.removeListener(_saveExternal);
    hiveKeyCtrl.removeListener(_saveExternal);
    openaiUrlCtrl.removeListener(_saveExternal);
    openaiKeyCtrl.removeListener(_saveExternal);
    claudeUrlCtrl.removeListener(_saveExternal);
    claudeKeyCtrl.removeListener(_saveExternal);
    urlCtrl.dispose();
    deepseekUrlCtrl.dispose();
    deepseekKeyCtrl.dispose();
    hiveUrlCtrl.dispose();
    hiveKeyCtrl.dispose();
    openaiUrlCtrl.dispose();
    openaiKeyCtrl.dispose();
    claudeUrlCtrl.dispose();
    claudeKeyCtrl.dispose();
    customModelCtrl.dispose();
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
