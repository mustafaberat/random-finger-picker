import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class SelectionAnimation {
  static const Duration duration = GameScreen.kSelectionDuration;

  static Widget build({
    required Color color,
    required double scale,
    required bool isSelected,
    required double selectionProgress,
  }) {
    final baseOpacity = GameScreen.kDarkenedOpacity;
    
    if (isSelected) {
      // Fast selection phase (0-0.6), slow highlight phase (0.6-0.8), final display (0.8-1.0)
      final isInFastPhase = selectionProgress < 0.6;
      final isInSlowPhase = selectionProgress >= 0.6 && selectionProgress < 0.8;
      final isInFinalPhase = selectionProgress >= 0.8;
      
      // Calculate progress for each phase
      double cycleProgress;
      double highlightIntensity;
      
      if (isInFastPhase) {
        // Fast cycling phase
        cycleProgress = (selectionProgress / 0.6 * 8.0) % 1.0; // 8 fast cycles
        highlightIntensity = 1.0;
      } else if (isInSlowPhase) {
        // Slow cycling phase with increasing highlight
        cycleProgress = ((selectionProgress - 0.6) / 0.2 * 2.0) % 1.0; // 2 slow cycles
        highlightIntensity = ((selectionProgress - 0.6) / 0.2) * 2.0;
      } else {
        // Final display phase
        cycleProgress = 0.0; // Stop at current position
        highlightIntensity = 2.0 + ((selectionProgress - 0.8) / 0.2) * 1.0; // Extra glow at the end
      }
      
      // Smooth out the cycle progress
      final smoothProgress = Curves.easeInOut.transform(cycleProgress);
      
      // Calculate pulsing effect
      final pulseEffect = isInFinalPhase 
          ? sin(selectionProgress * 10 * pi) * 0.2 + 0.8 // Gentle pulse in final phase
          : smoothProgress;
      
      return Transform.scale(
        scale: scale * (1.0 + (GameScreen.kPulseScaleFactor * pulseEffect)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer border circle
            Container(
              width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              decoration: BoxDecoration(
                color: color.withOpacity(GameScreen.kBorderOpacity * highlightIntensity),
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
                  color: Colors.white.withOpacity(GameScreen.kHighlightBorderOpacity * highlightIntensity),
                  width: GameScreen.kBorderWidth * (isInFinalPhase ? 1.5 : 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(GameScreen.kGlowOpacity * highlightIntensity),
                    blurRadius: GameScreen.kGlowBlurRadius * (isInFinalPhase ? 1.5 : 1.0),
                    spreadRadius: GameScreen.kGlowSpreadRadius * (isInFinalPhase ? 1.5 : 1.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Non-selected circles stay darkened but maintain border
      return Transform.scale(
        scale: scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer border circle
            Container(
              width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              decoration: BoxDecoration(
                color: color.withOpacity(GameScreen.kBorderOpacity * 0.25),
                shape: BoxShape.circle,
              ),
            ),
            // Main circle
            Container(
              width: GameScreen.kFingerSize,
              height: GameScreen.kFingerSize,
              decoration: BoxDecoration(
                color: color.withOpacity(baseOpacity),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(GameScreen.kBorderOpacity * 0.5),
                  width: GameScreen.kBorderWidth,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
} 