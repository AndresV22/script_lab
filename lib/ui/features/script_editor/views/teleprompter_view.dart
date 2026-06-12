import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/teleprompter_controller.dart';

/// Modo teleprompter a pantalla completa para leer el guion al grabar.
class TeleprompterView extends GetView<TeleprompterController> {
  const TeleprompterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.loaded.value) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.space):
              controller.togglePlay,
          const SingleActivator(LogicalKeyboardKey.escape): Get.back,
          const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
              controller.changeSpeed(controller.speed.value + 10),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
              controller.changeSpeed(controller.speed.value - 10),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: MouseRegion(
              onHover: (_) => controller.showControls(),
              child: const Stack(
                children: [
                  Positioned.fill(child: _ScrollingScript()),
                  // Anclada al borde inferior; solo ocupa su altura intrínseca.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: Center(child: _ControlsBar()),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ScrollingScript extends StatelessWidget {
  const _ScrollingScript();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeleprompterController>();
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final sections = controller.project.orderedSections;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification &&
            notification.dragDetails != null) {
          controller.onUserScroll();
        }
        if (notification is UserScrollNotification &&
            notification.direction != ScrollDirection.idle) {
          controller.onUserScroll();
        }
        return false;
      },
      child: Obx(() {
        final size = controller.fontSize.value;
        return SingleChildScrollView(
          controller: controller.scrollController,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // El texto empieza bajo y termina fuera de pantalla.
                    SizedBox(height: viewportHeight * 0.45),
                    for (final section in sections) ...[
                      Text(
                        section.title.toUpperCase(),
                        style: TextStyle(
                          fontSize: (size * 0.45).clamp(13.0, 26.0),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        section.content.trim(),
                        style: TextStyle(
                          fontSize: size,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size * 1.6),
                    ],
                    SizedBox(height: viewportHeight * 0.55),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeleprompterController>();
    return Obx(() {
      final visible = controller.controlsVisible.value;
      return IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xE61C1C1F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Salir (Esc)',
                  visualDensity: VisualDensity.compact,
                  iconSize: 19,
                  onPressed: Get.back,
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
                IconButton(
                  tooltip: 'Reiniciar',
                  visualDensity: VisualDensity.compact,
                  iconSize: 19,
                  onPressed: controller.restart,
                  icon: const Icon(Icons.replay, color: Colors.white70),
                ),
                const SizedBox(width: 2),
                Obx(() => IconButton.filled(
                      tooltip: controller.playing.value
                          ? 'Pausar (Espacio)'
                          : 'Reproducir (Espacio)',
                      visualDensity: VisualDensity.compact,
                      iconSize: 22,
                      onPressed: controller.togglePlay,
                      icon: Icon(controller.playing.value
                          ? Icons.pause
                          : Icons.play_arrow),
                    )),
                const SizedBox(width: 10),
                _SliderControl(
                  icon: Icons.speed,
                  tooltip: 'Velocidad (↑/↓)',
                  min: 10,
                  max: 300,
                  value: controller.speed,
                  onChanged: controller.changeSpeed,
                  labelBuilder: (v) => '${v.round()} px/s',
                ),
                const SizedBox(width: 8),
                _SliderControl(
                  icon: Icons.format_size,
                  tooltip: 'Tamaño de fuente',
                  min: 18,
                  max: 64,
                  value: controller.fontSize,
                  onChanged: controller.changeFontSize,
                  labelBuilder: (v) => '${v.round()} pt',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _SliderControl extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final double min;
  final double max;
  final RxDouble value;
  final ValueChanged<double> onChanged;
  final String Function(double) labelBuilder;

  const _SliderControl({
    required this.icon,
    required this.tooltip,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white54),
          SizedBox(
            width: 120,
            height: 28,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Obx(() => Slider(
                    value: value.value.clamp(min, max),
                    min: min,
                    max: max,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    onChanged: onChanged,
                  )),
            ),
          ),
          SizedBox(
            width: 50,
            child: Obx(() => Text(
                  labelBuilder(value.value),
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                )),
          ),
        ],
      ),
    );
  }
}
