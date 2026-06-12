import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/theme_controller.dart';

void showThemePickerDialog() {
  final theme = ThemeController.to;
  Get.dialog(
    AlertDialog(
      title: const Text('Tema de la aplicación'),
      content: Obx(
        () => SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('Sistema'),
              icon: Icon(Icons.brightness_auto_outlined, size: 16),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Claro'),
              icon: Icon(Icons.light_mode_outlined, size: 16),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Oscuro'),
              icon: Icon(Icons.dark_mode_outlined, size: 16),
            ),
          ],
          selected: {theme.mode.value},
          onSelectionChanged: (selection) => theme.setMode(selection.first),
        ),
      ),
      actions: [
        FilledButton(onPressed: Get.back, child: const Text('Listo')),
      ],
    ),
  );
}
