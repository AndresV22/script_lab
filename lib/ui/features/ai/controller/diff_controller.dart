import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:get/get.dart';

/// Calcula y gestiona las diferencias entre el texto original y la propuesta
/// de la IA, permitiendo aceptar o rechazar cambios individuales.
class DiffController extends GetxController {
  final String original;
  final String proposed;

  late final List<Diff> diffs;

  /// Índice del diff -> aceptado. Solo contiene diffs que no son "igual".
  final accepted = <int, bool>{}.obs;

  DiffController({required this.original, required this.proposed}) {
    final dmp = DiffMatchPatch();
    diffs = dmp.diff(original, proposed);
    dmp.diffCleanupSemantic(diffs);
    for (var i = 0; i < diffs.length; i++) {
      if (diffs[i].operation != DIFF_EQUAL) accepted[i] = true;
    }
  }

  bool get hasChanges => accepted.isNotEmpty;

  int get changeCount => accepted.length;

  int get acceptedCount => accepted.values.where((v) => v).length;

  void toggle(int index) {
    if (!accepted.containsKey(index)) return;
    accepted[index] = !accepted[index]!;
  }

  void acceptAll() => accepted.updateAll((key, value) => true);

  void rejectAll() => accepted.updateAll((key, value) => false);

  /// Texto resultante según los cambios aceptados.
  String get result {
    final buffer = StringBuffer();
    for (var i = 0; i < diffs.length; i++) {
      final diff = diffs[i];
      switch (diff.operation) {
        case DIFF_EQUAL:
          buffer.write(diff.text);
        case DIFF_INSERT:
          if (accepted[i] == true) buffer.write(diff.text);
        case DIFF_DELETE:
          if (accepted[i] != true) buffer.write(diff.text);
      }
    }
    return buffer.toString();
  }
}
