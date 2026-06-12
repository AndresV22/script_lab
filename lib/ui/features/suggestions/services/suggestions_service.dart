import 'package:get/get.dart';

import '../../../../core/services/storage_service.dart';
import '../enums/suggestion_type.dart';
import '../models/ai_suggestion.dart';

class SuggestionsService extends GetxService {
  static SuggestionsService get to => Get.find();

  final suggestions = <AiSuggestion>[].obs;

  @override
  void onInit() {
    super.onInit();
    _reload();
  }

  void _reload() {
    final list = StorageService.suggestions.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    suggestions.assignAll(list);
  }

  void reload() => _reload();

  List<AiSuggestion> byType(SuggestionType type) =>
      suggestions.where((s) => s.type == type).toList();

  List<AiSuggestion> get pending => suggestions;

  Future<void> saveAll(List<AiSuggestion> items) async {
    for (final item in items) {
      await StorageService.suggestions.put(item.id, item);
    }
    _reload();
  }

  Future<void> delete(String id) async {
    await StorageService.suggestions.delete(id);
    _reload();
  }

  Future<void> clearType(SuggestionType type) async {
    final ids = suggestions.where((s) => s.type == type).map((s) => s.id);
    for (final id in ids) {
      await StorageService.suggestions.delete(id);
    }
    _reload();
  }

  Future<void> clearAll() async {
    for (final id in suggestions.map((s) => s.id)) {
      await StorageService.suggestions.delete(id);
    }
    _reload();
  }
}
