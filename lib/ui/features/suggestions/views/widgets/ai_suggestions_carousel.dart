import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../controller/suggestions_controller.dart';
import '../../services/suggestions_service.dart';
import 'suggestion_card.dart';

/// Carrusel de sugerencias de IA pendientes en el dashboard.
class AiSuggestionsCarousel extends GetView<SuggestionsController> {
  const AiSuggestionsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    if (!controller.isUnlocked) return const SizedBox.shrink();

    return Obx(() {
      SuggestionsService.to.suggestions.length;
      final items = controller.dashboardPreview;
      final generating = controller.isGenerating.value;
      final scheme = Theme.of(context).colorScheme;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ideas de la IA',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (items.isNotEmpty)
                TextButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.suggestions),
                  child: const Text('Ver todas'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Material(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aún no hay sugerencias',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'La IA puede proponerte ideas de proyectos, estructuras y '
                      'prompts basadas en tus guiones.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: generating ? null : controller.generateAll,
                      icon: generating
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: scheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        generating ? 'Generando…' : 'Generar sugerencias',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) => SizedBox(
                  width: 300,
                  child: SuggestionCard(
                    suggestion: items[index],
                    compact: true,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
