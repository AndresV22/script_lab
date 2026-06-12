import 'package:hive_ce/hive.dart';

class StyleSample extends HiveObject {
  String id;
  String name;
  String content;
  DateTime importedAt;

  StyleSample({
    required this.id,
    this.name = '',
    this.content = '',
    DateTime? importedAt,
  }) : importedAt = importedAt ?? DateTime.now();

  Map<String, dynamic> toBackupJson() => {
        'id': id,
        'name': name,
        'content': content,
        'importedAt': importedAt.toIso8601String(),
      };

  factory StyleSample.fromBackupJson(Map<String, dynamic> json) => StyleSample(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? '',
        content: (json['content'] as String?) ?? '',
        importedAt: DateTime.tryParse((json['importedAt'] as String?) ?? ''),
      );
}
