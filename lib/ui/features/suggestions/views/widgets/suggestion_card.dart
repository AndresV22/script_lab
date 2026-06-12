import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../structures/services/structure_service.dart';
import '../../controller/suggestions_controller.dart';
import '../../enums/suggestion_type.dart';
import '../../models/ai_suggestion.dart';

class SuggestionCard extends GetView<SuggestionsController> {
  final AiSuggestion suggestion;
  final bool compact;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final type = suggestion.type;
    final structureName = suggestion.structureId.isEmpty
        ? null
        : StructureService.to.structures
            .firstWhereOrNull((s) => s.id == suggestion.structureId)
            ?.name;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon, size: 13, color: type.color),
                      const SizedBox(width: 5),
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: type.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Obx(() => IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Descartar',
                      visualDensity: VisualDensity.compact,
                      onPressed: controller.isGenerating.value
                          ? null
                          : () => controller.dismiss(suggestion),
                    )),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              suggestion.displayTitle.isEmpty
                  ? 'Sin título'
                  : suggestion.displayTitle,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (suggestion.displaySubtitle.isNotEmpty &&
                suggestion.displaySubtitle != suggestion.displayTitle) ...[
              const SizedBox(height: 4),
              Text(
                suggestion.displaySubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: _Body(
                  suggestion: suggestion,
                  structureName: structureName,
                  compact: compact,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => FilledButton(
                  onPressed: controller.isGenerating.value
                      ? null
                      : () => _apply(),
                  child: Text(_applyLabel(type)),
                )),
          ],
        ),
      ),
    );
  }

  String _applyLabel(SuggestionType type) => switch (type) {
        SuggestionType.project => 'Crear proyecto',
        SuggestionType.structure => 'Crear estructura',
        SuggestionType.prompt => 'Guardar prompt',
      };

  void _apply() => switch (suggestion.type) {
        SuggestionType.project => controller.applyProject(suggestion),
        SuggestionType.structure => controller.applyStructure(suggestion),
        SuggestionType.prompt => controller.applyPrompt(suggestion),
      };
}

class _Body extends StatelessWidget {
  final AiSuggestion suggestion;
  final String? structureName;
  final bool compact;

  const _Body({
    required this.suggestion,
    this.structureName,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return switch (suggestion.type) {
      SuggestionType.project => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (suggestion.description.isNotEmpty)
              Text(
                suggestion.description,
                maxLines: compact ? 3 : 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, height: 1.45),
              ),
            if (suggestion.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in suggestion.tags.take(compact ? 4 : 6))
                    Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
            if (structureName != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.account_tree_outlined,
                      size: 14, color: scheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      structureName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      SuggestionType.structure => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, step) in suggestion.steps.indexed.take(compact ? 4 : 8))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${i + 1}. ${step.name}',
                  style: const TextStyle(fontSize: 12.5),
                ),
              ),
            if (suggestion.steps.length > (compact ? 4 : 8))
              Text(
                '+ ${suggestion.steps.length - (compact ? 4 : 8)} más…',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
          ],
        ),
      SuggestionType.prompt => Text(
          suggestion.promptContent,
          maxLines: compact ? 4 : 6,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12.5, height: 1.45),
        ),
    };
  }
}
