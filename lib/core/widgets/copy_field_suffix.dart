import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Botón para copiar al portapapeles.
class CopyFieldSuffix extends StatelessWidget {
  final String Function() getText;
  final String tooltip;
  final String snackbarMessage;

  const CopyFieldSuffix({
    super.key,
    required this.getText,
    required this.tooltip,
    required this.snackbarMessage,
  });

  Future<void> _copy() async {
    final text = getText().trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Copiar',
        'No hay nada que copiar.',
        snackPosition: SnackPosition.BOTTOM,
        maxWidth: 360,
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copiar',
      snackbarMessage,
      snackPosition: SnackPosition.BOTTOM,
      maxWidth: 360,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy_outlined, size: 18),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: _copy,
    );
  }
}

/// [TextField] con botón de copiar fijado en la esquina superior derecha.
class TextFieldWithCopy extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration? decoration;
  final int? minLines;
  final int? maxLines;
  final String Function() getCopyText;
  final String copyTooltip;
  final String copySnackbarMessage;
  final List<Widget>? topRightActions;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const TextFieldWithCopy({
    super.key,
    required this.controller,
    required this.getCopyText,
    required this.copyTooltip,
    required this.copySnackbarMessage,
    this.decoration,
    this.minLines,
    this.maxLines,
    this.topRightActions,
    this.onChanged,
    this.onSubmitted,
  });

  static const _copyInset = 40.0;

  @override
  Widget build(BuildContext context) {
    final multiline = (minLines ?? 1) > 1;
    final actionCount = 1 + (topRightActions?.length ?? 0);
    final rightInset = _copyInset * actionCount;

    final base = decoration ?? const InputDecoration();
    final fieldDecoration = base.copyWith(
      contentPadding: _contentPadding(base.contentPadding, multiline, rightInset),
    );

    final copyButton = CopyFieldSuffix(
      getText: getCopyText,
      tooltip: copyTooltip,
      snackbarMessage: copySnackbarMessage,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          decoration: fieldDecoration,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
        Positioned(
          top: 2,
          right: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              copyButton,
              ...?topRightActions,
            ],
          ),
        ),
      ],
    );
  }

  EdgeInsetsGeometry _contentPadding(
    EdgeInsetsGeometry? base,
    bool multiline,
    double rightInset,
  ) {
    if (base is EdgeInsets) {
      return base.copyWith(right: rightInset);
    }
    return EdgeInsets.fromLTRB(12, multiline ? 12 : 0, rightInset, multiline ? 12 : 0);
  }
}

/// Coloca un botón de copiar en la esquina superior derecha de [child].
class CopyFieldOverlay extends StatelessWidget {
  final Widget child;
  final CopyFieldSuffix copyButton;
  final List<Widget>? topRightActions;

  const CopyFieldOverlay({
    super.key,
    required this.child,
    required this.copyButton,
    this.topRightActions,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: 2,
          right: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              copyButton,
              ...?topRightActions,
            ],
          ),
        ),
      ],
    );
  }
}
