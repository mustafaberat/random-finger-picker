import 'package:flutter/material.dart';
import '../animations/finger_tap_animation.dart';
import '../animations/winner_animation.dart';
import '../animations/selection_animation.dart';

class AnimationManager {
  final Map<int, AnimationController> fingerAnimationControllers = {};
  late final AnimationController selectionController;
  late final AnimationController winAnimationController;
  late final AnimationController pulseController;

  final TickerProvider vsync;
  final VoidCallback onSelectionComplete;

  AnimationManager({
    required this.vsync,
    required this.onSelectionComplete,
  }) {
    _initializeControllers();
  }

  void _initializeControllers() {
    selectionController = AnimationController(
      vsync: vsync,
      duration: SelectionAnimation.duration,
    );

    winAnimationController = AnimationController(
      vsync: vsync,
      duration: WinnerAnimation.duration,
    );

    pulseController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    selectionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onSelectionComplete();
      }
    });
  }

  void dispose() {
    selectionController.dispose();
    winAnimationController.dispose();
    pulseController.dispose();
    for (var controller in fingerAnimationControllers.values) {
      controller.dispose();
    }
  }

  void addFingerAnimation(int fingerKey) {
    // Stop and remove any existing animation for this finger
    fingerAnimationControllers[fingerKey]?.stop();
    fingerAnimationControllers[fingerKey]?.dispose();
    
    final controller = AnimationController(
      vsync: vsync,
      duration: FingerTapAnimation.duration,
    );
    
    fingerAnimationControllers[fingerKey] = controller;
    controller.forward();
  }

  void removeFingerAnimation(int fingerKey) {
    final controller = fingerAnimationControllers[fingerKey];
    if (controller != null) {
      controller.stop();
      controller.dispose();
      fingerAnimationControllers.remove(fingerKey);
    }
  }

  void startSelectionAnimation() {
    // Ensure all finger animations are in a stable state
    for (var controller in fingerAnimationControllers.values) {
      controller.stop();
      controller.value = 1.0;
    }
    
    selectionController
      ..stop()
      ..reset()
      ..forward();
  }

  void startWinAnimation() {
    selectionController.stop();
    selectionController.value = 0.0;
    winAnimationController.forward(from: 0);
  }

  void reset() {
    selectionController.stop();
    selectionController.value = 0.0;
    winAnimationController.stop();
    winAnimationController.value = 0.0;
  }

  Animation<double> getWinAnimation() {
    return winAnimationController.drive(
      CurveTween(curve: Curves.easeInOut),
    );
  }

  Animation<double> getPulseAnimation() {
    return pulseController.drive(
      CurveTween(curve: Curves.easeInOut),
    );
  }
} 