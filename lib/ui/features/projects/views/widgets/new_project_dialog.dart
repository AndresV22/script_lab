import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/projects_controller.dart';

void showNewProjectDialog() {
  final controller = Get.find<ProjectsController>();
  final topicCtrl = TextEditingController();
  Get.dialog(
    AlertDialog(
      title: const Text('Nuevo proyecto'),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: topicCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '¿De qué tratará el video?',
            labelText: 'Tema del video',
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              Get.back();
              controller.createProject(v);
            }
          },
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (topicCtrl.text.trim().isEmpty) return;
            Get.back();
            controller.createProject(topicCtrl.text);
          },
          child: const Text('Crear'),
        ),
      ],
    ),
  );
}
