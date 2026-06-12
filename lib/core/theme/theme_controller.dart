import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/settings_service.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final mode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    mode.value = _fromName(SettingsService.to.settings.value.themeMode);
  }

  ThemeMode _fromName(String name) => switch (name) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setMode(ThemeMode newMode) async {
    mode.value = newMode;
    Get.changeThemeMode(newMode);
    SettingsService.to.settings.value.themeMode = newMode.name;
    await SettingsService.to.saveSettings();
  }

  /// Reaplica el modo guardado en ajustes (p. ej. tras restaurar un respaldo).
  void applyStoredMode() {
    final stored = _fromName(SettingsService.to.settings.value.themeMode);
    mode.value = stored;
    Get.changeThemeMode(stored);
  }
}
