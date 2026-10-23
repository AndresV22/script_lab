import 'package:hive_ce/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/ai_options.dart';
import '../../../../core/constants/llm_provider.dart';

class AppSettings extends HiveObject {
  String ollamaUrl;
  String defaultModel;

  /// ollama | deepseek | hive
  String llmProvider;
  String deepseekApiKey;
  String deepseekBaseUrl;

  /// v1 | v3
  String deepseekApiVersion;
  String hiveApiKey;
  String hiveBaseUrl;

  /// v1 | v3
  String hiveApiVersion;

  /// Modo thinking de Ollama: off | on | low | medium | high
  String thinkMode;

  /// 'system' | 'light' | 'dark'
  String themeMode;
  int wordsPerMinute;

  /// 'grid' | 'list'
  String projectsViewMode;

  /// 'grid' | 'list'
  String structuresViewMode;

  /// 's' | 'm' | 'l'
  String cardSize;

  /// 'list' | 'kanban' | 'calendar'
  String projectsSectionMode;

  AppSettings({
    this.ollamaUrl = AppConstants.defaultOllamaUrl,
    this.defaultModel = '',
    this.llmProvider = LlmProvider.ollama,
    this.deepseekApiKey = '',
    this.deepseekBaseUrl = LlmProvider.deepseekV1Url,
    this.deepseekApiVersion = LlmProvider.v1,
    this.hiveApiKey = '',
    this.hiveBaseUrl = LlmProvider.hiveV3Url,
    this.hiveApiVersion = LlmProvider.v3,
    this.thinkMode = AiThinkMode.off,
    this.themeMode = 'system',
    this.wordsPerMinute = AppConstants.defaultWordsPerMinute,
    this.projectsViewMode = 'grid',
    this.structuresViewMode = 'grid',
    this.cardSize = 'm',
    this.projectsSectionMode = 'list',
  });

  Map<String, dynamic> toBackupJson() => {
        'ollamaUrl': ollamaUrl,
        'defaultModel': defaultModel,
        'llmProvider': llmProvider,
        'deepseekApiKey': deepseekApiKey,
        'deepseekBaseUrl': deepseekBaseUrl,
        'deepseekApiVersion': deepseekApiVersion,
        'hiveApiKey': hiveApiKey,
        'hiveBaseUrl': hiveBaseUrl,
        'hiveApiVersion': hiveApiVersion,
        'thinkMode': thinkMode,
        'themeMode': themeMode,
        'wordsPerMinute': wordsPerMinute,
        'projectsViewMode': projectsViewMode,
        'structuresViewMode': structuresViewMode,
        'cardSize': cardSize,
        'projectsSectionMode': projectsSectionMode,
      };

  factory AppSettings.fromBackupJson(Map<String, dynamic> json) => AppSettings(
        ollamaUrl:
            (json['ollamaUrl'] as String?) ?? AppConstants.defaultOllamaUrl,
        defaultModel: (json['defaultModel'] as String?) ?? '',
        llmProvider: (json['llmProvider'] as String?) ?? LlmProvider.ollama,
        deepseekApiKey: (json['deepseekApiKey'] as String?) ?? '',
        deepseekBaseUrl:
            (json['deepseekBaseUrl'] as String?) ?? LlmProvider.deepseekV1Url,
        deepseekApiVersion:
            (json['deepseekApiVersion'] as String?) ?? LlmProvider.v1,
        hiveApiKey: (json['hiveApiKey'] as String?) ?? '',
        hiveBaseUrl: (json['hiveBaseUrl'] as String?) ?? LlmProvider.hiveV3Url,
        hiveApiVersion: (json['hiveApiVersion'] as String?) ?? LlmProvider.v3,
        thinkMode: (json['thinkMode'] as String?) ?? AiThinkMode.off,
        themeMode: (json['themeMode'] as String?) ?? 'system',
        wordsPerMinute: (json['wordsPerMinute'] as num?)?.toInt() ??
            AppConstants.defaultWordsPerMinute,
        projectsViewMode: (json['projectsViewMode'] as String?) ?? 'grid',
        structuresViewMode: (json['structuresViewMode'] as String?) ?? 'grid',
        cardSize: (json['cardSize'] as String?) ?? 'm',
        projectsSectionMode:
            (json['projectsSectionMode'] as String?) ?? 'list',
      );
}
