import 'package:hive_ce/hive.dart';

import '../../ai/models/chat_message.dart';
import '../../script_editor/models/script_section.dart';
import '../../script_editor/models/script_version.dart';
import '../enums/project_status.dart';

class Project extends HiveObject {
  String id;
  String topic;
  ProjectStatus status;
  DateTime createdAt;
  DateTime updatedAt;
  String tentativeTitle;
  List<String> altTitles;

  /// Imagen en base64 de la miniatura principal.
  String thumbnail;

  /// Alternativas de miniatura en base64.
  List<String> altThumbnails;
  String description;
  List<String> tags;
  String notes;
  List<ScriptSection> sections;
  List<ScriptVersion> versions;
  String structureId;
  List<ChatMessage> chatMessages;

  Project({
    required this.id,
    this.topic = '',
    this.status = ProjectStatus.idea,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.tentativeTitle = '',
    List<String>? altTitles,
    this.thumbnail = '',
    List<String>? altThumbnails,
    this.description = '',
    List<String>? tags,
    this.notes = '',
    List<ScriptSection>? sections,
    List<ScriptVersion>? versions,
    this.structureId = '',
    List<ChatMessage>? chatMessages,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        altTitles = altTitles ?? [],
        altThumbnails = altThumbnails ?? [],
        tags = tags ?? [],
        sections = sections ?? [],
        versions = versions ?? [],
        chatMessages = chatMessages ?? [];

  List<ScriptSection> get orderedSections =>
      [...sections]..sort((a, b) => a.order.compareTo(b.order));

  String get displayTitle =>
      tentativeTitle.trim().isNotEmpty ? tentativeTitle.trim() : topic.trim();

  String get fullScriptText => orderedSections
      .map((s) => '## ${s.title}\n\n${s.content}')
      .join('\n\n');

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tentativeTitle': tentativeTitle,
        'altTitles': altTitles,
        'description': description,
        'tags': tags,
        'notes': notes,
        'sections': orderedSections.map((s) => s.toJson()).toList(),
      };

  /// Serialización completa para respaldos (incluye miniaturas, versiones y chat).
  Map<String, dynamic> toBackupJson() => {
        'id': id,
        'topic': topic,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tentativeTitle': tentativeTitle,
        'altTitles': altTitles,
        'thumbnail': thumbnail,
        'altThumbnails': altThumbnails,
        'description': description,
        'tags': tags,
        'notes': notes,
        'structureId': structureId,
        'sections': sections.map((s) => s.toBackupJson()).toList(),
        'versions': versions.map((v) => v.toBackupJson()).toList(),
        'chatMessages': chatMessages.map((m) => m.toBackupJson()).toList(),
      };

  factory Project.fromBackupJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        topic: (json['topic'] as String?) ?? '',
        status: ProjectStatus.values.asNameMap()[json['status']] ??
            ProjectStatus.idea,
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? ''),
        updatedAt: DateTime.tryParse((json['updatedAt'] as String?) ?? ''),
        tentativeTitle: (json['tentativeTitle'] as String?) ?? '',
        altTitles: _stringList(json['altTitles']),
        thumbnail: (json['thumbnail'] as String?) ?? '',
        altThumbnails: _stringList(json['altThumbnails']),
        description: (json['description'] as String?) ?? '',
        tags: _stringList(json['tags']),
        notes: (json['notes'] as String?) ?? '',
        structureId: (json['structureId'] as String?) ?? '',
        sections: _mapList(json['sections'])
            .map(ScriptSection.fromBackupJson)
            .toList(),
        versions: _mapList(json['versions'])
            .map(ScriptVersion.fromBackupJson)
            .toList(),
        chatMessages: _mapList(json['chatMessages'])
            .map(ChatMessage.fromBackupJson)
            .toList(),
      );

  static List<String> _stringList(Object? value) =>
      ((value as List?) ?? []).cast<String>().toList();

  static List<Map<String, dynamic>> _mapList(Object? value) =>
      ((value as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
}
