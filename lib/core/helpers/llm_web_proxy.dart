/// Reescribe hosts conocidos hacia el proxy del servidor web.
///
/// El navegador no puede llamar a DeepSeek ni a The Hive por CORS.
/// Nginx reenvía estas rutas al proveedor.
class LlmWebProxy {
  static String? prefixForHost(String host) => switch (host) {
        'api.deepseek.com' => '/llm-proxy/deepseek',
        'api.thehive.ai' => '/llm-proxy/hive',
        'api-cdn.thehive.ai' => '/llm-proxy/hive-cdn',
        'api-va1.thehive.ai' => '/llm-proxy/hive-va1',
        _ => null,
      };

  static Uri rewrite(Uri uri, {required bool useProxy}) {
    if (!useProxy) return uri;
    final prefix = prefixForHost(uri.host);
    if (prefix == null) return uri;
    final path = uri.path.startsWith('/') ? uri.path : '/${uri.path}';
    final query = uri.hasQuery ? '?${uri.query}' : '';
    return Uri.parse('$prefix$path$query');
  }
}
