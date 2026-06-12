/// Modos de razonamiento (thinking) para la API de Ollama.
abstract class AiThinkMode {
  static const off = 'off';
  static const on = 'on';
  static const low = 'low';
  static const medium = 'medium';
  static const high = 'high';

  static const values = [off, on, low, medium, high];

  static String label(String mode) => switch (mode) {
        off => 'Desactivado',
        on => 'Activado',
        low => 'Intensidad baja',
        medium => 'Intensidad media',
        high => 'Intensidad alta',
        _ => 'Desactivado',
      };

  static String description(String mode) => switch (mode) {
        off => 'Sin razonamiento previo.',
        on => 'Para modelos como qwen3 o deepseek-r1.',
        low => 'Para gpt-oss y modelos cloud con niveles.',
        medium => 'Razonamiento medio (gpt-oss).',
        high => 'Razonamiento profundo (gpt-oss).',
        _ => '',
      };

  /// Valor para el campo `think` de Ollama, o null si está desactivado.
  static Object? ollamaValue(String mode) => switch (mode) {
        on => true,
        low || medium || high => mode,
        _ => null,
      };
}
