import '../constants/llm_provider.dart';

/// Arma las rutas OpenAI `/chat/completions` y `/models` a partir de la URL base.
class ExternalLlmEndpoint {
  final String baseUrl;
  final String apiVersion;
  final String provider;

  const ExternalLlmEndpoint({
    required this.baseUrl,
    required this.apiVersion,
    required this.provider,
  });

  String get apiRoot {
    final normalized = _normalize(baseUrl);
    final root = normalized.isEmpty
        ? LlmProvider.presetBaseUrl(provider, apiVersion)
        : normalized;
    if (_includesVersion(root)) return root;
    final uri = Uri.parse(root);
    if (uri.host.contains('deepseek.com') && apiVersion == LlmProvider.v1) {
      return root;
    }
    if (uri.host.contains('thehive.ai')) return '$root/api/$apiVersion';
    return '$root/$apiVersion';
  }

  Uri get chatCompletions => Uri.parse('$apiRoot/chat/completions');

  Uri get models => Uri.parse('$apiRoot/models');

  static String _normalize(String raw) {
    var url = raw.trim();
    if (url.isEmpty) return '';
    if (!url.contains('://')) url = 'https://$url';
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  static bool _includesVersion(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    return path.endsWith('/v1') ||
        path.endsWith('/v3') ||
        path.endsWith('/api/v1') ||
        path.endsWith('/api/v3');
  }
}
