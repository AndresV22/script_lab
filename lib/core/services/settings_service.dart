import 'package:get/get.dart';

import '../../ui/features/settings/models/app_settings.dart';
import '../../ui/features/settings/models/channel_variables.dart';
import '../../ui/features/settings/models/project_defaults.dart';
import '../../ui/features/settings/models/style_sample.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

/// Acceso reactivo a la configuración global y variables del canal.
class SettingsService extends GetxService {
  static SettingsService get to => Get.find();

  late final Rx<AppSettings> settings;
  late final Rx<ChannelVariables> channel;
  late final Rx<ProjectDefaults> projectDefaults;
  final styleSamples = <StyleSample>[].obs;

  @override
  void onInit() {
    super.onInit();
    final storedSettings =
        StorageService.app.get(AppConstants.settingsKey) as AppSettings?;
    final storedChannel =
        StorageService.app.get(AppConstants.channelKey) as ChannelVariables?;
    final storedDefaults = StorageService.app
        .get(AppConstants.projectDefaultsKey) as ProjectDefaults?;
    settings = (storedSettings ?? AppSettings()).obs;
    channel = (storedChannel ?? ChannelVariables()).obs;
    projectDefaults = (storedDefaults ?? ProjectDefaults()).obs;
    _loadSamples();
  }

  void _loadSamples() {
    final samples = StorageService.styleSamples.values.toList()
      ..sort((a, b) => b.importedAt.compareTo(a.importedAt));
    styleSamples.assignAll(samples);
  }

  Future<void> saveSettings() async {
    await StorageService.app.put(AppConstants.settingsKey, settings.value);
    settings.refresh();
  }

  Future<void> saveChannel() async {
    await StorageService.app.put(AppConstants.channelKey, channel.value);
    channel.refresh();
  }

  Future<void> saveProjectDefaults() async {
    await StorageService.app
        .put(AppConstants.projectDefaultsKey, projectDefaults.value);
    projectDefaults.refresh();
  }

  /// Recarga desde el almacenamiento (p. ej. tras restaurar un respaldo).
  void reloadFromStorage() {
    settings.value =
        (StorageService.app.get(AppConstants.settingsKey) as AppSettings?) ??
            AppSettings();
    channel.value = (StorageService.app.get(AppConstants.channelKey)
            as ChannelVariables?) ??
        ChannelVariables();
    projectDefaults.value = (StorageService.app
            .get(AppConstants.projectDefaultsKey) as ProjectDefaults?) ??
        ProjectDefaults();
    _loadSamples();
  }

  Future<void> addStyleSample(StyleSample sample) async {
    await StorageService.styleSamples.put(sample.id, sample);
    _loadSamples();
  }

  Future<void> deleteStyleSample(String id) async {
    await StorageService.styleSamples.delete(id);
    _loadSamples();
  }
}
