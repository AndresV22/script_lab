import 'dart:convert';

import 'package:get/get.dart';

import '../../ai/services/ai_service.dart';
import '../../projects/models/project.dart';
import '../../prompts/models/prompt_item.dart';
import '../../structures/models/structure.dart';
import '../enums/suggestion_type.dart';
import '../models/ai_suggestion.dart';

/// Prompts y parseo para sugerencias de proyectos, estructuras y prompts.
abstract class SuggestionsAiService {
  static const batchSize = 5;
  static const mixedBatchSize = 3;

  static String generatePrompt({
    required SuggestionType type,
    required List<Project> projectsWithScript,
    required List<Structure> structures,
    required List<PromptItem> prompts,
    required List<String> avoidLabels,
    required int count,
  }) {
    final buffer = StringBuffer()
      ..writeln(_typeIntro(type, count))
      ..writeln()
      ..writeln('Contexto del creador:');

    if (projectsWithScript.isEmpty) {
      buffer.writeln('- Sin guiones escritos todavía.');
    } else {
      buffer.writeln('Proyectos con guion escrito:');
      for (final project in projectsWithScript.take(10)) {
        buffer
          ..writeln('- Tema: ${project.topic}')
          ..writeln('  Título: ${project.tentativeTitle}')
          ..writeln('  Etiquetas: ${project.tags.join(', ')}')
          ..writeln('  Extracto: ${_excerpt(project.fullScriptText)}');
      }
    }

    if (structures.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Estructuras existentes (referencia):');
      for (final s in structures.take(8)) {
        buffer.writeln('- "${s.name}" (${s.steps.length} secciones)');
      }
    }

    if (prompts.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Prompts existentes (referencia):');
      for (final p in prompts.take(8)) {
        buffer.writeln('- "${p.name}"${p.category.isNotEmpty ? ' (${p.category})' : ''}');
      }
    }

    if (type == SuggestionType.project && structures.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Estructuras disponibles (usa SOLO un structureId de esta lista):');
      for (final structure in structures) {
        buffer.writeln(
            '- structureId: "${structure.id}", nombre: "${structure.name}"');
      }
    }

    if (avoidLabels.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('NO repitas ni parafrasees estas ideas ya sugeridas:');
      for (final label in avoidLabels) {
        buffer.writeln('- $label');
      }
    }

    buffer
      ..writeln()
      ..writeln(_typeSchema(type, count));

    return buffer.toString();
  }

  static String _typeIntro(SuggestionType type, int count) => switch (type) {
        SuggestionType.project =>
          'Genera exactamente $count ideas nuevas de videos para YouTube '
              'basándote en el estilo y temática del creador.',
        SuggestionType.structure =>
          'Genera exactamente $count plantillas nuevas de estructura de guion '
              'para YouTube, distintas a las existentes.',
        SuggestionType.prompt =>
          'Genera exactamente $count prompts reutilizables para el asistente IA '
              'del creador de contenido.',
      };

  static String _typeSchema(SuggestionType type, int count) => switch (type) {
        SuggestionType.project => '''
Para cada idea incluye metadatos completos del proyecto (sin guion):
- topic, tentativeTitle, altTitles (3-5), description (2-3 párrafos),
  tags (8-12), notes (Markdown breve), structureId (de la lista o vacío)

Devuelve ÚNICAMENTE JSON:
{
  "suggestions": [
    {
      "topic": "...",
      "tentativeTitle": "...",
      "altTitles": ["..."],
      "description": "...",
      "tags": ["..."],
      "notes": "...",
      "structureId": "..."
    }
  ]
}
Debe haber al menos $count elementos. Sin comentarios fuera del JSON.''',
        SuggestionType.structure => '''
Para cada plantilla incluye:
- name: nombre corto de la estructura
- steps: lista de 4-10 secciones con "name" y "description" (indicaciones para la IA)

Devuelve ÚNICAMENTE JSON:
{
  "suggestions": [
    {
      "name": "...",
      "steps": [
        {"name": "Hook", "description": "..."}
      ]
    }
  ]
}
Debe haber al menos $count elementos. Sin comentarios fuera del JSON.''',
        SuggestionType.prompt => '''
Para cada prompt incluye:
- name: nombre corto identificativo
- content: instrucción completa para la IA (en español)
- category: categoría breve (ej. "Corrección", "Metadatos", "Ideas")

Devuelve ÚNICAMENTE JSON:
{
  "suggestions": [
    {
      "name": "...",
      "content": "...",
      "category": "..."
    }
  ]
}
Debe haber al menos $count elementos. Sin comentarios fuera del JSON.''',
      };

  static String _excerpt(String text, {int max = 350}) {
    final trimmed = text.trim();
    if (trimmed.length <= max) return trimmed;
    return '${trimmed.substring(0, max)}…';
  }

  static List<AiSuggestion> parseSuggestions(
    String raw,
    SuggestionType type, {
    List<Structure> structures = const [],
  }) {
    final candidates = <String>[
      AiService.cleanOutput(raw),
      raw.trim(),
    ];
    final objectMatch = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
    if (objectMatch != null) candidates.add(objectMatch.group(0)!);

    for (final candidate in candidates) {
      final parsed = _tryParse(candidate, type, structures: structures);
      if (parsed.isNotEmpty) return parsed;
    }
    return [];
  }

  static List<AiSuggestion> _tryParse(
    String text,
    SuggestionType type, {
    required List<Structure> structures,
  }) {
    try {
      final data = jsonDecode(text);
      final List<dynamic> items;
      if (data is List) {
        items = data;
      } else if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final rawItems =
            map['suggestions'] ?? map['ideas'] ?? map['prompts'] ?? map['structures'];
        if (rawItems is! List) return [];
        items = rawItems;
      } else {
        return [];
      }

      return switch (type) {
        SuggestionType.project =>
          _parseProjects(items, structures: structures),
        SuggestionType.structure => _parseStructures(items),
        SuggestionType.prompt => _parsePrompts(items),
      };
    } catch (_) {
      return [];
    }
  }

  static List<AiSuggestion> _parseProjects(
    List<dynamic> items, {
    required List<Structure> structures,
  }) {
    final results = <AiSuggestion>[];
    for (final item in items) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final topic = (map['topic'] as String?)?.trim() ?? '';
      if (topic.isEmpty) continue;

      results.add(AiSuggestion(
        id: '',
        type: SuggestionType.project,
        topic: topic,
        tentativeTitle: (map['tentativeTitle'] as String?)?.trim() ?? '',
        altTitles: _stringList(map['altTitles']),
        description: (map['description'] as String?)?.trim() ?? '',
        tags: _stringList(map['tags']),
        notes: (map['notes'] as String?)?.trim() ?? '',
        structureId: _resolveStructureId(
          (map['structureId'] as String?)?.trim() ?? '',
          (map['structureName'] as String?)?.trim(),
          structures,
        ),
      ));
    }
    return results;
  }

  static List<AiSuggestion> _parseStructures(List<dynamic> items) {
    final results = <AiSuggestion>[];
    for (final item in items) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final name = (map['name'] as String?)?.trim() ?? '';
      final stepsRaw = map['steps'];
      if (name.isEmpty || stepsRaw is! List || stepsRaw.isEmpty) continue;

      final steps = <StructureStep>[];
      for (final step in stepsRaw) {
        if (step is! Map) continue;
        final stepMap = Map<String, dynamic>.from(step);
        final stepName = (stepMap['name'] as String?)?.trim() ?? '';
        if (stepName.isEmpty) continue;
        steps.add(StructureStep(
          name: stepName,
          description: (stepMap['description'] as String?)?.trim() ?? '',
        ));
      }
      if (steps.isEmpty) continue;

      results.add(AiSuggestion(
        id: '',
        type: SuggestionType.structure,
        structureName: name,
        steps: steps,
      ));
    }
    return results;
  }

  static List<AiSuggestion> _parsePrompts(List<dynamic> items) {
    final results = <AiSuggestion>[];
    for (final item in items) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final name = (map['name'] as String?)?.trim() ?? '';
      final content = (map['content'] as String?)?.trim() ?? '';
      if (name.isEmpty || content.isEmpty) continue;

      results.add(AiSuggestion(
        id: '',
        type: SuggestionType.prompt,
        promptName: name,
        promptContent: content,
        promptCategory: (map['category'] as String?)?.trim() ?? '',
      ));
    }
    return results;
  }

  static String _resolveStructureId(
    String id,
    String? name,
    List<Structure> structures,
  ) {
    if (id.isNotEmpty && structures.any((s) => s.id == id)) return id;
    if (name != null && name.isNotEmpty) {
      final lower = name.toLowerCase();
      final match =
          structures.firstWhereOrNull((s) => s.name.toLowerCase() == lower);
      if (match != null) return match.id;
    }
    return '';
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return [];
    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
