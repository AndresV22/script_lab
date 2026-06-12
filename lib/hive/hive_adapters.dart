import 'package:hive_ce/hive.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/ai_options.dart';
import '../ui/features/ai/models/chat_message.dart';
import '../ui/features/projects/enums/project_status.dart';
import '../ui/features/suggestions/enums/suggestion_type.dart';
import '../ui/features/suggestions/models/ai_suggestion.dart';
import '../ui/features/projects/models/project_suggestion.dart';
import '../ui/features/projects/models/project.dart';
import '../ui/features/prompts/models/prompt_item.dart';
import '../ui/features/script_editor/models/script_section.dart';
import '../ui/features/script_editor/models/script_version.dart';
import '../ui/features/settings/models/app_settings.dart';
import '../ui/features/settings/models/channel_variables.dart';
import '../ui/features/settings/models/project_defaults.dart';
import '../ui/features/settings/models/style_sample.dart';
import '../ui/features/structures/models/structure.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<SuggestionType>(),
  AdapterSpec<AiSuggestion>(),
  AdapterSpec<ProjectSuggestion>(),
  AdapterSpec<ProjectStatus>(),
  AdapterSpec<ScriptSection>(),
  AdapterSpec<ScriptVersion>(),
  AdapterSpec<Project>(),
  AdapterSpec<StructureStep>(),
  AdapterSpec<Structure>(),
  AdapterSpec<PromptItem>(),
  AdapterSpec<AppSettings>(),
  AdapterSpec<ChannelVariables>(),
  AdapterSpec<StyleSample>(),
  AdapterSpec<ProjectDefaults>(),
  AdapterSpec<ChatMessage>(),
])
// ignore: unused_element
void _() {}
