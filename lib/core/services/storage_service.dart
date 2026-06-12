import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../hive/hive_registrar.g.dart';
import '../../ui/features/projects/models/project.dart';
import '../../ui/features/projects/models/project_suggestion.dart';
import '../../ui/features/prompts/models/prompt_item.dart';
import '../../ui/features/settings/models/style_sample.dart';
import '../../ui/features/structures/models/structure.dart';
import '../../ui/features/suggestions/models/ai_suggestion.dart';
import '../constants/app_constants.dart';

/// Inicializa Hive y expone los boxes de la aplicación.
class StorageService {
  StorageService._();

  static late final Box<Project> projects;
  static late final Box<AiSuggestion> suggestions;
  static late final Box<Structure> structures;
  static late final Box<PromptItem> prompts;
  static late final Box<StyleSample> styleSamples;
  static late final Box<dynamic> app;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    projects = await Hive.openBox<Project>(AppConstants.projectsBox);
    suggestions = await Hive.openBox<AiSuggestion>(AppConstants.suggestionsBox);
    structures = await Hive.openBox<Structure>(AppConstants.structuresBox);
    prompts = await Hive.openBox<PromptItem>(AppConstants.promptsBox);
    styleSamples =
        await Hive.openBox<StyleSample>(AppConstants.styleSamplesBox);
    app = await Hive.openBox<dynamic>(AppConstants.appBox);
    await _migrateLegacyProjectSuggestions();
  }

  /// Migra sugerencias de proyecto del box anterior al modelo unificado.
  static Future<void> _migrateLegacyProjectSuggestions() async {
    try {
      if (!await Hive.boxExists(AppConstants.projectSuggestionsBox)) return;
      final legacy = await Hive.openBox<ProjectSuggestion>(
        AppConstants.projectSuggestionsBox,
      );
      if (legacy.isEmpty) {
        await legacy.close();
        return;
      }
      for (final item in legacy.values) {
        if (suggestions.containsKey(item.id)) continue;
        await suggestions.put(
          item.id,
          AiSuggestion.fromLegacyProjectSuggestion(item.toBackupJson()),
        );
      }
      await legacy.clear();
      await legacy.close();
    } catch (_) {
      // Box legacy inexistente o incompatible; ignorar.
    }
  }
}
