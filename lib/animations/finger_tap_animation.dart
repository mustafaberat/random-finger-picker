import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class FingerTapAnimation {
  static const Duration duration = GameScreen.kTapDuration;

  static Widget build({
    required Color color,
    required double scale,
    required double tapProgress,
    required bool isSelecting,
    required bool isWinAnimationPlaying,
  }) {
    // Two-phase animation: expand then shrink
    final maxScale = GameScreen.kMaxScale;
    final finalRestScale = GameScreen.kFinalScale;
    
    // Ensure tapProgress is within valid range
    final clampedProgress = tapProgress.clamp(0.0, 1.0);
    
    // Calculate scale based on progress
    final double currentScale;
    if (clampedProgress < 0.7) {
      // First phase: Expand (0-70% of animation)
      final expandProgress = (clampedProgress / 0.7).clamp(0.0, 1.0);
      currentScale = 1.0 + ((maxScale - 1.0) * Curves.easeOut.transform(expandProgress));
    } else {
      // Second phase: Shrink (70-100% of animation)
      final shrinkProgress = ((clampedProgress - 0.7) / 0.3).clamp(0.0, 1.0);
      currentScale = maxScale - ((maxScale - finalRestScale) * Curves.easeOut.transform(shrinkProgress));
    }

    // Border opacity with smooth fade in
    final borderProgress = clampedProgress.clamp(0.0, 1.0);
    final borderOpacity = (Curves.easeOut.transform(borderProgress) * GameScreen.kBorderOpacity)
        .clamp(0.0, GameScreen.kBorderOpacity);

    return Transform.scale(
      scale: scale * currentScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer border circle
          Container(
            width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
            height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
            decoration: BoxDecoration(
              color: color.withOpacity(borderOpacity * 0.5),
              shape: BoxShape.circle,
            ),
          ),
          // Main circle
          Container(
            width: GameScreen.kFingerSize,
            height: GameScreen.kFingerSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(borderOpacity),
                width: GameScreen.kBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(GameScreen.kGlowOpacity),
                  blurRadius: GameScreen.kGlowBlurRadius,
                  spreadRadius: GameScreen.kGlowSpreadRadius,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

