import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class SelectionAnimation {
  static const Duration duration = Duration(milliseconds: 200);

  static Widget build({
    required Color color,
    required double scale,
    required bool isSelected,
    required double selectionProgress,
  }) {
    final baseOpacity = GameScreen.kDarkenedOpacity;
    
    if (isSelected) {
      // Calculate glow intensity based on selection progress
      final glowIntensity = (1 + sin(selectionProgress * 2 * pi)) * 0.5;
      final highlightIntensity = 1.0 + (glowIntensity * 0.5);
      
      // Pulse effect for selected circle
      final pulseScale = 1.0 + (glowIntensity * 0.2);
      
      return Transform.scale(
        scale: scale * pulseScale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale * 1.2,
              height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale * 1.2,
              decoration: BoxDecoration(
                color: color.withOpacity(GameScreen.kBorderOpacity * glowIntensity * 0.5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(GameScreen.kGlowOpacity * glowIntensity),
                    blurRadius: GameScreen.kGlowBlurRadius * 2,
                    spreadRadius: GameScreen.kGlowSpreadRadius * glowIntensity,
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
                  color: Colors.white.withOpacity(GameScreen.kHighlightBorderOpacity * highlightIntensity),
                  width: GameScreen.kBorderWidth * highlightIntensity,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(GameScreen.kGlowOpacity * highlightIntensity),
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
      // Non-selected circles stay darkened but maintain a subtle pulse
      return Transform.scale(
        scale: scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              decoration: BoxDecoration(
                color: color.withOpacity(GameScreen.kBorderOpacity * 0.25),
                shape: BoxShape.circle,
              ),
            ),
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