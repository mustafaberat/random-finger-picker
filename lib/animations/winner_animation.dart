import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class WinnerAnimation {
  static const Duration duration = GameScreen.kWinDuration;


  static Widget build({
    required Color color,
    required double progress,
    required double baseScale,
  }) {
    // Quick initial pause before expanding
    final delayedProgress = progress < 0.1 
        ? 0.0 
        : ((progress - 0.1) / 0.9).clamp(0.0, 1.0);
    
    // Smooth scale up animation
    final scaleProgress = Curves.easeInOut.transform(delayedProgress);
    final targetScale = 25.0; // Large enough to cover the screen
    final currentScale = baseScale + (targetScale * scaleProgress);

    // Maintain white border but make it thinner as circle grows
    final borderWidth = 4.0 * (1.0 - scaleProgress * 0.7);

    return Transform.scale(
      scale: currentScale,
      child: Container(
        width: GameScreen.kFingerSize,
        height: GameScreen.kFingerSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20 * (1.0 + scaleProgress),
              spreadRadius: 5 * (1.0 + scaleProgress),
            ),
          ],
        ),
      ),
    );
  }
} 