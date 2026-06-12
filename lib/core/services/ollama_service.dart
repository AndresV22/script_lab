import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'http/create_client_io.dart'
    if (dart.library.js_interop) 'http/create_client_web.dart';
import 'settings_service.dart';

enum OllamaStatus { unknown, checking, connected, disconnected }

class OllamaException implements Exception {
  final String message;
  OllamaException(this.message);

  @override
  String toString() => message;
}

/// Cliente HTTP para un servidor Ollama local.
class OllamaService extends GetxService {
  static OllamaService get to => Get.find();

  final status = OllamaStatus.unknown.obs;
  final models = <String>[].obs;
  final lastError = ''.obs;

  String get baseUrl {
    final url = SettingsService.to.settings.value.ollamaUrl.trim();
    final cleaned = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    return cleaned.isEmpty ? 'http://localhost:11434' : cleaned;
  }

  String get defaultModel => SettingsService.to.settings.value.defaultModel;

  @override
  void onInit() {
    super.onInit();
    checkConnection();
  }

  /// Comprueba la conexión y refresca la lista de modelos disponibles.
  Future<bool> checkConnection() async {
    status.value = OllamaStatus.checking;
    lastError.value = '';
    final client = createHttpClient();
    try {
      final res = await client
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) {
        throw OllamaException('Respuesta inesperada: HTTP ${res.statusCode}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = ((data['models'] as List?) ?? [])
          .map((m) => (m as Map)['name'] as String)
          .toList();
      models.assignAll(list);
      status.value = OllamaStatus.connected;
      return true;
    } catch (e) {
      models.clear();
      status.value = OllamaStatus.disconnected;
      lastError.value = e.toString();
      return false;
    } finally {
      client.close();
    }
  }

  /// Envía un chat de un solo turno a Ollama y emite la respuesta en streaming.
  Stream<String> chat({
    required String model,
    required String system,
    required String prompt,
  }) =>
      chatWithHistory(
        model: model,
        system: system,
        messages: [
          {'role': 'user', 'content': prompt},
        ],
      );

  /// Envía un chat con historial completo a Ollama y emite la respuesta
  /// en streaming. [messages] son mapas {'role', 'content'}.
  Stream<String> chatWithHistory({
    required String model,
    required String system,
    required List<Map<String, String>> messages,
  }) async* {
    if (model.isEmpty) {
      throw OllamaException(
          'No hay un modelo seleccionado. Configúralo en Ajustes.');
    }
    final client = createHttpClient();
    try {
      final request = http.Request('POST', Uri.parse('$baseUrl/api/chat'))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({
          'model': model,
          'stream': true,
          'messages': [
            if (system.isNotEmpty) {'role': 'system', 'content': system},
            ...messages,
          ],
        });
      final response = await client.send(request);
      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        throw OllamaException('Error de Ollama (${response.statusCode}): $body');
      }
      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      await for (final line in lines) {
        if (line.trim().isEmpty) continue;
        final data = jsonDecode(line) as Map<String, dynamic>;
        if (data['error'] != null) {
          throw OllamaException(data['error'].toString());
        }
        final content = (data['message'] as Map?)?['content'] as String?;
        if (content != null && content.isNotEmpty) yield content;
        if (data['done'] == true) break;
      }
    } finally {
      client.close();
    }
  }
}
