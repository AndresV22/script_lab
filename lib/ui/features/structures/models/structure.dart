import 'package:hive_ce/hive.dart';

class StructureStep extends HiveObject {
  String name;
  String description;

  StructureStep({this.name = '', this.description = ''});

  StructureStep copy() => StructureStep(name: name, description: description);

  Map<String, dynamic> toJson() => {'name': name, 'description': description};

  factory StructureStep.fromJson(Map<String, dynamic> json) => StructureStep(
        name: (json['name'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
      );
}

class Structure extends HiveObject {
  String id;
  String name;
  List<StructureStep> steps;
  DateTime createdAt;

  Structure({
    required this.id,
    this.name = '',
    List<StructureStep>? steps,
    DateTime? createdAt,
  })  : steps = steps ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'name': name,
        'steps': steps.map((s) => s.toJson()).toList(),
      };

  factory Structure.fromJson(Map<String, dynamic> json, String id) => Structure(
        id: id,
        name: (json['name'] as String?) ?? '',
        steps: ((json['steps'] as List?) ?? [])
            .map((e) => StructureStep.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Map<String, dynamic> toBackupJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'steps': steps.map((s) => s.toJson()).toList(),
      };

  factory Structure.fromBackupJson(Map<String, dynamic> json) => Structure(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? '',
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? ''),
        steps: ((json['steps'] as List?) ?? [])
            .map((e) =>
                StructureStep.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
