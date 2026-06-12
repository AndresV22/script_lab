import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/settings_service.dart';
import '../../script_editor/models/script_section.dart';
import '../../structures/services/structure_service.dart';
import '../enums/project_status.dart';
import '../models/project.dart';
import '../services/project_service.dart';

class ProjectsController extends GetxController {
  final query = ''.obs;
  final statusFilter = Rxn<ProjectStatus>();

  List<Project> get filtered {
    final q = query.value.trim().toLowerCase();
    return ProjectService.to.projects.where((p) {
      if (statusFilter.value != null && p.status != statusFilter.value) {
        return false;
      }
      if (q.isEmpty) return true;
      return p.displayTitle.toLowerCase().contains(q) ||
          p.topic.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  Future<void> createProject(String topic) async {
    final defaults = SettingsService.to.projectDefaults.value;
    final project = Project(
      id: const Uuid().v4(),
      topic: topic.trim(),
      description: defaults.description,
      tags: [...defaults.tags],
      notes: defaults.notes,
    );

    if (defaults.structureId.isNotEmpty) {
      final structure = StructureService.to.structures
          .firstWhereOrNull((s) => s.id == defaults.structureId);
      if (structure != null) {
        project.structureId = structure.id;
        for (final (i, step) in structure.steps.indexed) {
          project.sections.add(ScriptSection(
            id: const Uuid().v4(),
            title: step.name,
            description: step.description,
            order: i,
          ));
        }
      }
    }

    await ProjectService.to.save(project, touch: false);
    Get.toNamed(AppRoutes.projectDetailPath(project.id));
  }

  Future<void> deleteProject(Project project) =>
      ProjectService.to.delete(project.id);

  Future<void> setStatus(Project project, ProjectStatus status) async {
    project.status = status;
    await ProjectService.to.save(project);
  }

  // ----- Vista -----

  String get viewMode => SettingsService.to.settings.value.projectsViewMode;

  String get cardSize => SettingsService.to.settings.value.cardSize;

  Future<void> setViewMode(String mode) async {
    SettingsService.to.settings.value.projectsViewMode = mode;
    await SettingsService.to.saveSettings();
  }

  Future<void> setCardSize(String size) async {
    SettingsService.to.settings.value.cardSize = size;
    await SettingsService.to.saveSettings();
  }
}
