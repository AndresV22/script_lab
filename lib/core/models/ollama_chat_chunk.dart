/// Fragmento de una respuesta en streaming de Ollama.
class OllamaChatChunk {
  final String? thinking;
  final String? content;

  const OllamaChatChunk({this.thinking, this.content});

  bool get hasThinking => thinking != null && thinking!.isNotEmpty;
  bool get hasContent => content != null && content!.isNotEmpty;
}
