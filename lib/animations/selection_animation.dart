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
    // Use GameScreen constants for consistent appearance
    final baseOpacity = GameScreen.kDarkenedOpacity;
    
    if (isSelected) {
      // Create a smooth highlight effect with dynamic speed
      final cycleCount = 12.0; // Total number of cycles
      
      // Create a speed curve that starts fast and slows down
      final speedCurve = Curves.easeIn.transform(selectionProgress);
      final slowdownFactor = 1.0 - (speedCurve * 0.9); // More dramatic slowdown
      
      // Calculate cycle progress with variable speed
      final cycleProgress = ((selectionProgress * cycleCount * slowdownFactor) % 1.0).clamp(0.0, 1.0);
      final highlightProgress = Curves.easeInOut.transform(cycleProgress);
      
      // Increase highlight intensity near the end
      final finalHighlight = selectionProgress > 0.8 
          ? Curves.easeIn.transform((selectionProgress - 0.8) * 5) 
          : 0.0;
      
      return Transform.scale(
        scale: scale * (1.0 + (GameScreen.kPulseScaleFactor * (highlightProgress + finalHighlight))),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer border circle
            Container(
              width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              decoration: BoxDecoration(
                color: color.withOpacity(GameScreen.kBorderOpacity * 0.5 * (highlightProgress + finalHighlight)),
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
                  color: Colors.white.withOpacity(GameScreen.kHighlightBorderOpacity * (1.0 + finalHighlight)),
                  width: GameScreen.kBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(GameScreen.kGlowOpacity * (highlightProgress + finalHighlight)),
                    blurRadius: GameScreen.kGlowBlurRadius,
                    spreadRadius: GameScreen.kGlowSpreadRadius,
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