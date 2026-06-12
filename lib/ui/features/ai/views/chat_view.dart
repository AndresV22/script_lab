import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/services/ollama_service.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/ollama_model_dropdown.dart';
import '../controller/chat_controller.dart';
import '../models/chat_message.dart';

/// Pestaña de chat persistente con la IA sobre el proyecto.
class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Column(
          children: [
            _ChatToolbar(controller: controller),
            Expanded(child: _MessageList(controller: controller)),
            _Composer(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _ChatToolbar extends StatelessWidget {
  final ChatController controller;

  const _ChatToolbar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 4),
      child: Row(
        children: [
          SizedBox(
            width: 260,
            child: Obx(() => OllamaModelDropdown(
                  value: controller.selectedModel.value,
                  models: OllamaService.to.models,
                  onChanged: (model) =>
                      controller.selectedModel.value = model ?? '',
                  isDense: true,
                )),
          ),
          const Spacer(),
          Obx(() => TextButton.icon(
                onPressed: controller.messages.isEmpty &&
                        !controller.isStreaming.value
                    ? null
                    : controller.clearConversation,
                icon: const Icon(Icons.delete_sweep_outlined, size: 17),
                label: const Text('Limpiar conversación'),
              )),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final ChatController controller;

  const _MessageList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final streaming = controller.streamingText.value;
      final hasStreaming = controller.isStreaming.value;
      if (controller.messages.isEmpty && !hasStreaming) {
        return const EmptyState(
          icon: Icons.chat_bubble_outline,
          title: 'Conversa con tu proyecto',
          subtitle:
              'La IA conoce el tema, el guion, las variables del canal y tu estilo. '
              'Pregunta, pide ideas o discute enfoques: la conversación queda guardada en el proyecto.',
        );
      }
      return ListView(
        controller: controller.scrollController,
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
        children: [
          for (final message in controller.messages)
            _MessageBubble(message: message),
          if (hasStreaming)
            _MessageBubble(
              message: ChatMessage(
                role: 'assistant',
                content: streaming.isEmpty ? '…' : streaming,
              ),
              streaming: true,
            ),
        ],
      );
    });
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool streaming;

  const _MessageBubble({required this.message, this.streaming = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 620),
        decoration: BoxDecoration(
          color: isUser
              ? scheme.primaryContainer.withValues(alpha: 0.55)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              message.content,
              style: const TextStyle(fontSize: 13.5, height: 1.5),
            ),
            if (streaming)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: scheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final ChatController controller;

  const _Composer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.enter):
                    controller.send,
              },
              child: TextField(
                controller: controller.inputCtrl,
                minLines: 1,
                maxLines: 6,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.send(),
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje sobre este proyecto…',
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => controller.isStreaming.value
              ? IconButton.filledTonal(
                  tooltip: 'Detener',
                  onPressed: controller.stop,
                  icon: const Icon(Icons.stop),
                )
              : IconButton.filled(
                  tooltip: 'Enviar',
                  onPressed: controller.send,
                  icon: const Icon(Icons.arrow_upward),
                )),
        ],
      ),
    );
  }
}
