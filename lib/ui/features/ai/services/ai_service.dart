import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/services/settings_service.dart';
import '../../projects/models/project.dart';
import '../../script_editor/models/script_section.dart';

/// Construye los prompts con el contexto completo del proyecto,
/// las variables del canal y las muestras de estilo del creador.
abstract class AiService {
  static String buildSystemPrompt() {
    final channel = SettingsService.to.channel.value;
    final samples = SettingsService.to.styleSamples;
    final buffer = StringBuffer()
      ..writeln(
          'Eres un asistente experto en escritura de guiones para YouTube. '
          'Trabajas para un creador de contenido y conoces su canal a fondo. '
          'Responde siempre en español. Usa formato Markdown sencillo '
          '(negritas, listas, encabezados) cuando mejore la legibilidad; '
          'no uses tablas. Cuando se te pida devolver ÚNICAMENTE un texto '
          '(guion, sección, título, descripción), entrégalo sin adornos extra.');

    if (!channel.isEmpty) {
      buffer.writeln('\nInformación permanente del canal:');
      if (channel.channelName.isNotEmpty) {
        buffer.writeln('- Nombre del canal: ${channel.channelName}');
      }
      if (channel.greeting.isNotEmpty) {
        buffer.writeln('- Saludo habitual: ${channel.greeting}');
      }
      if (channel.audience.isNotEmpty) {
        buffer.writeln('- Público objetivo: ${channel.audience}');
      }
      if (channel.style.isNotEmpty) {
        buffer.writeln('- Estilo de escritura: ${channel.style}');
      }
      if (channel.avoid.isNotEmpty) {
        buffer.writeln('- Evitar: ${channel.avoid}');
      }
      if (channel.avgDuration.isNotEmpty) {
        buffer.writeln('- Duración promedio de los videos: '
            '${channel.avgDuration}');
      }
    }

    if (samples.isNotEmpty) {
      buffer.writeln(
          '\nEjemplos del estilo real del creador (extractos de videos '
          'anteriores). Imita su tono, ritmo y patrones de escritura:');
      for (final sample in samples.take(AppConstants.maxStyleSamples)) {
        buffer
          ..writeln('--- Extracto: ${sample.name} ---')
          ..writeln(sample.content.truncate(AppConstants.maxStyleSampleChars));
      }
    }
    return buffer.toString();
  }

  /// System prompt para el chat del proyecto: instrucciones generales,
  /// variables del canal, estilo y contexto fresco del proyecto.
  static String chatSystemPrompt(Project p) => '''
${buildSystemPrompt()}

${_projectContext(p)}

Estás conversando con el creador sobre este proyecto. Responde de forma
directa y útil; puedes proponer ideas, mejorar fragmentos o responder dudas
usando todo el contexto anterior.''';

  static String _projectContext(Project p, {bool includeScript = true}) {
    final buffer = StringBuffer()..writeln('Contexto del proyecto actual:');
    if (p.topic.isNotEmpty) buffer.writeln('- Tema del video: ${p.topic}');
    if (p.tentativeTitle.isNotEmpty) {
      buffer.writeln('- Título tentativo: ${p.tentativeTitle}');
    }
    if (p.description.isNotEmpty) {
      buffer.writeln('- Descripción actual: ${p.description}');
    }
    if (p.tags.isNotEmpty) buffer.writeln('- Etiquetas: ${p.tags.join(', ')}');
    final titles = p.orderedSections.map((s) => s.title).join(' → ');
    if (titles.isNotEmpty) buffer.writeln('- Estructura del guion: $titles');
    final described =
        p.orderedSections.where((s) => s.description.trim().isNotEmpty);
    if (described.isNotEmpty) {
      buffer.writeln('- Indicaciones del creador por sección:');
      for (final s in described) {
        buffer.writeln('  · ${s.title}: ${s.description.trim()}');
      }
    }
    if (includeScript && p.fullScriptText.trim().isNotEmpty) {
      buffer
        ..writeln('\nGuion actual completo:')
        ..writeln(p.fullScriptText);
    }
    return buffer.toString();
  }

  /// Bloque con indicaciones adicionales del creador (vacío si no hay).
  static String _extraBlock(String extra) => extra.trim().isEmpty
      ? ''
      : '\n\nIndicaciones adicionales del creador (respétalas):\n${extra.trim()}';

  // ----- Corrección -----

  static String correctionPrompt(Project p) => '''
${_projectContext(p)}

Corrige la ortografía, la gramática y la redacción del guion completo.
Mantén el estilo, el tono y la voz del creador. No agregues contenido nuevo ni elimines ideas.
Devuelve ÚNICAMENTE el guion corregido, conservando exactamente los encabezados de sección con el formato "## Nombre de la sección".''';

  static String sectionCorrectionPrompt(Project p, ScriptSection s) => '''
${_projectContext(p)}

Sección a corregir: "${s.title}"
${s.description.trim().isNotEmpty ? 'Indicaciones del creador para esta sección: ${s.description.trim()}\n' : ''}
Texto original de la sección:
${s.content}

Usa el guion completo solo como contexto, pero corrige ÚNICAMENTE esta sección:
ortografía, gramática y redacción. Mantén el estilo y la voz del creador.
No agregues ideas nuevas ni toques otras secciones.
Devuelve ÚNICAMENTE el texto corregido de la sección, sin encabezados ni comentarios.''';

  // ----- Análisis -----

  static String analysisPrompt(Project p) => '''
${_projectContext(p)}

Analiza el guion completo y entrega un informe breve y accionable con:
1. Contradicciones: afirmaciones que se contradicen entre secciones.
2. Repeticiones: ideas, frases o muletillas repetidas.
3. Secciones débiles: partes que pierden ritmo, aportan poco o necesitan más fuerza, con una sugerencia concreta para cada una.''';

  // ----- Sugerencias -----

  static String titlesPrompt(Project p, {String extra = ''}) => '''
${_projectContext(p)}

Propón 8 títulos alternativos con alto CTR para este video.
Deben ser claros, despertar curiosidad y evitar el clickbait engañoso.
Devuelve solo la lista, un título por línea, con guiones.${_extraBlock(extra)}''';

  static String tentativeTitlePrompt(Project p, {String extra = ''}) => '''
${_projectContext(p)}

Elige el mejor título tentativo para este video: claro, con buen CTR y sin clickbait engañoso.
Devuelve ÚNICAMENTE el título, sin comillas, numeración ni explicaciones.${_extraBlock(extra)}''';

  static String tagsPrompt(Project p, {String extra = ''}) => '''
${_projectContext(p)}

Genera entre 10 y 15 etiquetas relevantes para YouTube sobre este video.
Incluye términos amplios y específicos que ayuden al descubrimiento.
Devuelve solo la lista, una etiqueta por línea, con guiones. Sin hashtags.${_extraBlock(extra)}''';

  static String notesPrompt(Project p, {String extra = ''}) => '''
${_projectContext(p)}

Genera notas útiles para el creador mientras prepara el video:
ideas secundarias, referencias a mencionar, datos a verificar, ángulos alternativos y recordatorios de producción.
Usa viñetas con guiones, en español, de forma concisa y accionable.${_extraBlock(extra)}''';

  static String thumbnailsPrompt(Project p, {String extra = ''}) => '''
${_projectContext(p)}

Propón 5 ideas de miniatura para este video.
Para cada una describe: composición visual, texto en pantalla (máximo 4 palabras) y la emoción que transmite.${_extraBlock(extra)}''';

  static String hooksPrompt(Project p, {String extra = ''}) => '''
${_projectContext(p)}

Escribe 5 propuestas de hook inicial (primeros 15 segundos) más fuertes para este video.
Cada hook debe generar tensión o curiosidad inmediata. Devuelve la lista con guiones.${_extraBlock(extra)}''';

  static String descriptionPrompt(Project p, {String extra = ''}) => '''
${_projectContext(p)}

Escribe una descripción optimizada para YouTube de este video: 2 o 3 párrafos,
con lenguaje natural, palabras clave relevantes y una invitación a suscribirse al final.
Devuelve ÚNICAMENTE la descripción, sin títulos ni comentarios.${_extraBlock(extra)}''';

  // ----- Generación -----

  static String generateSectionPrompt(Project p, ScriptSection s) => '''
${_projectContext(p)}

Escribe el contenido de la sección "${s.title}" del guion.
${s.description.trim().isNotEmpty ? 'Indicaciones del creador para esta sección (respétalas): ${s.description.trim()}\n' : ''}Debe integrarse con naturalidad con el resto del guion, en el estilo del creador,
listo para ser narrado en voz alta.
Devuelve ÚNICAMENTE el texto de la sección, sin encabezados ni comentarios.''';

  static String generateFullPrompt(Project p) {
    final sectionList = p.orderedSections.isEmpty
        ? '## Hook inicial\n## Introducción\n## Desarrollo\n## Conclusión'
        : p.orderedSections
            .map((s) => s.description.trim().isEmpty
                ? '## ${s.title}'
                : '## ${s.title}\n(Indicaciones: ${s.description.trim()})')
            .join('\n');
    return '''
${_projectContext(p, includeScript: false)}

Escribe el guion completo del video, listo para ser narrado en voz alta,
siguiendo exactamente esta estructura de secciones:

$sectionList

Usa los encabezados tal cual, con el formato "## Nombre de la sección", y
escribe el contenido completo debajo de cada uno. Las líneas "(Indicaciones: …)"
son guía para ti: respétalas pero NO las incluyas en el guion.
No agregues comentarios fuera del guion.''';
  }

  static String customPrompt(Project p, String prompt) => '''
${_projectContext(p)}

Instrucción del creador:
$prompt''';

  /// Extrae etiquetas desde listas con guiones o texto separado por comas.
  static List<String> parseTags(String text) {
    final items = text.parsedListItems;
    if (items.isNotEmpty) return items;
    return cleanOutput(text)
        .split(RegExp(r'[,\n]'))
        .map((t) => t.trim().replaceAll(RegExp(r'^#'), ''))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// Obtiene un único título desde la respuesta del modelo.
  static String parseSingleTitle(String text) {
    final items = text.parsedListItems;
    if (items.isNotEmpty) return items.first;
    final line = cleanOutput(text).split('\n').first.trim();
    return line.replaceAll(RegExp(r'^["“]|["”]$'), '');
  }

  /// Limpia la salida del modelo: quita fences de código y razonamiento.
  static String cleanOutput(String raw) {
    var text = raw.trim();
    text = text.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '').trim();
    final fence = RegExp(r'^```[a-zA-Z]*\n([\s\S]*?)\n```$');
    final match = fence.firstMatch(text);
    final fenced = match?.group(1);
    if (fenced != null) text = fenced.trim();
    return text;
  }

  /// Divide un guion con encabezados "## Título" en pares título/contenido.
  static List<(String, String)> parseSections(String text) {
    final result = <(String, String)>[];
    String? currentTitle;
    final currentContent = StringBuffer();

    void flush() {
      final title = currentTitle;
      if (title != null) {
        result.add((title, currentContent.toString().trim()));
      }
      currentContent.clear();
    }

    for (final line in cleanOutput(text).split('\n')) {
      final heading = RegExp(r'^#{1,3}\s+(.*)$').firstMatch(line.trim());
      if (heading != null) {
        flush();
        currentTitle = heading.group(1)!.trim();
      } else if (currentTitle != null) {
        currentContent.writeln(line);
      }
    }
    flush();
    return result;
  }
}
