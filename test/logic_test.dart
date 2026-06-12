import 'package:flutter_test/flutter_test.dart';
import 'package:script_lab/core/extensions/string_extensions.dart';
import 'package:script_lab/core/helpers/text_stats.dart';
import 'package:script_lab/ui/features/ai/controller/diff_controller.dart';
import 'package:script_lab/ui/features/ai/services/ai_service.dart';
import 'package:script_lab/ui/features/structures/models/structure.dart';
import 'package:script_lab/ui/features/suggestions/enums/suggestion_type.dart';
import 'package:script_lab/ui/features/suggestions/services/suggestions_ai_service.dart';
import 'package:script_lab/ui/features/structures/services/structure_ai_service.dart';

void main() {
  group('TextStats', () {
    test('cuenta palabras y caracteres', () {
      expect(TextStats.words('Hola mundo, esto es una prueba.'), 6);
      expect(TextStats.words('   '), 0);
      expect(TextStats.chars('abc'), 3);
    });

    test('estima tiempo de narración', () {
      expect(TextStats.narrationTime(140, 140), const Duration(minutes: 1));
      expect(TextStats.narrationTime(0, 140), Duration.zero);
    });

    test('formatea duraciones', () {
      expect(TextStats.formatDuration(const Duration(seconds: 45)), '45 s');
      expect(TextStats.formatDuration(const Duration(minutes: 10)), '10 min');
      expect(
        TextStats.formatDuration(const Duration(minutes: 3, seconds: 20)),
        '3 min 20 s',
      );
    });
  });

  group('StringX.parsedListItems', () {
    test('extrae listas con guiones y números', () {
      const text = '''
Aquí tienes los títulos:
- ¿Cuántos relojes necesitas?
* El error de todos los coleccionistas
1. La verdad sobre tener demasiados relojes
2) Otro título
Texto suelto que no es item
''';
      final items = text.parsedListItems;
      expect(items, hasLength(4));
      expect(items.first, '¿Cuántos relojes necesitas?');
      expect(items.last, 'Otro título');
    });
  });

  group('AiService', () {
    test('cleanOutput quita fences y razonamiento', () {
      expect(AiService.cleanOutput('```md\nhola\n```'), 'hola');
      expect(
        AiService.cleanOutput('<think>pensando...</think>respuesta'),
        'respuesta',
      );
    });

    test('parseTags extrae etiquetas', () {
      expect(
        AiService.parseTags('- relojes\n- coleccion\n- review'),
        ['relojes', 'coleccion', 'review'],
      );
      expect(
        AiService.parseTags('relojes, coleccion, review'),
        ['relojes', 'coleccion', 'review'],
      );
    });

    test('parseSingleTitle obtiene un título', () {
      expect(
        AiService.parseSingleTitle('- El mejor reloj del año'),
        'El mejor reloj del año',
      );
      expect(
        AiService.parseSingleTitle('Título directo'),
        'Título directo',
      );
    });

    test('parseSections divide por encabezados', () {
      const script = '''
## Hook inicial

Esto es el hook.

## Conclusión

Esto es el cierre.
''';
      final parsed = AiService.parseSections(script);
      expect(parsed, hasLength(2));
      expect(parsed[0].$1, 'Hook inicial');
      expect(parsed[0].$2, 'Esto es el hook.');
      expect(parsed[1].$1, 'Conclusión');
    });
  });

  group('DiffController', () {
    test('aceptar todo produce la propuesta', () {
      final controller = DiffController(
        original: 'El reloj es bonito y barato.',
        proposed: 'El reloj es elegante y barato.',
      );
      expect(controller.hasChanges, isTrue);
      controller.acceptAll();
      expect(controller.result, 'El reloj es elegante y barato.');
    });

    test('rechazar todo conserva el original', () {
      final controller = DiffController(
        original: 'El reloj es bonito y barato.',
        proposed: 'El reloj es elegante y barato.',
      );
      controller.rejectAll();
      expect(controller.result, 'El reloj es bonito y barato.');
    });
  });

  group('Structure', () {
    test('serializa y deserializa JSON', () {
      final structure = Structure(
        id: 'a',
        name: 'Review de relojes',
        steps: [
          StructureStep(name: 'Hook inicial'),
          StructureStep(name: 'Historia de la marca'),
        ],
      );
      final restored = Structure.fromJson(structure.toJson(), 'b');
      expect(restored.name, 'Review de relojes');
      expect(restored.steps, hasLength(2));
      expect(restored.steps[1].name, 'Historia de la marca');
    });
  });

  group('StructureAiService', () {
    test('parsea JSON de estructura generada', () {
      const raw = '''
```json
{
  "name": "Review de relojes",
  "steps": [
    {"name": "Hook", "description": "Captar atención en 15 segundos"},
    {"name": "Veredicto", "description": "Conclusión clara"}
  ]
}
```
''';
      final parsed = StructureAiService.parseStructure(raw);
      expect(parsed, isNotNull);
      expect(parsed!.name, 'Review de relojes');
      expect(parsed.steps, hasLength(2));
      expect(parsed.steps.first.description, contains('15 segundos'));
    });
  });

  group('SuggestionsAiService', () {
    test('parsea sugerencias de proyecto', () {
      const raw = '''
{
  "suggestions": [
    {
      "topic": "Relojes submarinos",
      "tentativeTitle": "Los 5 mejores diver watches",
      "altTitles": ["Top diver watches"],
      "description": "Un recorrido por los mejores relojes.",
      "tags": ["relojes", "diver"],
      "notes": "- Comparar precios",
      "structureId": "struct-1"
    }
  ]
}
''';
      final parsed = SuggestionsAiService.parseSuggestions(
        raw,
        SuggestionType.project,
        structures: [
          Structure(id: 'struct-1', name: 'Review'),
        ],
      );
      expect(parsed, hasLength(1));
      expect(parsed.first.topic, 'Relojes submarinos');
      expect(parsed.first.structureId, 'struct-1');
    });

    test('parsea sugerencias de estructura', () {
      const raw = '''
{
  "suggestions": [
    {
      "name": "Review corto",
      "steps": [
        {"name": "Hook", "description": "Captar atención"}
      ]
    }
  ]
}
''';
      final parsed = SuggestionsAiService.parseSuggestions(
        raw,
        SuggestionType.structure,
      );
      expect(parsed, hasLength(1));
      expect(parsed.first.structureName, 'Review corto');
      expect(parsed.first.steps, hasLength(1));
    });
  });
}
