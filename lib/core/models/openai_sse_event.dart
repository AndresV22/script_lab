import 'dart:convert';

import 'llm_exception.dart';

/// Un evento SSE de chat completions (`data: {...}` o `data: [DONE]`).
class OpenAiSseEvent {
  final String? content;
  final String? reasoning;
  final bool done;

  const OpenAiSseEvent({
    this.content,
    this.reasoning,
    this.done = false,
  });

  bool get hasContent => content != null && content!.isNotEmpty;
  bool get hasReasoning => reasoning != null && reasoning!.isNotEmpty;

  /// Devuelve null si la línea no trae un delta útil.
  static OpenAiSseEvent? parse(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith(':')) return null;
    if (!trimmed.startsWith('data:')) return null;
    final payload = trimmed.substring(5).trim();
    if (payload.isEmpty) return null;
    if (payload == '[DONE]') return const OpenAiSseEvent(done: true);

    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } catch (_) {
      throw LlmException('Respuesta de streaming no reconocida.');
    }
    if (decoded is! Map) {
      throw LlmException('Respuesta de streaming no reconocida.');
    }
    final data = Map<String, dynamic>.from(decoded);
    final error = _errorMessage(data);
    if (error != null) throw LlmException(error);

    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final choice = choices.first;
    if (choice is! Map) return null;
    final delta = choice['delta'];
    final message = choice['message'];
    final source = delta is Map
        ? delta
        : message is Map
            ? message
            : null;
    if (source == null) return null;
    return OpenAiSseEvent(
      content: _text(source['content']),
      reasoning: _text(source['reasoning_content']) ?? _text(source['reasoning']),
    );
  }

  static String? _text(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return value;
  }

  static String? _errorMessage(Map<String, dynamic> data) {
    final error = data['error'];
    if (error is String && error.isNotEmpty) return error;
    if (error is Map) {
      final message = error['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return null;
  }
}
