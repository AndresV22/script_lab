import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/prompt_item.dart';
import '../services/prompt_service.dart';

class PromptsController extends GetxController {
  static const presets = [
    (
      'Mejorar hook',
      'Redacción',
      'Reescribe el hook inicial del guion para que genere más tensión y '
          'curiosidad en los primeros 15 segundos. Propón 3 versiones y '
          'explica brevemente por qué cada una retiene mejor al espectador.'
    ),
    (
      'Detectar contradicciones',
      'Análisis',
      'Revisa el guion completo y lista todas las afirmaciones que se '
          'contradicen entre sí o datos inconsistentes entre secciones. '
          'Cita el texto exacto de cada contradicción.'
    ),
    (
      'Hacer más entretenido',
      'Redacción',
      'Reescribe el guion manteniendo toda la información, pero con un tono '
          'más entretenido: añade analogías, preguntas retóricas y momentos '
          'de humor sutil acordes al estilo del canal.'
    ),
    (
      'Títulos con alto CTR',
      'Títulos',
      'Genera 10 títulos con alto CTR para este video. Combina fórmulas '
          'probadas: curiosidad, números, contraste y beneficio claro. '
          'Evita el clickbait engañoso.'
    ),
    (
      'Acortar el guion',
      'Edición',
      'Reduce el guion en un 30% sin perder las ideas principales. Elimina '
          'redundancias y rodeos, y prioriza frases cortas y directas que '
          'mantengan el ritmo.'
    ),
  ];

  List<PromptItem> get prompts => PromptService.to.prompts;

  Future<void> save(PromptItem prompt) => PromptService.to.save(prompt);

  Future<void> delete(PromptItem prompt) =>
      PromptService.to.delete(prompt.id);

  /// Inserta los prompts de ejemplo que aún no existan (por nombre).
  Future<void> addPresets() async {
    final existing =
        prompts.map((p) => p.name.trim().toLowerCase()).toSet();
    var added = 0;
    for (final (name, category, content) in presets) {
      if (existing.contains(name.toLowerCase())) continue;
      await PromptService.to.save(PromptItem(
        id: const Uuid().v4(),
        name: name,
        category: category,
        content: content,
      ));
      added++;
    }
    Get.snackbar(
      'Prompts',
      added > 0
          ? 'Se añadieron $added prompts de ejemplo.'
          : 'Los prompts de ejemplo ya estaban en tu biblioteca.',
      snackPosition: SnackPosition.BOTTOM,
      maxWidth: 380,
    );
  }
}
