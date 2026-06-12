import 'package:hive_ce/hive.dart';

import 'script_section.dart';

class ScriptVersion extends HiveObject {
  String id;
  String label;
  DateTime createdAt;
  List<ScriptSection> sections;

  ScriptVersion({
    required this.id,
    this.label = '',
    DateTime? createdAt,
    List<ScriptSection>? sections,
  })  : createdAt = createdAt ?? DateTime.now(),
        sections = sections ?? [];

  String get fullText => sections
      .map((s) => '## ${s.title}\n\n${s.content}')
      .join('\n\n');

  Map<String, dynamic> toBackupJson() => {
        'id': id,
        'label': label,
        'createdAt': createdAt.toIso8601String(),
        'sections': sections.map((s) => s.toBackupJson()).toList(),
      };

  factory ScriptVersion.fromBackupJson(Map<String, dynamic> json) =>
      ScriptVersion(
        id: json['id'] as String,
        label: (json['label'] as String?) ?? '',
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? ''),
        sections: ((json['sections'] as List?) ?? [])
            .map((e) => ScriptSection.fromBackupJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
