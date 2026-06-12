import 'package:hive_ce/hive.dart';

/// Sugerencia de proyecto generada por IA (metadatos sin guion).
class ProjectSuggestion extends HiveObject {
  String id;
  String topic;
  String tentativeTitle;
  List<String> altTitles;
  String description;
  List<String> tags;
  String notes;
  String structureId;
  DateTime createdAt;

  ProjectSuggestion({
    required this.id,
    this.topic = '',
    this.tentativeTitle = '',
    List<String>? altTitles,
    this.description = '',
    List<String>? tags,
    this.notes = '',
    this.structureId = '',
    DateTime? createdAt,
  })  : altTitles = altTitles ?? [],
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now();

  String get displayTitle =>
      tentativeTitle.trim().isNotEmpty ? tentativeTitle.trim() : topic.trim();

  Map<String, dynamic> toBackupJson() => {
        'id': id,
        'topic': topic,
        'tentativeTitle': tentativeTitle,
        'altTitles': altTitles,
        'description': description,
        'tags': tags,
        'notes': notes,
        'structureId': structureId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ProjectSuggestion.fromBackupJson(Map<String, dynamic> json) =>
      ProjectSuggestion(
        id: json['id'] as String,
        topic: (json['topic'] as String?) ?? '',
        tentativeTitle: (json['tentativeTitle'] as String?) ?? '',
        altTitles: _stringList(json['altTitles']),
        description: (json['description'] as String?) ?? '',
        tags: _stringList(json['tags']),
        notes: (json['notes'] as String?) ?? '',
        structureId: (json['structureId'] as String?) ?? '',
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? ''),
      );

  static List<String> _stringList(Object? value) =>
      ((value as List?) ?? []).cast<String>().toList();
}
