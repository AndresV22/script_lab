import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/confirm_dialog.dart';
import '../../controller/projects_controller.dart';
import '../../models/project.dart';

/// Menú de acciones del proyecto (eliminar).
class ProjectMenu extends StatelessWidget {
  final Project project;

  const ProjectMenu({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = Get.find<ProjectsController>();
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, size: 18, color: scheme.onSurfaceVariant),
      onSelected: (value) async {
        if (value == 'delete') {
          final ok = await showConfirmDialog(
            title: 'Eliminar proyecto',
            message:
                'Se eliminará "${project.displayTitle}" y todo su contenido. Esta acción no se puede deshacer.',
          );
          if (ok) controller.deleteProject(project);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'delete',
          child: Text('Eliminar'),
        ),
      ],
    );
  }
}
