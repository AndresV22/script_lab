class LlmException implements Exception {
  final String message;

  LlmException(this.message);

  @override
  String toString() => message;
}
