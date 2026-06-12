import 'dart:convert';

import '../../ai/services/ai_service.dart';
import '../models/structure.dart';

class StructureGeneration {
  final String name;
  final List<StructureStep> steps;

  const StructureGeneration({required this.name, required this.steps});
}

/// Prompts y parseo para generar estructuras con IA.
abstract class StructureAiService {
  static String generatePrompt({
    required String description,
    required String sectionsHint,
  }) {
    final buffer = StringBuffer()
      ..writeln('Diseña una plantilla de estructura de guion para YouTube.')
      ..writeln()
      ..writeln('Descripción de la estructura que busca el creador:')
      ..writeln(description.trim());

    if (sectionsHint.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Secciones o pasos que el creador quiere incluir (respétalos '
            'y complétalos si hace falta):')
        ..writeln(sectionsHint.trim());
    }

    buffer
      ..writeln()
      ..writeln('Genera un nombre corto para la plantilla y entre 4 y 12 '
          'secciones ordenadas.')
      ..writeln('Para cada sección incluye:')
      ..writeln('- "name": título breve de la sección (sin numeración).')
      ..writeln('- "description": 1 o 2 frases con indicaciones para la IA '
          'sobre qué debe cubrir esa sección al escribir el guion.')
      ..writeln()
      ..writeln('Devuelve ÚNICAMENTE un objeto JSON válido con este formato:')
      ..writeln('{')
      ..writeln('  "name": "Nombre de la estructura",')
      ..writeln('  "steps": [')
      ..writeln('    {"name": "Hook", "description": "..."},')
      ..writeln('    {"name": "Desarrollo", "description": "..."}')
      ..writeln('  ]')
      ..writeln('}')
      ..writeln('Sin comentarios, markdown ni texto fuera del JSON.');

    return buffer.toString();
  }

  static StructureGeneration? parseStructure(String raw) {
    final candidates = <String>[
      AiService.cleanOutput(raw),
      raw.trim(),
    ];

    final objectMatch = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
    if (objectMatch != null) {
      candidates.add(objectMatch.group(0)!);
    }

    for (final candidate in candidates) {
      final parsed = _tryParseJson(candidate);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static StructureGeneration? _tryParseJson(String text) {
    try {
      final data = jsonDecode(text) as Map<String, dynamic>;
      final name = (data['name'] as String?)?.trim() ?? '';
      final stepsRaw = data['steps'];
      if (name.isEmpty || stepsRaw is! List || stepsRaw.isEmpty) return null;

      final steps = <StructureStep>[];
      for (final item in stepsRaw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final stepName = (map['name'] as String?)?.trim() ?? '';
        if (stepName.isEmpty) continue;
        steps.add(StructureStep(
          name: stepName,
          description: (map['description'] as String?)?.trim() ?? '',
        ));
      }

      if (steps.isEmpty) return null;
      return StructureGeneration(name: name, steps: steps);
    } catch (_) {
      return null;
    }
  }
}
