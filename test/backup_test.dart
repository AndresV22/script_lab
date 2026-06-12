import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_lab/ui/features/ai/models/chat_message.dart';
import 'package:script_lab/ui/features/projects/enums/project_status.dart';
import 'package:script_lab/ui/features/projects/models/project.dart';
import 'package:script_lab/ui/features/prompts/models/prompt_item.dart';
import 'package:script_lab/ui/features/script_editor/models/script_section.dart';
import 'package:script_lab/ui/features/script_editor/models/script_version.dart';
import 'package:script_lab/ui/features/settings/models/app_settings.dart';
import 'package:script_lab/ui/features/settings/models/channel_variables.dart';
import 'package:script_lab/ui/features/settings/models/project_defaults.dart';
import 'package:script_lab/ui/features/settings/models/style_sample.dart';
import 'package:script_lab/ui/features/structures/models/structure.dart';

/// Codifica y decodifica como JSON real para simular el archivo de respaldo.
Map<String, dynamic> roundTrip(Map<String, dynamic> json) =>
    Map<String, dynamic>.from(jsonDecode(jsonEncode(json)) as Map);

void main() {
  group('Round-trip de respaldo', () {
    test('Project conserva todos los campos', () {
      final project = Project(
        id: 'p1',
        topic: 'Relojes de buceo',
        status: ProjectStatus.review,
        createdAt: DateTime(2026, 1, 2, 3, 4),
        updatedAt: DateTime(2026, 2, 3, 4, 5),
        tentativeTitle: '¿Cuántos relojes necesitas?',
        altTitles: ['Título A', 'Título B'],
        thumbnail: 'base64-principal',
        altThumbnails: ['base64-alt1', 'base64-alt2'],
        description: 'Descripción del video',
        tags: ['relojes', 'buceo'],
        notes: 'Notas del proyecto',
        structureId: 'st1',
        sections: [
          ScriptSection(
              id: 's1',
              title: 'Hook',
              content: 'Contenido del hook',
              description: 'Debe generar tensión y mencionar el sorteo',
              order: 0,
              expanded: false,
              aiGenerated: true),
          ScriptSection(id: 's2', title: 'Cierre', content: 'Fin', order: 1),
        ],
        versions: [
          ScriptVersion(
            id: 'v1',
            label: 'Antes de aplicar IA',
            createdAt: DateTime(2026, 1, 15),
            sections: [
              ScriptSection(id: 's1', title: 'Hook', content: 'Viejo', order: 0),
            ],
          ),
        ],
        chatMessages: [
          ChatMessage(
              role: 'user',
              content: 'Hola',
              timestamp: DateTime(2026, 3, 1, 10)),
          ChatMessage(
              role: 'assistant',
              content: 'Hola, ¿en qué te ayudo?',
              timestamp: DateTime(2026, 3, 1, 10, 1)),
        ],
      );

      final restored = Project.fromBackupJson(roundTrip(project.toBackupJson()));

      expect(restored.id, project.id);
      expect(restored.topic, project.topic);
      expect(restored.status, project.status);
      expect(restored.createdAt, project.createdAt);
      expect(restored.updatedAt, project.updatedAt);
      expect(restored.tentativeTitle, project.tentativeTitle);
      expect(restored.altTitles, project.altTitles);
      expect(restored.thumbnail, project.thumbnail);
      expect(restored.altThumbnails, project.altThumbnails);
      expect(restored.description, project.description);
      expect(restored.tags, project.tags);
      expect(restored.notes, project.notes);
      expect(restored.structureId, project.structureId);

      expect(restored.sections.length, 2);
      expect(restored.sections.first.id, 's1');
      expect(restored.sections.first.expanded, false);
      expect(restored.sections.first.aiGenerated, true);
      expect(restored.sections.first.content, 'Contenido del hook');
      expect(restored.sections.first.description,
          'Debe generar tensión y mencionar el sorteo');

      expect(restored.versions.length, 1);
      expect(restored.versions.first.label, 'Antes de aplicar IA');
      expect(restored.versions.first.createdAt, DateTime(2026, 1, 15));
      expect(restored.versions.first.sections.single.content, 'Viejo');

      expect(restored.chatMessages.length, 2);
      expect(restored.chatMessages.first.role, 'user');
      expect(restored.chatMessages.last.content, 'Hola, ¿en qué te ayudo?');
      expect(restored.chatMessages.first.timestamp, DateTime(2026, 3, 1, 10));
    });

    test('Structure conserva id, fecha y pasos', () {
      final structure = Structure(
        id: 'st1',
        name: 'Review de relojes',
        createdAt: DateTime(2025, 12, 25),
        steps: [
          StructureStep(name: 'Hook', description: 'Inicio fuerte'),
          StructureStep(name: 'Specs'),
        ],
      );

      final restored =
          Structure.fromBackupJson(roundTrip(structure.toBackupJson()));

      expect(restored.id, 'st1');
      expect(restored.name, 'Review de relojes');
      expect(restored.createdAt, DateTime(2025, 12, 25));
      expect(restored.steps.length, 2);
      expect(restored.steps.first.description, 'Inicio fuerte');
    });

    test('PromptItem y StyleSample', () {
      final prompt = PromptItem(
          id: 'pr1', name: 'Mejorar hook', content: 'Reescribe…', category: 'Redacción');
      final restoredPrompt =
          PromptItem.fromBackupJson(roundTrip(prompt.toBackupJson()));
      expect(restoredPrompt.id, 'pr1');
      expect(restoredPrompt.name, 'Mejorar hook');
      expect(restoredPrompt.content, 'Reescribe…');
      expect(restoredPrompt.category, 'Redacción');

      final sample = StyleSample(
          id: 'ss1',
          name: 'video1.txt',
          content: 'Transcripción…',
          importedAt: DateTime(2026, 4, 1));
      final restoredSample =
          StyleSample.fromBackupJson(roundTrip(sample.toBackupJson()));
      expect(restoredSample.id, 'ss1');
      expect(restoredSample.name, 'video1.txt');
      expect(restoredSample.content, 'Transcripción…');
      expect(restoredSample.importedAt, DateTime(2026, 4, 1));
    });

    test('AppSettings, ChannelVariables y ProjectDefaults', () {
      final settings = AppSettings(
        ollamaUrl: 'http://otra:11434',
        defaultModel: 'llama3',
        themeMode: 'dark',
        wordsPerMinute: 150,
        projectsViewMode: 'list',
        structuresViewMode: 'grid',
        cardSize: 'l',
      );
      final restoredSettings =
          AppSettings.fromBackupJson(roundTrip(settings.toBackupJson()));
      expect(restoredSettings.ollamaUrl, 'http://otra:11434');
      expect(restoredSettings.defaultModel, 'llama3');
      expect(restoredSettings.themeMode, 'dark');
      expect(restoredSettings.wordsPerMinute, 150);
      expect(restoredSettings.projectsViewMode, 'list');
      expect(restoredSettings.structuresViewMode, 'grid');
      expect(restoredSettings.cardSize, 'l');

      final channel = ChannelVariables(
        channelName: 'Relojes Altiro',
        greeting: 'Bienvenidos',
        audience: 'Aficionados',
        style: 'Conversacional',
        avoid: 'Formalismos',
        avgDuration: '10 minutos',
      );
      final restoredChannel =
          ChannelVariables.fromBackupJson(roundTrip(channel.toBackupJson()));
      expect(restoredChannel.channelName, 'Relojes Altiro');
      expect(restoredChannel.greeting, 'Bienvenidos');
      expect(restoredChannel.audience, 'Aficionados');
      expect(restoredChannel.style, 'Conversacional');
      expect(restoredChannel.avoid, 'Formalismos');
      expect(restoredChannel.avgDuration, '10 minutos');

      final defaults = ProjectDefaults(
        description: 'Desc fija',
        tags: ['tag1', 'tag2'],
        notes: 'Checklist',
        structureId: 'st1',
      );
      final restoredDefaults =
          ProjectDefaults.fromBackupJson(roundTrip(defaults.toBackupJson()));
      expect(restoredDefaults.description, 'Desc fija');
      expect(restoredDefaults.tags, ['tag1', 'tag2']);
      expect(restoredDefaults.notes, 'Checklist');
      expect(restoredDefaults.structureId, 'st1');
    });

    test('Respaldos sin campos opcionales usan valores por defecto', () {
      final project = Project.fromBackupJson({'id': 'p1'});
      expect(project.status, ProjectStatus.idea);
      expect(project.sections, isEmpty);
      expect(project.versions, isEmpty);
      expect(project.chatMessages, isEmpty);
      expect(project.thumbnail, '');

      final settings = AppSettings.fromBackupJson(const {});
      expect(settings.projectsViewMode, 'grid');
      expect(settings.cardSize, 'm');
    });
  });
}
