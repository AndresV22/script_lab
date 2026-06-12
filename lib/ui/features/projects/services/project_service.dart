import 'package:get/get.dart';

import '../../../../core/services/storage_service.dart';
import '../models/project.dart';

class ProjectService extends GetxService {
  static ProjectService get to => Get.find();

  /// Lista reactiva ordenada por última modificación.
  final projects = <Project>[].obs;

  @override
  void onInit() {
    super.onInit();
    _reload();
  }

  void _reload() {
    final list = StorageService.projects.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    projects.assignAll(list);
  }

  /// Recarga desde el almacenamiento (p. ej. tras restaurar un respaldo).
  void reload() => _reload();

  Project? byId(String id) => StorageService.projects.get(id);

  Future<void> save(Project project, {bool touch = true}) async {
    if (touch) project.updatedAt = DateTime.now();
    await StorageService.projects.put(project.id, project);
    _reload();
  }

  Future<void> delete(String id) async {
    await StorageService.projects.delete(id);
    _reload();
  }

  /// Búsqueda global por título, tema, etiquetas y contenido del guion.
  List<Project> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return projects.where((p) {
      if (p.tentativeTitle.toLowerCase().contains(q)) return true;
      if (p.topic.toLowerCase().contains(q)) return true;
      if (p.altTitles.any((t) => t.toLowerCase().contains(q))) return true;
      if (p.tags.any((t) => t.toLowerCase().contains(q))) return true;
      if (p.sections.any((s) =>
          s.title.toLowerCase().contains(q) ||
          s.content.toLowerCase().contains(q))) {
        return true;
      }
      return false;
    }).toList();
  }
}
