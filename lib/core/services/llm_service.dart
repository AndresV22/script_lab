import 'package:get/get.dart';

import '../constants/llm_provider.dart';
import '../models/ollama_chat_chunk.dart';
import 'external_llm_service.dart';
import 'ollama_service.dart';
import 'settings_service.dart';

/// Punto de entrada de la IA: Ollama local o un proveedor externo.
class LlmService extends GetxService {
  static LlmService get to => Get.find();

  final _external = ExternalLlmService();

  bool get usesOllama =>
      SettingsService.to.settings.value.llmProvider == LlmProvider.ollama;

  Rx<OllamaStatus> get status {
    SettingsService.to.settings.value.llmProvider;
    return usesOllama ? OllamaService.to.status : _external.status;
  }

  RxList<String> get models {
    SettingsService.to.settings.value.llmProvider;
    return usesOllama ? OllamaService.to.models : _external.models;
  }

  RxString get lastError {
    SettingsService.to.settings.value.llmProvider;
    return usesOllama ? OllamaService.to.lastError : _external.lastError;
  }

  bool get usedCatalog => !usesOllama && _external.usedCatalog.value;

  @override
  void onInit() {
    super.onInit();
    checkConnection();
  }

  Future<bool> checkConnection() {
    if (usesOllama) return OllamaService.to.checkConnection();
    return _external.checkConnection();
  }

  Future<void> refreshConnection() async {
    await checkConnection();
  }

  Stream<String> chat({
    required String model,
    required String system,
    required String prompt,
    bool thinking = false,
  }) {
    if (usesOllama) {
      return OllamaService.to.chat(
        model: model,
        system: system,
        prompt: prompt,
        thinking: thinking,
      );
    }
    return _external.chat(
      model: model,
      system: system,
      prompt: prompt,
      thinking: thinking,
    );
  }

  Stream<String> chatWithHistory({
    required String model,
    required String system,
    required List<Map<String, String>> messages,
    bool thinking = false,
  }) {
    if (usesOllama) {
      return OllamaService.to.chatWithHistory(
        model: model,
        system: system,
        messages: messages,
        thinking: thinking,
      );
    }
    return _external.chatWithHistory(
      model: model,
      system: system,
      messages: messages,
      thinking: thinking,
    );
  }

  Stream<OllamaChatChunk> chatWithHistoryChunks({
    required String model,
    required String system,
    required List<Map<String, String>> messages,
    bool thinking = false,
  }) {
    if (usesOllama) {
      return OllamaService.to.chatWithHistoryChunks(
        model: model,
        system: system,
        messages: messages,
        thinking: thinking,
      );
    }
    return _external.chatWithHistoryChunks(
      model: model,
      system: system,
      messages: messages,
      thinking: thinking,
    );
  }
}
