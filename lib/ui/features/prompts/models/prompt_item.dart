import 'package:hive_ce/hive.dart';

class PromptItem extends HiveObject {
  String id;
  String name;
  String content;
  String category;

  PromptItem({
    required this.id,
    this.name = '',
    this.content = '',
    this.category = '',
  });

  Map<String, dynamic> toBackupJson() => {
        'id': id,
        'name': name,
        'content': content,
        'category': category,
      };

  factory PromptItem.fromBackupJson(Map<String, dynamic> json) => PromptItem(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? '',
        content: (json['content'] as String?) ?? '',
        category: (json['category'] as String?) ?? '',
      );
}
