import '../constants/ai_options.dart';
import '../constants/llm_provider.dart';

/// Parámetros de razonamiento para APIs compatibles con OpenAI.
class ExternalThinking {
  static Map<String, dynamic> parameters({
    required String provider,
    required bool thinking,
    required String mode,
  }) {
    final enabled = thinking && mode != AiThinkMode.off;
    final effort = enabled ? _effort(mode) : 'none';
    if (provider == LlmProvider.hive) {
      return {'reasoning_effort': effort};
    }
    return {
      'thinking': {'type': enabled ? 'enabled' : 'disabled'},
      'reasoning_effort': effort,
    };
  }

  static String _effort(String mode) => switch (mode) {
        AiThinkMode.low => 'low',
        AiThinkMode.medium || AiThinkMode.high || AiThinkMode.on => 'high',
        _ => 'none',
      };
}
