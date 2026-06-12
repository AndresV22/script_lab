import 'package:hive_ce/hive.dart';

import '../../../../core/constants/app_constants.dart';

class AppSettings extends HiveObject {
  String ollamaUrl;
  String defaultModel;

  /// 'system' | 'light' | 'dark'
  String themeMode;
  int wordsPerMinute;

  /// 'grid' | 'list'
  String projectsViewMode;

  /// 'grid' | 'list'
  String structuresViewMode;

  /// 's' | 'm' | 'l'
  String cardSize;

  AppSettings({
    this.ollamaUrl = AppConstants.defaultOllamaUrl,
    this.defaultModel = '',
    this.themeMode = 'system',
    this.wordsPerMinute = AppConstants.defaultWordsPerMinute,
    this.projectsViewMode = 'grid',
    this.structuresViewMode = 'grid',
    this.cardSize = 'm',
  });

  Map<String, dynamic> toBackupJson() => {
        'ollamaUrl': ollamaUrl,
        'defaultModel': defaultModel,
        'themeMode': themeMode,
        'wordsPerMinute': wordsPerMinute,
        'projectsViewMode': projectsViewMode,
        'structuresViewMode': structuresViewMode,
        'cardSize': cardSize,
      };

  factory AppSettings.fromBackupJson(Map<String, dynamic> json) => AppSettings(
        ollamaUrl:
            (json['ollamaUrl'] as String?) ?? AppConstants.defaultOllamaUrl,
        defaultModel: (json['defaultModel'] as String?) ?? '',
        themeMode: (json['themeMode'] as String?) ?? 'system',
        wordsPerMinute: (json['wordsPerMinute'] as num?)?.toInt() ??
            AppConstants.defaultWordsPerMinute,
        projectsViewMode: (json['projectsViewMode'] as String?) ?? 'grid',
        structuresViewMode: (json['structuresViewMode'] as String?) ?? 'grid',
        cardSize: (json['cardSize'] as String?) ?? 'm',
      );
}
