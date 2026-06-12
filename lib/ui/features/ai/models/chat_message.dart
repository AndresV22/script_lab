import 'package:hive_ce/hive.dart';

/// Mensaje del chat persistente de un proyecto.
class ChatMessage extends HiveObject {
  /// 'user' o 'assistant'.
  String role;
  String content;
  DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 'user';

  Map<String, dynamic> toBackupJson() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromBackupJson(Map<String, dynamic> json) => ChatMessage(
        role: (json['role'] as String?) ?? 'user',
        content: (json['content'] as String?) ?? '',
        timestamp: DateTime.tryParse((json['timestamp'] as String?) ?? ''),
      );
}
