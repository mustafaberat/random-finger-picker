import 'package:flutter/material.dart';
import '../animations/finger_tap_animation.dart';
import '../animations/winner_animation.dart';
import '../animations/selection_animation.dart';
import '../screens/game_screen.dart';
import 'dart:math';

class AnimationManager {
  final Map<int, AnimationController> fingerAnimationControllers = {};
  late final AnimationController selectionController;
  late final AnimationController winAnimationController;
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
      duration: Duration(milliseconds: 150), // Sabit, hızlı bir süre
    );

    winAnimationController = AnimationController(
      vsync: vsync,
      duration: WinnerAnimation.duration,
    );

    selectionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animasyon tamamlandığında tekrar çağrılmaya devam edecek
        // Bu _animateNextSelection içinde handling edilecek
        if (GameScreen.kDebugMode) {
          print("👉 Selection animation cycle completed");
        }
      }
    });
  }

  void dispose() {
    selectionController.dispose();
    winAnimationController.dispose();
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

    // Kesintisiz seleksiyon için timer kuralım
    if (GameScreen.kDebugMode) {
      print("💫 Starting continuous selection animation");
    }

    // Seçim animasyonunu sürekli çalıştır
    _animateNextSelection();
  }

  void _animateNextSelection() {
    if (SelectionAnimation.isAnimationCompleted) {
      if (GameScreen.kDebugMode) {
        print("✅ AnimationManager: Animation fully completed, calling onSelectionComplete");
      }
      onSelectionComplete();
      return;
    }

    // Forward hareketi tamamlandığında, tekrar çağır
    selectionController.forward(from: 0).whenComplete(() {
      // Seçim animasyonu tamamlanmadığı sürece devam et
      if (!SelectionAnimation.isAnimationCompleted) {
        _animateNextSelection();
      } else {
        if (GameScreen.kDebugMode) {
          print("✅ AnimationManager: Animation fully completed (post-cycle), calling onSelectionComplete");
        }
        onSelectionComplete();
      }
    });
  }

  void startWinAnimation() {
    selectionController.stop();
    winAnimationController.forward(from: 0);
  }

  void reset() {
    selectionController.stop();
    winAnimationController.stop();
    selectionController.value = 0;
    winAnimationController.value = 0;

    for (var controller in fingerAnimationControllers.values) {
      controller.dispose();
    }
    fingerAnimationControllers.clear();
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
