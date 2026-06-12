import 'package:get/get.dart';

import '../../ui/features/dashboard/controller/dashboard_controller.dart';
import '../../ui/features/dashboard/views/dashboard_view.dart';
import '../../ui/features/ai/controller/ai_controller.dart';
import '../../ui/features/ai/controller/chat_controller.dart';
import '../../ui/features/analytics/controller/analytics_controller.dart';
import '../../ui/features/projects/controller/project_detail_controller.dart';
import '../../ui/features/suggestions/controller/suggestions_controller.dart';
import '../../ui/features/suggestions/views/suggestions_view.dart';
import '../../ui/features/projects/controller/projects_controller.dart';
import '../../ui/features/projects/views/project_detail_view.dart';
import '../../ui/features/projects/views/projects_view.dart';
import '../../ui/features/prompts/controller/prompts_controller.dart';
import '../../ui/features/prompts/views/prompts_view.dart';
import '../../ui/features/analytics/views/analytics_view.dart';
import '../../ui/features/script_editor/controller/script_editor_controller.dart';
import '../../ui/features/script_editor/controller/teleprompter_controller.dart';
import '../../ui/features/script_editor/views/teleprompter_view.dart';
import '../../ui/features/settings/controller/settings_controller.dart';
import '../../ui/features/settings/views/settings_view.dart';
import '../../ui/features/structures/controller/structure_ai_controller.dart';
import '../../ui/features/structures/controller/structures_controller.dart';
import '../../ui/features/structures/views/structures_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController());
        Get.lazyPut(() => AnalyticsController());
        Get.lazyPut(() => ProjectsController());
        Get.lazyPut(() => SettingsController());
        Get.lazyPut(() => SuggestionsController());
      }),
    ),
    GetPage(
      name: AppRoutes.projects,
      page: () => const ProjectsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProjectsController());
      }),
    ),
    GetPage(
      name: AppRoutes.projectDetail,
      page: () => const ProjectDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProjectDetailController());
        Get.lazyPut(() => ScriptEditorController());
        Get.lazyPut(() => AiController());
        Get.lazyPut(() => ChatController());
      }),
    ),
    GetPage(
      name: AppRoutes.teleprompter,
      page: () => const TeleprompterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TeleprompterController());
      }),
    ),
    GetPage(
      name: AppRoutes.structures,
      page: () => const StructuresView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => StructuresController());
        Get.lazyPut(() => StructureAiController());
      }),
    ),
    GetPage(
      name: AppRoutes.prompts,
      page: () => const PromptsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PromptsController());
      }),
    ),
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AnalyticsController());
      }),
    ),
    GetPage(
      name: AppRoutes.suggestions,
      page: () => const SuggestionsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SuggestionsController());
      }),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsController());
      }),
    ),
  ];
}
