import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'core/services/ollama_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/theme_controller.dart';
import 'ui/features/suggestions/services/suggestions_service.dart';
import 'ui/features/projects/services/project_service.dart';
import 'ui/features/prompts/services/prompt_service.dart';
import 'ui/features/structures/services/structure_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  Get.put(SettingsService(), permanent: true);
  Get.put(OllamaService(), permanent: true);
  Get.put(ProjectService(), permanent: true);
  Get.put(SuggestionsService(), permanent: true);
  Get.put(StructureService(), permanent: true);
  Get.put(PromptService(), permanent: true);
  Get.put(ThemeController(), permanent: true);

  runApp(const ScriptLabApp());
}
