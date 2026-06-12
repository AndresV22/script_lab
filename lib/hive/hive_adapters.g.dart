// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class ProjectStatusAdapter extends TypeAdapter<ProjectStatus> {
  @override
  final typeId = 0;

  @override
  ProjectStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProjectStatus.idea;
      case 1:
        return ProjectStatus.writing;
      case 2:
        return ProjectStatus.review;
      case 3:
        return ProjectStatus.ready;
      case 4:
        return ProjectStatus.published;
      default:
        return ProjectStatus.idea;
    }
  }

  @override
  void write(BinaryWriter writer, ProjectStatus obj) {
    switch (obj) {
      case ProjectStatus.idea:
        writer.writeByte(0);
      case ProjectStatus.writing:
        writer.writeByte(1);
      case ProjectStatus.review:
        writer.writeByte(2);
      case ProjectStatus.ready:
        writer.writeByte(3);
      case ProjectStatus.published:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScriptSectionAdapter extends TypeAdapter<ScriptSection> {
  @override
  final typeId = 1;

  @override
  ScriptSection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScriptSection(
      id: fields[0] as String,
      title: fields[1] == null ? '' : fields[1] as String,
      content: fields[2] == null ? '' : fields[2] as String,
      description: fields[6] == null ? '' : fields[6] as String,
      order: fields[3] == null ? 0 : (fields[3] as num).toInt(),
      expanded: fields[4] == null ? true : fields[4] as bool,
      aiGenerated: fields[5] == null ? false : fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScriptSection obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.order)
      ..writeByte(4)
      ..write(obj.expanded)
      ..writeByte(5)
      ..write(obj.aiGenerated)
      ..writeByte(6)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScriptSectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScriptVersionAdapter extends TypeAdapter<ScriptVersion> {
  @override
  final typeId = 2;

  @override
  ScriptVersion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScriptVersion(
      id: fields[0] as String,
      label: fields[1] == null ? '' : fields[1] as String,
      createdAt: fields[2] as DateTime?,
      sections: (fields[3] as List?)?.cast<ScriptSection>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScriptVersion obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.sections);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScriptVersionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final typeId = 3;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      topic: fields[1] == null ? '' : fields[1] as String,
      status: fields[2] == null
          ? ProjectStatus.idea
          : fields[2] as ProjectStatus,
      createdAt: fields[3] as DateTime?,
      updatedAt: fields[4] as DateTime?,
      tentativeTitle: fields[5] == null ? '' : fields[5] as String,
      altTitles: (fields[6] as List?)?.cast<String>(),
      thumbnail: fields[7] == null ? '' : fields[7] as String,
      altThumbnails: (fields[8] as List?)?.cast<String>(),
      description: fields[9] == null ? '' : fields[9] as String,
      tags: (fields[10] as List?)?.cast<String>(),
      notes: fields[11] == null ? '' : fields[11] as String,
      sections: (fields[12] as List?)?.cast<ScriptSection>(),
      versions: (fields[13] as List?)?.cast<ScriptVersion>(),
      structureId: fields[14] == null ? '' : fields[14] as String,
      chatMessages: (fields[15] as List?)?.cast<ChatMessage>(),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.topic)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.tentativeTitle)
      ..writeByte(6)
      ..write(obj.altTitles)
      ..writeByte(7)
      ..write(obj.thumbnail)
      ..writeByte(8)
      ..write(obj.altThumbnails)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.sections)
      ..writeByte(13)
      ..write(obj.versions)
      ..writeByte(14)
      ..write(obj.structureId)
      ..writeByte(15)
      ..write(obj.chatMessages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StructureStepAdapter extends TypeAdapter<StructureStep> {
  @override
  final typeId = 4;

  @override
  StructureStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StructureStep(
      name: fields[0] == null ? '' : fields[0] as String,
      description: fields[1] == null ? '' : fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StructureStep obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StructureStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StructureAdapter extends TypeAdapter<Structure> {
  @override
  final typeId = 5;

  @override
  Structure read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Structure(
      id: fields[0] as String,
      name: fields[1] == null ? '' : fields[1] as String,
      steps: (fields[2] as List?)?.cast<StructureStep>(),
      createdAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Structure obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.steps)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StructureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PromptItemAdapter extends TypeAdapter<PromptItem> {
  @override
  final typeId = 6;

  @override
  PromptItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PromptItem(
      id: fields[0] as String,
      name: fields[1] == null ? '' : fields[1] as String,
      content: fields[2] == null ? '' : fields[2] as String,
      category: fields[3] == null ? '' : fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PromptItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final typeId = 7;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      ollamaUrl: fields[0] == null
          ? AppConstants.defaultOllamaUrl
          : fields[0] as String,
      defaultModel: fields[1] == null ? '' : fields[1] as String,
      themeMode: fields[2] == null ? 'system' : fields[2] as String,
      wordsPerMinute: fields[3] == null
          ? AppConstants.defaultWordsPerMinute
          : (fields[3] as num).toInt(),
      projectsViewMode: fields[4] == null ? 'grid' : fields[4] as String,
      structuresViewMode: fields[5] == null ? 'grid' : fields[5] as String,
      cardSize: fields[6] == null ? 'm' : fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.ollamaUrl)
      ..writeByte(1)
      ..write(obj.defaultModel)
      ..writeByte(2)
      ..write(obj.themeMode)
      ..writeByte(3)
      ..write(obj.wordsPerMinute)
      ..writeByte(4)
      ..write(obj.projectsViewMode)
      ..writeByte(5)
      ..write(obj.structuresViewMode)
      ..writeByte(6)
      ..write(obj.cardSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChannelVariablesAdapter extends TypeAdapter<ChannelVariables> {
  @override
  final typeId = 8;

  @override
  ChannelVariables read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChannelVariables(
      channelName: fields[0] == null ? '' : fields[0] as String,
      greeting: fields[1] == null ? '' : fields[1] as String,
      audience: fields[2] == null ? '' : fields[2] as String,
      style: fields[3] == null ? '' : fields[3] as String,
      avoid: fields[4] == null ? '' : fields[4] as String,
      avgDuration: fields[5] == null ? '' : fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChannelVariables obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.channelName)
      ..writeByte(1)
      ..write(obj.greeting)
      ..writeByte(2)
      ..write(obj.audience)
      ..writeByte(3)
      ..write(obj.style)
      ..writeByte(4)
      ..write(obj.avoid)
      ..writeByte(5)
      ..write(obj.avgDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelVariablesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StyleSampleAdapter extends TypeAdapter<StyleSample> {
  @override
  final typeId = 9;

  @override
  StyleSample read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StyleSample(
      id: fields[0] as String,
      name: fields[1] == null ? '' : fields[1] as String,
      content: fields[2] == null ? '' : fields[2] as String,
      importedAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, StyleSample obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.importedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StyleSampleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectDefaultsAdapter extends TypeAdapter<ProjectDefaults> {
  @override
  final typeId = 10;

  @override
  ProjectDefaults read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectDefaults(
      description: fields[0] == null ? '' : fields[0] as String,
      tags: (fields[1] as List?)?.cast<String>(),
      notes: fields[2] == null ? '' : fields[2] as String,
      structureId: fields[3] == null ? '' : fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectDefaults obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.tags)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.structureId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectDefaultsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final typeId = 11;

  @override
  ChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      role: fields[0] as String,
      content: fields[1] as String,
      timestamp: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.role)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectSuggestionAdapter extends TypeAdapter<ProjectSuggestion> {
  @override
  final typeId = 12;

  @override
  ProjectSuggestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectSuggestion(
      id: fields[0] as String,
      topic: fields[1] == null ? '' : fields[1] as String,
      tentativeTitle: fields[2] == null ? '' : fields[2] as String,
      altTitles: (fields[3] as List?)?.cast<String>(),
      description: fields[4] == null ? '' : fields[4] as String,
      tags: (fields[5] as List?)?.cast<String>(),
      notes: fields[6] == null ? '' : fields[6] as String,
      structureId: fields[7] == null ? '' : fields[7] as String,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectSuggestion obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.topic)
      ..writeByte(2)
      ..write(obj.tentativeTitle)
      ..writeByte(3)
      ..write(obj.altTitles)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.structureId)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectSuggestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SuggestionTypeAdapter extends TypeAdapter<SuggestionType> {
  @override
  final typeId = 13;

  @override
  SuggestionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SuggestionType.project;
      case 1:
        return SuggestionType.structure;
      case 2:
        return SuggestionType.prompt;
      default:
        return SuggestionType.project;
    }
  }

  @override
  void write(BinaryWriter writer, SuggestionType obj) {
    switch (obj) {
      case SuggestionType.project:
        writer.writeByte(0);
      case SuggestionType.structure:
        writer.writeByte(1);
      case SuggestionType.prompt:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AiSuggestionAdapter extends TypeAdapter<AiSuggestion> {
  @override
  final typeId = 14;

  @override
  AiSuggestion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiSuggestion(
      id: fields[0] as String,
      type: fields[1] as SuggestionType,
      createdAt: fields[2] as DateTime?,
      topic: fields[3] == null ? '' : fields[3] as String,
      tentativeTitle: fields[4] == null ? '' : fields[4] as String,
      altTitles: (fields[5] as List?)?.cast<String>(),
      description: fields[6] == null ? '' : fields[6] as String,
      tags: (fields[7] as List?)?.cast<String>(),
      notes: fields[8] == null ? '' : fields[8] as String,
      structureId: fields[9] == null ? '' : fields[9] as String,
      structureName: fields[10] == null ? '' : fields[10] as String,
      steps: (fields[11] as List?)?.cast<StructureStep>(),
      promptName: fields[12] == null ? '' : fields[12] as String,
      promptContent: fields[13] == null ? '' : fields[13] as String,
      promptCategory: fields[14] == null ? '' : fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AiSuggestion obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.topic)
      ..writeByte(4)
      ..write(obj.tentativeTitle)
      ..writeByte(5)
      ..write(obj.altTitles)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.structureId)
      ..writeByte(10)
      ..write(obj.structureName)
      ..writeByte(11)
      ..write(obj.steps)
      ..writeByte(12)
      ..write(obj.promptName)
      ..writeByte(13)
      ..write(obj.promptContent)
      ..writeByte(14)
      ..write(obj.promptCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiSuggestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
