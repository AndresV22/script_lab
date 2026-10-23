/// Indicaciones y estructura elegidas para generar el guion completo.
class GenerateFullScriptRequest {
  /// Valor del menú cuando el guion debe seguir las secciones del proyecto.
  static const String projectSections = '__project_sections__';

  final String prompt;
  final String structureId;

  const GenerateFullScriptRequest({
    required this.prompt,
    required this.structureId,
  });

  bool get useProjectSections => structureId == projectSections;
}
