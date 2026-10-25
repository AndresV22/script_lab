import 'package:hive_ce/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/ai_options.dart';
import '../../../../core/constants/llm_provider.dart';

class AppSettings extends HiveObject {
  String ollamaUrl;
  String defaultModel;

  /// ollama | deepseek | hive | openai | claude
  String llmProvider;
  String deepseekApiKey;
  String deepseekBaseUrl;

  /// v1 | v3
  String deepseekApiVersion;
  String hiveApiKey;
  String hiveBaseUrl;

  /// v1 | v3
  String hiveApiVersion;
  String openaiApiKey;
  String openaiBaseUrl;

  /// v1 | v3
  String openaiApiVersion;
  String claudeApiKey;
  String claudeBaseUrl;

  /// v1 | v3
  String claudeApiVersion;

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
    this.openaiApiKey = '',
    this.openaiBaseUrl = LlmProvider.openaiV1Url,
    this.openaiApiVersion = LlmProvider.v1,
    this.claudeApiKey = '',
    this.claudeBaseUrl = LlmProvider.claudeV1Url,
    this.claudeApiVersion = LlmProvider.v1,
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
        'openaiApiKey': openaiApiKey,
        'openaiBaseUrl': openaiBaseUrl,
        'openaiApiVersion': openaiApiVersion,
        'claudeApiKey': claudeApiKey,
        'claudeBaseUrl': claudeBaseUrl,
        'claudeApiVersion': claudeApiVersion,
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
        openaiApiKey: (json['openaiApiKey'] as String?) ?? '',
        openaiBaseUrl:
            (json['openaiBaseUrl'] as String?) ?? LlmProvider.openaiV1Url,
        openaiApiVersion:
            (json['openaiApiVersion'] as String?) ?? LlmProvider.v1,
        claudeApiKey: (json['claudeApiKey'] as String?) ?? '',
        claudeBaseUrl:
            (json['claudeBaseUrl'] as String?) ?? LlmProvider.claudeV1Url,
        claudeApiVersion:
            (json['claudeApiVersion'] as String?) ?? LlmProvider.v1,
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

  String baseUrlFor(String provider) => switch (provider) {
        LlmProvider.hive => hiveBaseUrl,
        LlmProvider.openai => openaiBaseUrl,
        LlmProvider.claude => claudeBaseUrl,
        _ => deepseekBaseUrl,
      };

  String apiKeyFor(String provider) => switch (provider) {
        LlmProvider.hive => hiveApiKey,
        LlmProvider.openai => openaiApiKey,
        LlmProvider.claude => claudeApiKey,
        _ => deepseekApiKey,
      };

  String apiVersionFor(String provider) => switch (provider) {
        LlmProvider.hive => hiveApiVersion,
        LlmProvider.openai => openaiApiVersion,
        LlmProvider.claude => claudeApiVersion,
        _ => deepseekApiVersion,
      };
}
