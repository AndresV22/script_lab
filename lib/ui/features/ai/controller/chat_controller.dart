import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/ai_options.dart';
import '../../../../core/models/ollama_chat_chunk.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/ollama_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../projects/controller/project_detail_controller.dart';
import '../../projects/models/project.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../views/widgets/model_picker_dialog.dart';

/// Chat persistente con la IA en el contexto de un proyecto.
class ChatController extends GetxController {
  final detail = Get.find<ProjectDetailController>();

  final messages = <ChatMessage>[].obs;
  final streamingText = ''.obs;
  final streamingThinking = ''.obs;
  final isStreaming = false.obs;
  final selectedModel = ''.obs;

  final inputCtrl = TextEditingController();
  final scrollController = ScrollController();

  StreamSubscription<OllamaChatChunk>? _subscription;

  String? _thinkModeBeforeDisable;

  Project get project => detail.project;

  bool get thinkEnabled =>
      AiThinkMode.ollamaValue(SettingsService.to.settings.value.thinkMode) !=
      null;

  Future<void> toggleThinking() async {
    final settings = SettingsService.to.settings.value;
    if (thinkEnabled) {
      _thinkModeBeforeDisable = settings.thinkMode;
      settings.thinkMode = AiThinkMode.off;
    } else {
      settings.thinkMode = _thinkModeBeforeDisable ?? AiThinkMode.on;
      _thinkModeBeforeDisable = null;
    }
    await SettingsService.to.saveSettings();
  }

  @override
  void onInit() {
    super.onInit();
    selectedModel.value = SettingsService.to.settings.value.defaultModel;
    messages.assignAll(project.chatMessages);
  }

  void send() {
    final content = inputCtrl.text.trim();
    if (content.isEmpty || isStreaming.value) return;

    if (selectedModel.value.isEmpty) {
      _requestModel(onReady: () => _send(content));
      return;
    }
    _send(content);
  }

  void _send(String content) {
    inputCtrl.clear();
    final message = ChatMessage(role: 'user', content: content);
    project.chatMessages.add(message);
    messages.add(message);
    detail.markDirty();
    _scrollToBottom();

    isStreaming.value = true;
    streamingText.value = '';
    streamingThinking.value = '';
    final history = [
      for (final m in project.chatMessages)
        {'role': m.role, 'content': m.content},
    ];
    _subscription = OllamaService.to
        .chatWithHistoryChunks(
          model: selectedModel.value,
          system: AiService.chatSystemPrompt(project),
          messages: history,
          thinking: true,
        )
        .listen(
          (chunk) {
            if (chunk.hasThinking) {
              streamingThinking.value += chunk.thinking!;
            }
            if (chunk.hasContent) {
              streamingText.value += chunk.content!;
            }
            _scrollToBottom();
          },
          onError: (Object e) {
            _finish();
            Get.snackbar('Chat', 'Error: $e',
                snackPosition: SnackPosition.BOTTOM, maxWidth: 420);
          },
          onDone: _finish,
        );
  }

  /// Cierra el streaming y persiste lo recibido (también respuestas parciales).
  void _finish() {
    _subscription?.cancel();
    _subscription = null;
    final text = streamingText.value.trim();
    final thinking = streamingThinking.value.trim();
    if (text.isNotEmpty || thinking.isNotEmpty) {
      final message = ChatMessage(
        role: 'assistant',
        content: text,
        thinking: thinking,
      );
      project.chatMessages.add(message);
      messages.add(message);
      detail.markDirty();
    }
    streamingText.value = '';
    streamingThinking.value = '';
    isStreaming.value = false;
    _scrollToBottom();
  }

  void stop() {
    if (isStreaming.value) _finish();
  }

  Future<void> clearConversation() async {
    final ok = await showConfirmDialog(
      title: 'Limpiar conversación',
      message:
          'Se eliminarán todos los mensajes del chat de este proyecto. Esta acción no se puede deshacer.',
    );
    if (!ok) return;
    stop();
    project.chatMessages.clear();
    messages.clear();
    detail.markDirty();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

  /// Mismo flujo de "sin modelo" que el asistente de IA.
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
          child: Text('No hay conexión con Ollama o no hay modelos instalados. '
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
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    inputCtrl.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
