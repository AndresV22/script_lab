enum AiTask {
  correction,
  sectionCorrection,
  analysis,
  titles,
  tentativeTitle,
  thumbnails,
  hooks,
  description,
  tags,
  notes,
  generateSection,
  generateFull,
  custom;

  String get label => switch (this) {
        AiTask.correction => 'Corrección del guion',
        AiTask.sectionCorrection => 'Corrección de sección',
        AiTask.analysis => 'Análisis del guion',
        AiTask.titles => 'Alternativas de título',
        AiTask.tentativeTitle => 'Título tentativo',
        AiTask.thumbnails => 'Ideas de miniatura',
        AiTask.hooks => 'Hooks más fuertes',
        AiTask.description => 'Descripción del video',
        AiTask.tags => 'Etiquetas del video',
        AiTask.notes => 'Notas del proyecto',
        AiTask.generateSection => 'Generación de sección',
        AiTask.generateFull => 'Generación de guion completo',
        AiTask.custom => 'Prompt personalizado',
      };
}
