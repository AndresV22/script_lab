import 'package:get/get.dart';

import '../../../../core/services/storage_service.dart';
import '../models/prompt_item.dart';

class PromptService extends GetxService {
  static PromptService get to => Get.find();

  final prompts = <PromptItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _reload();
  }

  void _reload() {
    final list = StorageService.prompts.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    prompts.assignAll(list);
  }

  /// Recarga desde el almacenamiento (p. ej. tras restaurar un respaldo).
  void reload() => _reload();

  Future<void> save(PromptItem prompt) async {
    await StorageService.prompts.put(prompt.id, prompt);
    _reload();
  }

  Future<void> delete(String id) async {
    await StorageService.prompts.delete(id);
    _reload();
  }
}
