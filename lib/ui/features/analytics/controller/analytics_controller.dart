import 'package:get/get.dart';

import '../../../../core/helpers/text_stats.dart';
import '../../../../core/services/settings_service.dart';
import '../../projects/enums/project_status.dart';
import '../../projects/models/project.dart';
import '../../projects/services/project_service.dart';

class AnalyticsController extends GetxController {
  List<Project> get projects => ProjectService.to.projects;

  int get totalProjects => projects.length;

  int get totalWords => projects.fold(
      0, (acc, p) => acc + TextStats.words(p.fullScriptText));

  int get totalSections =>
      projects.fold(0, (acc, p) => acc + p.sections.length);

  Duration get totalNarration => TextStats.narrationTime(
      totalWords, SettingsService.to.settings.value.wordsPerMinute);

  Map<ProjectStatus, int> get byStatus {
    final map = <ProjectStatus, int>{};
    for (final status in ProjectStatus.values) {
      final count = projects.where((p) => p.status == status).length;
      if (count > 0) map[status] = count;
    }
    return map;
  }
}
