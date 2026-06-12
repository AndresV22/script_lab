import 'package:hive_ce/hive.dart';

class ScriptSection extends HiveObject {
  String id;
  String title;
  String content;

  /// Descripción opcional de la sección: contexto extra para la IA
  /// (qué debe cubrir, tono, datos a incluir, etc.).
  String description;
  int order;
  bool expanded;
  bool aiGenerated;

  ScriptSection({
    required this.id,
    this.title = '',
    this.content = '',
    this.description = '',
    this.order = 0,
    this.expanded = true,
    this.aiGenerated = false,
  });

  ScriptSection copy() => ScriptSection(
        id: id,
        title: title,
        content: content,
        description: description,
        order: order,
        expanded: expanded,
        aiGenerated: aiGenerated,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'description': description,
        'order': order,
        'aiGenerated': aiGenerated,
      };

  Map<String, dynamic> toBackupJson() => {
        'id': id,
        'title': title,
        'content': content,
        'description': description,
        'order': order,
        'expanded': expanded,
        'aiGenerated': aiGenerated,
      };

  factory ScriptSection.fromBackupJson(Map<String, dynamic> json) =>
      ScriptSection(
        id: json['id'] as String,
        title: (json['title'] as String?) ?? '',
        content: (json['content'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        order: (json['order'] as num?)?.toInt() ?? 0,
        expanded: (json['expanded'] as bool?) ?? true,
        aiGenerated: (json['aiGenerated'] as bool?) ?? false,
      );
}
