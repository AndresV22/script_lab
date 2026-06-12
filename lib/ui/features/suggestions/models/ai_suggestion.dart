import 'package:hive_ce/hive.dart';

import '../../structures/models/structure.dart';
import '../enums/suggestion_type.dart';

/// Sugerencia generada por IA: proyecto, estructura o prompt pendiente.
class AiSuggestion extends HiveObject {
  String id;
  SuggestionType type;
  DateTime createdAt;

  // Proyecto
  String topic;
  String tentativeTitle;
  List<String> altTitles;
  String description;
  List<String> tags;
  String notes;
  String structureId;

  // Estructura
  String structureName;
  List<StructureStep> steps;

  // Prompt
  String promptName;
  String promptContent;
  String promptCategory;

  AiSuggestion({
    required this.id,
    required this.type,
    DateTime? createdAt,
    this.topic = '',
    this.tentativeTitle = '',
    List<String>? altTitles,
    this.description = '',
    List<String>? tags,
    this.notes = '',
    this.structureId = '',
    this.structureName = '',
    List<StructureStep>? steps,
    this.promptName = '',
    this.promptContent = '',
    this.promptCategory = '',
  })  : createdAt = createdAt ?? DateTime.now(),
        altTitles = altTitles ?? [],
        tags = tags ?? [],
        steps = steps ?? [];

  String get displayTitle => switch (type) {
        SuggestionType.project =>
          tentativeTitle.trim().isNotEmpty ? tentativeTitle.trim() : topic.trim(),
        SuggestionType.structure => structureName.trim(),
        SuggestionType.prompt => promptName.trim(),
      };

  String get displaySubtitle => switch (type) {
        SuggestionType.project => topic,
        SuggestionType.structure =>
          '${steps.length} sección${steps.length == 1 ? '' : 'es'}',
        SuggestionType.prompt => promptCategory.isNotEmpty
            ? promptCategory
            : 'Prompt reutilizable',
      };

  Map<String, dynamic> toBackupJson() => {
        'id': id,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'topic': topic,
        'tentativeTitle': tentativeTitle,
        'altTitles': altTitles,
        'description': description,
        'tags': tags,
        'notes': notes,
        'structureId': structureId,
        'structureName': structureName,
        'steps': steps.map((s) => s.toJson()).toList(),
        'promptName': promptName,
        'promptContent': promptContent,
        'promptCategory': promptCategory,
      };

  factory AiSuggestion.fromBackupJson(Map<String, dynamic> json) =>
      AiSuggestion(
        id: json['id'] as String,
        type: SuggestionType.values.asNameMap()[json['type']] ??
            SuggestionType.project,
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? ''),
        topic: (json['topic'] as String?) ?? '',
        tentativeTitle: (json['tentativeTitle'] as String?) ?? '',
        altTitles: _stringList(json['altTitles']),
        description: (json['description'] as String?) ?? '',
        tags: _stringList(json['tags']),
        notes: (json['notes'] as String?) ?? '',
        structureId: (json['structureId'] as String?) ?? '',
        structureName: (json['structureName'] as String?) ?? '',
        steps: _stepsList(json['steps']),
        promptName: (json['promptName'] as String?) ?? '',
        promptContent: (json['promptContent'] as String?) ?? '',
        promptCategory: (json['promptCategory'] as String?) ?? '',
      );

  /// Migra una sugerencia de proyecto del formato anterior.
  factory AiSuggestion.fromLegacyProjectSuggestion(Map<String, dynamic> json) =>
      AiSuggestion(
        id: json['id'] as String,
        type: SuggestionType.project,
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? ''),
        topic: (json['topic'] as String?) ?? '',
        tentativeTitle: (json['tentativeTitle'] as String?) ?? '',
        altTitles: _stringList(json['altTitles']),
        description: (json['description'] as String?) ?? '',
        tags: _stringList(json['tags']),
        notes: (json['notes'] as String?) ?? '',
        structureId: (json['structureId'] as String?) ?? '',
      );

  static List<String> _stringList(Object? value) =>
      ((value as List?) ?? []).cast<String>().toList();

  static List<StructureStep> _stepsList(Object? value) =>
      ((value as List?) ?? [])
          .map((e) =>
              StructureStep.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
}
