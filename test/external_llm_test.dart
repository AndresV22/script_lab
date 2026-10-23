import 'package:flutter_test/flutter_test.dart';
import 'package:script_lab/core/constants/ai_options.dart';
import 'package:script_lab/core/constants/llm_provider.dart';
import 'package:script_lab/core/helpers/external_thinking.dart';
import 'package:script_lab/core/helpers/llm_web_proxy.dart';
import 'package:script_lab/core/models/external_llm_endpoint.dart';
import 'package:script_lab/core/models/llm_exception.dart';
import 'package:script_lab/core/models/openai_sse_event.dart';

void main() {
  group('ExternalLlmEndpoint', () {
    test('DeepSeek v1 usa /v1/chat/completions', () {
      final endpoint = ExternalLlmEndpoint(
        baseUrl: LlmProvider.deepseekV1Url,
        apiVersion: LlmProvider.v1,
        provider: LlmProvider.deepseek,
      );
      expect(
        endpoint.chatCompletions.toString(),
        'https://api.deepseek.com/v1/chat/completions',
      );
      expect(
        endpoint.models.toString(),
        'https://api.deepseek.com/v1/models',
      );
    });

    test('DeepSeek sin segmento de versión mantiene la ruta oficial', () {
      final endpoint = ExternalLlmEndpoint(
        baseUrl: 'https://api.deepseek.com/',
        apiVersion: LlmProvider.v1,
        provider: LlmProvider.deepseek,
      );
      expect(
        endpoint.chatCompletions.toString(),
        'https://api.deepseek.com/chat/completions',
      );
    });

    test('The Hive v3 usa /api/v3/chat/completions', () {
      final endpoint = ExternalLlmEndpoint(
        baseUrl: LlmProvider.hiveV3Url,
        apiVersion: LlmProvider.v3,
        provider: LlmProvider.hive,
      );
      expect(
        endpoint.chatCompletions.toString(),
        'https://api-cdn.thehive.ai/api/v3/chat/completions',
      );
    });

    test('un host de The Hive sin versión recibe /api/v3', () {
      final endpoint = ExternalLlmEndpoint(
        baseUrl: 'https://api.thehive.ai',
        apiVersion: LlmProvider.v3,
        provider: LlmProvider.hive,
      );
      expect(
        endpoint.models.toString(),
        'https://api.thehive.ai/api/v3/models',
      );
    });

    test('una URL vacía usa el preset del proveedor', () {
      final endpoint = ExternalLlmEndpoint(
        baseUrl: '  ',
        apiVersion: LlmProvider.v3,
        provider: LlmProvider.hive,
      );
      expect(endpoint.apiRoot, LlmProvider.hiveV3Url);
    });
  });

  group('LlmProvider', () {
    test('cambiar de v3 a v1 conserva el host de The Hive', () {
      expect(
        LlmProvider.replaceApiVersion(
          'https://api-va1.thehive.ai/api/v3',
          LlmProvider.hive,
          LlmProvider.v1,
        ),
        'https://api-va1.thehive.ai/api/v1',
      );
    });
  });

  group('LlmWebProxy', () {
    test('en web reescribe los hosts conocidos', () {
      final uri = LlmWebProxy.rewrite(
        Uri.parse('https://api-cdn.thehive.ai/api/v3/chat/completions'),
        useProxy: true,
      );
      expect(
        uri.toString(),
        '/llm-proxy/hive-cdn/api/v3/chat/completions',
      );
    });

    test('fuera de la web deja la URL original', () {
      final original = Uri.parse('https://api.deepseek.com/v1/models');
      expect(
        LlmWebProxy.rewrite(original, useProxy: false),
        original,
      );
    });
  });

  group('ExternalThinking', () {
    test('DeepSeek desactiva el razonamiento cuando no se pide', () {
      expect(
        ExternalThinking.parameters(
          provider: LlmProvider.deepseek,
          thinking: false,
          mode: AiThinkMode.high,
        ),
        {
          'thinking': {'type': 'disabled'},
          'reasoning_effort': 'none',
        },
      );
    });

    test('The Hive envía high cuando el modo está activado', () {
      expect(
        ExternalThinking.parameters(
          provider: LlmProvider.hive,
          thinking: true,
          mode: AiThinkMode.on,
        ),
        {'reasoning_effort': 'high'},
      );
    });
  });

  group('OpenAiSseEvent', () {
    test('separa razonamiento y contenido', () {
      final event = OpenAiSseEvent.parse(
        'data: {"choices":[{"delta":{"reasoning_content":"pienso","content":"hola"}}]}',
      );
      expect(event?.reasoning, 'pienso');
      expect(event?.content, 'hola');
    });

    test('reconoce el fin del stream', () {
      expect(OpenAiSseEvent.parse('data: [DONE]')?.done, isTrue);
    });

    test('propaga el error del proveedor', () {
      expect(
        () => OpenAiSseEvent.parse(
          'data: {"error":{"message":"clave inválida"}}',
        ),
        throwsA(
          isA<LlmException>().having(
            (error) => error.message,
            'message',
            'clave inválida',
          ),
        ),
      );
    });
  });
}
