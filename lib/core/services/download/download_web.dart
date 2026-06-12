import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Descarga un archivo en el navegador mediante un Blob temporal.
Future<void> downloadFile(String filename, List<int> bytes, String mime) async {
  final blob = web.Blob(
    [Uint8List.fromList(bytes).toJS].toJS,
    web.BlobPropertyBag(type: mime),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
