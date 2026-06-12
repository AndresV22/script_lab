import 'package:hive_ce/hive.dart';

/// Valores predeterminados que se aplican a cada proyecto nuevo.
class ProjectDefaults extends HiveObject {
  String description;
  List<String> tags;
  String notes;

  /// Id de la estructura que se aplica automáticamente ('' = ninguna).
  String structureId;

  ProjectDefaults({
    this.description = '',
    List<String>? tags,
    this.notes = '',
    this.structureId = '',
  }) : tags = tags ?? [];

  Map<String, dynamic> toBackupJson() => {
        'description': description,
        'tags': tags,
        'notes': notes,
        'structureId': structureId,
      };

  factory ProjectDefaults.fromBackupJson(Map<String, dynamic> json) =>
      ProjectDefaults(
        description: (json['description'] as String?) ?? '',
        tags: ((json['tags'] as List?) ?? []).cast<String>().toList(),
        notes: (json['notes'] as String?) ?? '',
        structureId: (json['structureId'] as String?) ?? '',
      );
}
