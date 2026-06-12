import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../models/project.dart';
import '../services/project_service.dart';

/// Búsqueda global por título, etiquetas y contenido del guion.
class GlobalSearchDialog extends StatefulWidget {
  const GlobalSearchDialog({super.key});

  @override
  State<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<GlobalSearchDialog> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final results = ProjectService.to.search(query);
    return Dialog(
      alignment: const Alignment(0, -0.6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar por título, etiquetas o contenido…',
                  prefixIcon: Icon(Icons.search, size: 18),
                ),
                onChanged: (v) => setState(() => query = v),
              ),
            ),
            if (query.trim().isNotEmpty) const Divider(),
            Flexible(
              child: query.trim().isEmpty
                  ? const SizedBox.shrink()
                  : results.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Sin resultados para "$query"',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: results.length,
                          itemBuilder: (context, index) =>
                              _ResultTile(project: results[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final Project project;

  const _ResultTile({required this.project});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.description_outlined,
          size: 18, color: scheme.onSurfaceVariant),
      title: Text(
        project.displayTitle.isEmpty ? 'Sin título' : project.displayTitle,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: project.tags.isEmpty
          ? null
          : Text(
              project.tags.join(' · '),
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: project.status.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          project.status.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: project.status.color,
          ),
        ),
      ),
      onTap: () {
        Get.back();
        Get.toNamed(AppRoutes.projectDetailPath(project.id));
      },
    );
  }
}
