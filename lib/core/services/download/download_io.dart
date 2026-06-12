import 'dart:io';

Future<void> downloadFile(String filename, List<int> bytes, String mime) async {
  final file = File('${Directory.systemTemp.path}/$filename');
  await file.writeAsBytes(bytes);
}
