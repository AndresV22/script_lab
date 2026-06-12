import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_shell.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controller/suggestions_controller.dart';
import '../enums/suggestion_type.dart';
import '../services/suggestions_service.dart';
import 'widgets/suggestion_card.dart';

class SuggestionsView extends GetView<SuggestionsController> {
  const SuggestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!controller.isUnlocked) {
      return AppShell(
        selected: AppSection.suggestions,
        child: const EmptyState(
          icon: Icons.lightbulb_outline,
          title: 'Sugerencias no disponibles',
          subtitle:
              'Escribe al menos un guion completo en un proyecto para que la IA '
              'pueda proponerte ideas de videos, estructuras y prompts.',
        ),
      );
    }

    return AppShell(
      selected: AppSection.suggestions,
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
            child: Text(
              'Sugerencias',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
            child: Text(
              'Ideas generadas por IA a partir de tus guiones. '
              'Se generan de 5 en 5 por categoría, o 3 de cada una con '
              '«Sugerir de todo».',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
            child: Obx(() {
              final generating = controller.isGenerating.value;
              SuggestionsService.to.suggestions.length;
              final hasSuggestions = SuggestionsService.to.suggestions.isNotEmpty;

              return Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: generating ? null : controller.generateAll,
                    icon: const Icon(Icons.layers_outlined, size: 18),
                    label: const Text('Sugerir de todo'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: generating || !hasSuggestions
                        ? null
                        : controller.clearAll,
                    icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                    label: const Text('Limpiar todo'),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Proyectos'),
                Tab(text: 'Estructuras'),
                Tab(text: 'Prompts'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _SuggestionsTab(type: SuggestionType.project),
                _SuggestionsTab(type: SuggestionType.structure),
                _SuggestionsTab(type: SuggestionType.prompt),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsTab extends GetView<SuggestionsController> {
  final SuggestionType type;

  const _SuggestionsTab({required this.type});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      SuggestionsService.to.suggestions.length;
      final items = controller.byType(type);
      final generating = controller.isGenerating.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
            child: Row(
              children: [
                if (items.isEmpty)
                  FilledButton.icon(
                    onPressed: generating ? null : () => controller.generateInitial(type),
                    icon: const Icon(Icons.auto_awesome, size: 17),
                    label: const Text('Generar sugerencias'),
                  )
                else ...[
                  OutlinedButton.icon(
                    onPressed: generating ? null : () => controller.addMore(type),
                    icon: const Icon(Icons.add, size: 17),
                    label: const Text('Añadir más sugerencias'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: generating ? null : () => controller.clearType(type),
                    icon: const Icon(Icons.delete_sweep_outlined, size: 17),
                    label: const Text('Limpiar'),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty && !generating
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(
                        'Pulsa "Generar sugerencias" para obtener 5 ideas de '
                        '${type.label.toLowerCase()} basadas en tu contenido.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      mainAxisExtent: 320,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        SuggestionCard(suggestion: items[index]),
                  ),
          ),
        ],
      );
    });
  }
}
