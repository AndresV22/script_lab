import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../ui/features/projects/models/project.dart';
import 'download/download_io.dart'
    if (dart.library.js_interop) 'download/download_web.dart';

/// Exporta proyectos a TXT, Markdown, PDF y JSON.
class ExportService {
  ExportService._();

  static String _safeName(Project p) {
    final base = p.displayTitle.isEmpty ? 'guion' : p.displayTitle;
    return base
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9áéíóúñü ]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
  }

  static String toTxt(Project p) {
    final buffer = StringBuffer()
      ..writeln(p.displayTitle.toUpperCase())
      ..writeln();
    for (final section in p.orderedSections) {
      buffer
        ..writeln(section.title.toUpperCase())
        ..writeln()
        ..writeln(section.content)
        ..writeln();
    }
    return buffer.toString();
  }

  static String toMarkdown(Project p) {
    final buffer = StringBuffer()..writeln('# ${p.displayTitle}\n');
    if (p.description.isNotEmpty) {
      buffer.writeln('> ${p.description.replaceAll('\n', '\n> ')}\n');
    }
    if (p.tags.isNotEmpty) {
      buffer.writeln('Etiquetas: ${p.tags.map((t) => '`$t`').join(' ')}\n');
    }
    for (final section in p.orderedSections) {
      buffer
        ..writeln('## ${section.title}\n')
        ..writeln('${section.content}\n');
    }
    return buffer.toString();
  }

  static String toJson(Project p) =>
      const JsonEncoder.withIndent('  ').convert(p.toJson());

  static pw.ThemeData? _pdfTheme;

  /// Tema del PDF con fuente Unicode embebida: la Helvetica integrada del
  /// paquete `pdf` no cubre caracteres como guiones largos (—) o "…".
  static Future<pw.ThemeData> _loadPdfTheme() async {
    if (_pdfTheme != null) return _pdfTheme!;
    final regular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final bold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
    _pdfTheme = pw.ThemeData.withFont(
      base: regular,
      bold: bold,
      italic: regular,
      boldItalic: bold,
    );
    return _pdfTheme!;
  }

  static Future<List<int>> toPdf(Project p) async {
    final doc = pw.Document(theme: await _loadPdfTheme());
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (_) => [
          pw.Text(
            p.displayTitle,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          for (final section in p.orderedSections) ...[
            pw.Text(
              section.title,
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text(section.content,
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 3)),
            pw.SizedBox(height: 14),
          ],
        ],
      ),
    );
    return doc.save();
  }

  static Future<void> exportTxt(Project p) =>
      downloadFile('${_safeName(p)}.txt', utf8.encode(toTxt(p)), 'text/plain');

  static Future<void> exportMarkdown(Project p) => downloadFile(
      '${_safeName(p)}.md', utf8.encode(toMarkdown(p)), 'text/markdown');

  static Future<void> exportJson(Project p) => downloadFile(
      '${_safeName(p)}.json', utf8.encode(toJson(p)), 'application/json');

  static Future<void> exportPdf(Project p) async =>
      downloadFile('${_safeName(p)}.pdf', await toPdf(p), 'application/pdf');

  /// Descarga texto plano arbitrario (por ejemplo, estructuras en JSON).
  static Future<void> exportRaw(
          String filename, String content, String mime) =>
      downloadFile(filename, utf8.encode(content), mime);
}
