import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../projects/models/project.dart';
import '../../projects/services/project_service.dart';

/// Controla el auto-scroll y los ajustes del modo teleprompter.
class TeleprompterController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final Project project;
  final loaded = false.obs;

  final scrollController = ScrollController();
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  /// Evita que el scroll programático se interprete como scroll manual.
  bool _autoScrolling = false;

  final playing = false.obs;

  /// Velocidad del auto-scroll en píxeles por segundo.
  final speed = 60.0.obs;
  final fontSize = 32.0.obs;

  final controlsVisible = true.obs;
  Timer? _hideTimer;

  @override
  void onInit() {
    super.onInit();
    final id = Get.parameters['id'] ?? '';
    final found = ProjectService.to.byId(id);
    if (found == null) {
      Get.offAllNamed('/projects');
      return;
    }
    project = found;
    _ticker = createTicker(_onTick);
    loaded.value = true;
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (!scrollController.hasClients) return;

    final max = scrollController.position.maxScrollExtent;
    final next = scrollController.offset + speed.value * dt;
    _autoScrolling = true;
    scrollController.jumpTo(next.clamp(0.0, max));
    _autoScrolling = false;
    if (next >= max) pause();
  }

  void togglePlay() => playing.value ? pause() : play();

  void play() {
    if (playing.value || !loaded.value) return;
    playing.value = true;
    _lastElapsed = Duration.zero;
    _ticker.start();
    _scheduleHideControls();
  }

  void pause() {
    if (!playing.value) return;
    playing.value = false;
    _ticker.stop();
    showControls();
  }

  void restart() {
    pause();
    if (scrollController.hasClients) scrollController.jumpTo(0);
  }

  void changeSpeed(double value) => speed.value = value.clamp(10, 300);

  void changeFontSize(double value) => fontSize.value = value.clamp(18, 64);

  /// Pausa si el usuario hace scroll manual (rueda o arrastre).
  void onUserScroll() {
    if (!_autoScrolling && playing.value) pause();
  }

  /// Muestra los controles; se auto-ocultan al reproducir.
  void showControls() {
    controlsVisible.value = true;
    _scheduleHideControls();
  }

  void _scheduleHideControls() {
    _hideTimer?.cancel();
    if (!playing.value) return;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (playing.value) controlsVisible.value = false;
    });
  }

  @override
  void onClose() {
    _hideTimer?.cancel();
    if (loaded.value) _ticker.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
