import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String confirmLabel = 'Eliminar',
  bool destructive = true,
}) async {
  final result = await Get.dialog<bool>(
    Builder(builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            onPressed: () => Get.back(result: true),
            child: Text(confirmLabel),
          ),
        ],
      );
    }),
  );
  return result ?? false;
}
