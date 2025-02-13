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
    // Enhanced animation phases
    final initialPause = 0.15; // Initial pause before animation starts
    final expandDuration = 0.5; // Duration of expansion phase
    final glowDuration = 0.35; // Duration of final glow phase
    
    // Calculate phase-specific progress
    final delayedProgress = progress < initialPause 
        ? 0.0 
        : ((progress - initialPause) / (1 - initialPause)).clamp(0.0, 1.0);
    
    // Smooth scale up animation with easing
    final scaleProgress = Curves.easeOutBack.transform(delayedProgress);
    final targetScale = 40.0; // Large enough to cover the screen
    final currentScale = baseScale + (targetScale * scaleProgress);

    // Enhanced glow effect that intensifies during the animation
    final glowProgress = progress > (1 - glowDuration)
        ? ((progress - (1 - glowDuration)) / glowDuration).clamp(0.0, 1.0)
        : 0.0;
    final glowIntensity = Curves.easeInOut.transform(glowProgress);

    // Pulse effect for the final phase
    final pulseEffect = progress > 0.7 
        ? sin((progress - 0.7) * 10 * pi) * 0.05 * (1 - ((progress - 0.7) / 0.3))
        : 0.0;

    return Container(
      width: GameScreen.kFingerSize * (currentScale + pulseEffect),
      height: GameScreen.kFingerSize * (currentScale + pulseEffect),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow layer
          if (glowProgress > 0) Container(
            width: GameScreen.kFingerSize * 1.2,
            height: GameScreen.kFingerSize * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3 * glowIntensity),
                  blurRadius: 30 * (1 + glowIntensity),
                  spreadRadius: 15 * glowIntensity,
                ),
              ],
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
                color: Colors.white.withOpacity(0.8 - (0.3 * scaleProgress)),
                width: 4.0 * (1.0 - (0.5 * scaleProgress)),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5 * (1 - scaleProgress)),
                  blurRadius: 20 * (1.0 + scaleProgress),
                  spreadRadius: 10 * (1.0 + scaleProgress),
                ),
                if (glowProgress > 0) BoxShadow(
                  color: Colors.white.withOpacity(0.3 * glowIntensity),
                  blurRadius: 15 * glowIntensity,
                  spreadRadius: 5 * glowIntensity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 