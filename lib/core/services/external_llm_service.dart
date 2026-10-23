import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../ui/features/settings/models/app_settings.dart';
import '../constants/llm_provider.dart';
import '../helpers/external_thinking.dart';
import '../helpers/llm_web_proxy.dart';
import '../models/external_llm_endpoint.dart';
import '../models/llm_exception.dart';
import '../models/llm_status.dart';
import '../models/ollama_chat_chunk.dart';
import '../models/openai_sse_event.dart';
import 'http/create_client_io.dart'
    if (dart.library.js_interop) 'http/create_client_web.dart';
import 'settings_service.dart';

/// Cliente de chat compatible con OpenAI para DeepSeek y The Hive.
class ExternalLlmService {
  final status = OllamaStatus.unknown.obs;
  final models = <String>[].obs;
  final lastError = ''.obs;
  final usedCatalog = false.obs;

  Future<bool> checkConnection() async {
    status.value = OllamaStatus.checking;
    lastError.value = '';
    usedCatalog.value = false;
    final settings = SettingsService.to.settings.value;
    final provider = settings.llmProvider;
    final apiKey = _apiKey(settings);
    if (apiKey.isEmpty) {
      models.clear();
      status.value = OllamaStatus.disconnected;
      lastError.value = 'Añade una clave de API para ${LlmProvider.label(provider)}.';
      return false;
    }

    final endpoint = _endpoint(settings);
    final client = createHttpClient();
    try {
      final response = await client
          .get(
            _requestUri(endpoint.models),
            headers: _headers(apiKey, stream: false),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 404 || response.statusCode == 405) {
        _assignModels(LlmProvider.fallbackModels(provider), settings.defaultModel);
        usedCatalog.value = true;
        status.value = OllamaStatus.connected;
        return true;
      }
      if (response.statusCode != 200) {
        throw LlmException(_httpError(response.statusCode, response.body));
      }
      final ids = _parseModelIds(response.body);
      if (ids.isEmpty) {
        _assignModels(LlmProvider.fallbackModels(provider), settings.defaultModel);
        usedCatalog.value = true;
      } else {
        _assignModels(ids, settings.defaultModel);
      }
      status.value = OllamaStatus.connected;
      return true;
    } catch (e) {
      models.clear();
      status.value = OllamaStatus.disconnected;
      lastError.value = _friendly(e);
      return false;
    } finally {
      client.close();
    }
  }

  Stream<String> chat({
    required String model,
    required String system,
    required String prompt,
    bool thinking = false,
  }) =>
      chatWithHistory(
        model: model,
        system: system,
        messages: [
          {'role': 'user', 'content': prompt},
        ],
        thinking: thinking,
      );

  Stream<String> chatWithHistory({
    required String model,
    required String system,
    required List<Map<String, String>> messages,
    bool thinking = false,
  }) =>
      chatWithHistoryChunks(
        model: model,
        system: system,
        messages: messages,
        thinking: thinking,
      ).where((chunk) => chunk.hasContent).map((chunk) => chunk.content!);

  Stream<OllamaChatChunk> chatWithHistoryChunks({
    required String model,
    required String system,
    required List<Map<String, String>> messages,
    bool thinking = false,
  }) async* {
    if (model.isEmpty) {
      throw LlmException(
          'No hay un modelo seleccionado. Configúralo en Ajustes.');
    }
    final settings = SettingsService.to.settings.value;
    final apiKey = _apiKey(settings);
    if (apiKey.isEmpty) {
      throw LlmException(
          'Añade una clave de API para ${LlmProvider.label(settings.llmProvider)}.');
    }
    final endpoint = _endpoint(settings);
    final body = <String, dynamic>{
      'model': model,
      'stream': true,
      'messages': [
        if (system.isNotEmpty) {'role': 'system', 'content': system},
        ...messages,
      ],
    };
    body.addAll(ExternalThinking.parameters(
      provider: settings.llmProvider,
      thinking: thinking,
      mode: settings.thinkMode,
    ));

    final client = createHttpClient();
    try {
      final request = http.Request('POST', _requestUri(endpoint.chatCompletions))
        ..headers.addAll(_headers(apiKey, stream: true))
        ..body = jsonEncode(body);
      final response = await client.send(request);
      if (response.statusCode != 200) {
        final raw = await response.stream.bytesToString();
        throw LlmException(_httpError(response.statusCode, raw));
      }
      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      await for (final line in lines) {
        final event = OpenAiSseEvent.parse(line);
        if (event == null) continue;
        if (event.done) break;
        if (event.hasReasoning) {
          yield OllamaChatChunk(thinking: event.reasoning);
        }
        if (event.hasContent) {
          yield OllamaChatChunk(content: event.content);
        }
      }
    } finally {
      client.close();
    }
  }

  ExternalLlmEndpoint _endpoint(AppSettings settings) => ExternalLlmEndpoint(
        baseUrl: settings.llmProvider == LlmProvider.hive
            ? settings.hiveBaseUrl
            : settings.deepseekBaseUrl,
        apiVersion: settings.llmProvider == LlmProvider.hive
            ? settings.hiveApiVersion
            : settings.deepseekApiVersion,
        provider: settings.llmProvider,
      );

  String _apiKey(AppSettings settings) {
    final raw = settings.llmProvider == LlmProvider.hive
        ? settings.hiveApiKey
        : settings.deepseekApiKey;
    return raw.trim();
  }

  Uri _requestUri(Uri uri) =>
      LlmWebProxy.rewrite(uri, useProxy: kIsWeb);

  Map<String, String> _headers(String apiKey, {required bool stream}) => {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': stream ? 'text/event-stream' : 'application/json',
      };

  void _assignModels(List<String> ids, String selected) {
    final list = [...ids];
    final current = selected.trim();
    if (current.isNotEmpty && !list.contains(current)) list.add(current);
    models.assignAll(list);
  }

  List<String> _parseModelIds(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) return [];
    final data = decoded['data'] ?? decoded['models'];
    if (data is! List) return [];
    final ids = <String>[];
    for (final item in data) {
      if (item is! Map) continue;
      final id = item['id'] ?? item['name'];
      if (id is String && id.isNotEmpty) ids.add(id);
    }
    return ids;
  }

  String _httpError(int code, String body) {
    if (code == 401) return 'La clave de API fue rechazada.';
    if (code == 403) return 'La clave no tiene permiso para usar esta API.';
    final message = _bodyMessage(body);
    if (message != null) return 'Error HTTP $code: $message';
    return 'Respuesta inesperada: HTTP $code';
  }

  String? _bodyMessage(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        final error = decoded['error'];
        if (error is Map && error['message'] is String) {
          return _short(error['message'] as String);
        }
        if (error is String) return _short(error);
        if (decoded['message'] is String) {
          return _short(decoded['message'] as String);
        }
      }
    } catch (_) {
      return _short(trimmed);
    }
    return _short(trimmed);
  }

  String _short(String value) {
    final clean = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= 180) return clean;
    return '${clean.substring(0, 180)}…';
  }

  String _friendly(Object error) {
    if (error is LlmException) return error.message;
    if (error is TimeoutException) return 'La conexión tardó demasiado.';
    final raw = error.toString();
    if (raw.contains('Failed to fetch') ||
        raw.contains('XMLHttpRequest') ||
        raw.contains('ClientException')) {
      return 'No se pudo contactar el servidor. Revisa la URL base. '
          'En el navegador, DeepSeek y The Hive pasan por el servidor de la app; '
          'otro dominio puede quedar bloqueado.';
    }
    return raw;
  }
}
