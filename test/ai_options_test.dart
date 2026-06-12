import 'package:flutter_test/flutter_test.dart';
import 'package:script_lab/core/constants/ai_options.dart';

void main() {
  group('AiThinkMode', () {
    test('ollamaValue mapea modos compatibles con la API', () {
      expect(AiThinkMode.ollamaValue(AiThinkMode.off), isNull);
      expect(AiThinkMode.ollamaValue(AiThinkMode.on), true);
      expect(AiThinkMode.ollamaValue(AiThinkMode.low), 'low');
      expect(AiThinkMode.ollamaValue(AiThinkMode.medium), 'medium');
      expect(AiThinkMode.ollamaValue(AiThinkMode.high), 'high');
    });
  });
}
