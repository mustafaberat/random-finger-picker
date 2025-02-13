import 'package:flutter/material.dart';
import '../animations/finger_tap_animation.dart';
import '../animations/winner_animation.dart';
import '../animations/selection_animation.dart';

class AnimationManager {
  final Map<int, AnimationController> fingerAnimationControllers = {};
  late final AnimationController selectionController;
  late final AnimationController winAnimationController;
  late final AnimationController speedController;
  bool _isWaitingForWinAnimation = false;

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

    speedController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 2000),
    );

    selectionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onSelectionComplete();
      }
    });

    // Create a curved animation for speed
    speedController.addListener(() {
      // Speed up in the first half, slow down in the second half
      if (speedController.value <= 0.5) {
        // Accelerate: 200ms -> 50ms interval
        selectionController.duration = Duration(milliseconds: (200 - (150 * (speedController.value * 2))).round());
      } else {
        // Decelerate: 50ms -> 300ms interval
        final slowDownValue = (speedController.value - 0.5) * 2;
        selectionController.duration = Duration(milliseconds: (50 + (250 * slowDownValue)).round());
      }
    });
  }

  void dispose() {
    selectionController.dispose();
    winAnimationController.dispose();
    speedController.dispose();
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
    // Reset all animations
    for (var controller in fingerAnimationControllers.values) {
      controller.value = 1.0;
    }
    
    selectionController.stop();
    speedController.stop();
    
    // Start the speed controller which will drive the selection speed
    speedController.forward(from: 0);
    _animateNextSelection();
  }

  void _animateNextSelection() {
    if (!selectionController.isAnimating) {
      selectionController.forward(from: 0).whenComplete(() {
        if (speedController.isAnimating) {
          _animateNextSelection();
        }
      });
    }
  }

  void startWinAnimation() {
    selectionController.stop();
    speedController.stop();
    winAnimationController.forward(from: 0);
  }

  void reset() {
    selectionController.stop();
    winAnimationController.stop();
    speedController.stop();
    selectionController.value = 0;
    winAnimationController.value = 0;
    speedController.value = 0;
  }

  Animation<double> getWinAnimation() {
    return winAnimationController.drive(
      CurveTween(curve: Curves.easeInOut),
    );
  }

  Animation<double> getSelectionAnimation() {
    return selectionController.drive(
      CurveTween(curve: Curves.easeInOut),
    );
  }
} 