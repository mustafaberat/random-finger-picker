import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class SelectionAnimation {
  static const Duration duration = Duration(milliseconds: 2000);

  static Widget build({
    required Color color,
    required double scale,
    required bool isSelected,
    required double selectionProgress,
  }) {
    // Use GameScreen constants for consistent appearance
    final baseOpacity = GameScreen.kDarkenedOpacity;
    
    if (isSelected) {
      // Create a smooth highlight effect with faster cycling
      final cycleProgress = (selectionProgress * 10) % 1.0; // Cycle 10 times during the animation
      final highlightProgress = Curves.easeInOut.transform(cycleProgress);
      
      return Transform.scale(
        scale: scale * (1.0 + (GameScreen.kPulseScaleFactor * highlightProgress)),
        child: Container(
          width: GameScreen.kFingerSize,
          height: GameScreen.kFingerSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(GameScreen.kHighlightBorderOpacity),
              width: GameScreen.kBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(GameScreen.kGlowOpacity * highlightProgress),
                blurRadius: GameScreen.kGlowBlurRadius,
                spreadRadius: GameScreen.kGlowSpreadRadius,
              ),
            ],
          ),
        ),
      );
    } else {
      // Non-selected circles stay darkened but maintain border
      return Transform.scale(
        scale: scale,
        child: Container(
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
      );
    }
  }
} 