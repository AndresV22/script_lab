import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/helpers/text_stats.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../ai/views/diff_review_view.dart';
import '../../projects/controller/project_detail_controller.dart';
import '../controller/script_editor_controller.dart';

/// Historial de versiones del guion: restaurar, comparar y eliminar.
class VersionsView extends StatelessWidget {
  const VersionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final detail = Get.find<ProjectDetailController>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      detail.revision.value;
      final versions = [...detail.project.versions]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (versions.isEmpty) {
        return const EmptyState(
          icon: Icons.history,
          title: 'Sin versiones guardadas',
          subtitle:
              'Guarda versiones importantes del guion desde la pestaña Guion\npara poder restaurarlas o compararlas más adelante.',
        );
      }
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: ListView.separated(
            padding: const EdgeInsets.all(28),
            itemCount: versions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final version = versions[index];
              final words = version.sections
                  .fold<int>(0, (acc, s) => acc + TextStats.words(s.content));
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  leading: Icon(Icons.history,
                      size: 20, color: scheme.onSurfaceVariant),
                  title: Text(version.label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${version.createdAt.shortDateTime} · ${version.sections.length} secciones · $words palabras',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => DiffReviewView.show(
                          title: 'Comparar con la versión actual',
                          original: version.fullText,
                          proposed: detail.project.fullScriptText,
                        ),
                        child: const Text('Comparar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final ok = await showConfirmDialog(
                            title: 'Restaurar versión',
                            message:
                                'El guion actual se guardará como una nueva versión y se restaurará "${version.label}".',
                            confirmLabel: 'Restaurar',
                            destructive: false,
                          );
                          if (!ok) return;
                          await detail.restoreVersion(version);
                          Get.find<ScriptEditorController>().sync();
                          Get.snackbar(
                              'Versiones', 'Versión restaurada correctamente',
                              snackPosition: SnackPosition.BOTTOM,
                              maxWidth: 360);
                        },
                        child: const Text('Restaurar'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        tooltip: 'Eliminar versión',
                        onPressed: () async {
                          final ok = await showConfirmDialog(
                            title: 'Eliminar versión',
                            message:
                                'Se eliminará la versión "${version.label}".',
                          );
                          if (ok) detail.deleteVersion(version);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
