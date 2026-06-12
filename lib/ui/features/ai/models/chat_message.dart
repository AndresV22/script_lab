import 'package:hive_ce/hive.dart';

/// Mensaje del chat persistente de un proyecto.
class ChatMessage extends HiveObject {
  /// 'user' o 'assistant'.
  String role;
  String content;
  String thinking;
  DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    this.thinking = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 'user';

  bool get hasThinking => thinking.trim().isNotEmpty;

  Map<String, dynamic> toBackupJson() => {
        'role': role,
        'content': content,
        if (thinking.isNotEmpty) 'thinking': thinking,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromBackupJson(Map<String, dynamic> json) => ChatMessage(
        role: (json['role'] as String?) ?? 'user',
        content: (json['content'] as String?) ?? '',
        thinking: (json['thinking'] as String?) ?? '',
        timestamp: DateTime.tryParse((json['timestamp'] as String?) ?? ''),
      );
}
