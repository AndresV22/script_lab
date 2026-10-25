/// Proveedores de modelo y URLs base documentadas.
abstract class LlmProvider {
  static const ollama = 'ollama';
  static const deepseek = 'deepseek';
  static const hive = 'hive';
  static const openai = 'openai';
  static const claude = 'claude';

  static const values = [ollama, deepseek, hive, openai, claude];

  static const v1 = 'v1';
  static const v3 = 'v3';
  static const apiVersions = [v1, v3];

  static const deepseekV1Url = 'https://api.deepseek.com/v1';
  static const deepseekV3Url = 'https://api.deepseek.com/v3';
  static const hiveV1Url = 'https://api-cdn.thehive.ai/api/v1';
  static const hiveV3Url = 'https://api-cdn.thehive.ai/api/v3';
  static const openaiV1Url = 'https://api.openai.com/v1';
  static const openaiV3Url = 'https://api.openai.com/v3';
  static const claudeV1Url = 'https://api.anthropic.com/v1';
  static const claudeV3Url = 'https://api.anthropic.com/v3';

  /// Cabecera que pide la lista de modelos de Claude.
  static const claudeVersionHeader = '2026-10-21';

  static const deepseekModels = ['deepseek-flash', 'deepseek-v4-pro'];
  static const hiveModels = [
    'deepseek-ai/deepseek-v4.1-flash-1017',
    'zai-org/glm-5.3-flash',
  ];
  static const openaiModels = ['gpt-5.6-sol', 'gpt-6-astra'];
  static const claudeModels = [
    'claude-sonnet-5-5',
    'claude-opus-5-5',
    'claude-haiku-5-5',
  ];

  static const presets = [
    deepseekV1Url,
    deepseekV3Url,
    'https://api.deepseek.com',
    hiveV1Url,
    hiveV3Url,
    'https://api.thehive.ai/api/v1',
    'https://api.thehive.ai/api/v3',
    'https://api-va1.thehive.ai/api/v1',
    'https://api-va1.thehive.ai/api/v3',
    openaiV1Url,
    openaiV3Url,
    claudeV1Url,
    claudeV3Url,
  ];

  static String label(String provider) => switch (provider) {
        deepseek => 'DeepSeek',
        hive => 'The Hive',
        openai => 'OpenAI',
        claude => 'Claude',
        _ => 'Ollama',
      };

  static String presetBaseUrl(String provider, String version) =>
      switch (provider) {
        hive => version == v1 ? hiveV1Url : hiveV3Url,
        openai => version == v3 ? openaiV3Url : openaiV1Url,
        claude => version == v3 ? claudeV3Url : claudeV1Url,
        _ => version == v3 ? deepseekV3Url : deepseekV1Url,
      };

  static List<String> fallbackModels(String provider) => switch (provider) {
        hive => hiveModels,
        openai => openaiModels,
        claude => claudeModels,
        _ => deepseekModels,
      };

  static String modelHint(String provider) => switch (provider) {
        hive => 'Ej. zai-org/glm-5.3-flash',
        openai => 'Ej. gpt-5.6-sol',
        claude => 'Ej. claude-sonnet-5-5',
        _ => 'Ej. deepseek-flash',
      };

  static bool isPreset(String url) {
    final normalized = _stripSlash(url.trim());
    return presets.contains(normalized);
  }

  /// Cambia el sufijo v1/v3 si la URL ya lo trae. Si no, la deja igual.
  static String replaceApiVersion(String url, String provider, String version) {
    final normalized = _stripSlash(url.trim());
    if (normalized.isEmpty) return presetBaseUrl(provider, version);
    final replaced = normalized.replaceFirst(RegExp(r'/(api/)?v[13]$'), '');
    if (replaced == normalized) return normalized;
    if (replaced.contains('thehive.ai')) return '$replaced/api/$version';
    return '$replaced/$version';
  }

  static String helper(String provider) => switch (provider) {
        hive =>
          'The Hive documenta el chat en v3: https://api-cdn.thehive.ai/api/v3. '
              'Cuentas Virginia (VA1): https://api-va1.thehive.ai/api/v3.',
        openai =>
          'OpenAI documenta el chat en v1: https://api.openai.com/v1.',
        claude =>
          'Claude documenta el chat compatible con OpenAI en v1: '
              'https://api.anthropic.com/v1.',
        _ =>
          'DeepSeek usa una API compatible con OpenAI. '
              'La URL base v1 recomendada es https://api.deepseek.com/v1.',
      };

  static String unavailableTitle(String provider) =>
      '${label(provider)} no disponible';

  static String unavailableMessage(String provider) {
    if (provider == ollama) {
      return 'No hay conexión con Ollama o no hay modelos instalados. '
          'Verifica que Ollama esté en ejecución y configura la URL y el modelo en Ajustes.';
    }
    return 'No hay conexión con ${label(provider)} o no hay modelos disponibles. '
        'Revisa la clave de API, la URL base y la versión (v1 o v3) en Ajustes.';
  }

  static String _stripSlash(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;
}
