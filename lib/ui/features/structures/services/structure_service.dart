import 'package:get/get.dart';

import '../../../../core/services/storage_service.dart';
import '../models/structure.dart';

class StructureService extends GetxService {
  static StructureService get to => Get.find();

  final structures = <Structure>[].obs;

  @override
  void onInit() {
    super.onInit();
    _reload();
  }

  void _reload() {
    final list = StorageService.structures.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    structures.assignAll(list);
  }

  /// Recarga desde el almacenamiento (p. ej. tras restaurar un respaldo).
  void reload() => _reload();

  Future<void> save(Structure structure) async {
    await StorageService.structures.put(structure.id, structure);
    _reload();
  }

  Future<void> delete(String id) async {
    await StorageService.structures.delete(id);
    _reload();
  }
}
