import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';
import '../components/finger_circle.dart';

class FingerTapAnimation {
  static const Duration duration = GameScreen.kTapDuration;

  static Widget build({
    required Color color,
    required double tapProgress,
    required bool isSelecting,
    required bool isWinAnimationPlaying,
    required int fingerNumber,
  }) {
    // Border opacity with smooth fade in/out
    final borderProgress = tapProgress.clamp(0.0, 1.0);
    final borderOpacity = (Curves.easeInOut.transform(borderProgress) * GameScreen.kBorderOpacity)
        .clamp(0.0, GameScreen.kBorderOpacity);

    return FingerCircle(
      color: color,
      fingerNumber: fingerNumber,
      borderOpacity: borderOpacity,
      tapProgress: tapProgress,
    );
  }
}

