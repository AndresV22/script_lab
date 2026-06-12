abstract class AppConstants {
  static const appName = 'Script Lab';
  static const defaultOllamaUrl = 'http://localhost:11434';
  static const defaultWordsPerMinute = 140;

  // Nombres de boxes de Hive
  static const projectsBox = 'projects';
  static const structuresBox = 'structures';
  static const promptsBox = 'prompts';
  static const styleSamplesBox = 'style_samples';
  static const appBox = 'app';
  static const suggestionsBox = 'suggestions';
  static const projectSuggestionsBox = 'project_suggestions';

  // Claves dentro del box de app
  static const settingsKey = 'settings';
  static const channelKey = 'channel_variables';
  static const projectDefaultsKey = 'project_defaults';

  // Limites de contexto para la IA
  static const maxStyleSamples = 3;
  static const maxStyleSampleChars = 2500;
}
