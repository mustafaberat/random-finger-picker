import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class SelectionAnimation {
  static const Duration duration = Duration(milliseconds: 150); // Faster base duration

  static Widget build({
    required Color color,
    required double scale,
    required bool isSelected,
    required double selectionProgress,
  }) {
    final baseOpacity = GameScreen.kDarkenedOpacity;
    
    if (isSelected) {
      // Enhanced glow intensity calculation for more dramatic effect
      final glowIntensity = (1.2 + sin(selectionProgress * 3 * pi)) * 0.7;
      final highlightIntensity = 1.2 + (glowIntensity * 0.6);
      
      // More pronounced pulse effect
      final pulseScale = 1.0 + (sin(selectionProgress * 3 * pi) * 0.2);
      
      return Container(
        width: GameScreen.kFingerSize * scale * pulseScale,
        height: GameScreen.kFingerSize * scale * pulseScale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Enhanced outer glow
            Container(
              width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale * 1.15,
              height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale * 1.15,
              decoration: BoxDecoration(
                color: color.withOpacity(GameScreen.kBorderOpacity * glowIntensity * 0.6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(GameScreen.kBorderOpacity * 0.8),
                  width: GameScreen.kOuterBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(GameScreen.kGlowOpacity * glowIntensity * 1.2),
                    blurRadius: GameScreen.kGlowBlurRadius * 2.5,
                    spreadRadius: GameScreen.kGlowSpreadRadius * glowIntensity * 1.3,
                  ),
                ],
              ),
            ),
            // Enhanced main circle
            Container(
              width: GameScreen.kFingerSize,
              height: GameScreen.kFingerSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(GameScreen.kHighlightBorderOpacity),
                  width: GameScreen.kBorderWidth * 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(GameScreen.kGlowOpacity * highlightIntensity * 1.3),
                    blurRadius: GameScreen.kGlowBlurRadius * 1.5,
                    spreadRadius: GameScreen.kGlowSpreadRadius * 1.2,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Improved non-selected circles with maintained visibility
      return Container(
        width: GameScreen.kFingerSize * scale,
        height: GameScreen.kFingerSize * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              decoration: BoxDecoration(
                color: color.withOpacity(GameScreen.kBorderOpacity * 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(GameScreen.kBorderOpacity * 0.6),
                  width: GameScreen.kOuterBorderWidth * 0.8,
                ),
              ),
            ),
            Container(
              width: GameScreen.kFingerSize,
              height: GameScreen.kFingerSize,
              decoration: BoxDecoration(
                color: color.withOpacity(baseOpacity),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(GameScreen.kBorderOpacity * 0.7),
                  width: GameScreen.kBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(GameScreen.kGlowOpacity * 0.3),
                    blurRadius: GameScreen.kGlowBlurRadius * 0.5,
                    spreadRadius: GameScreen.kGlowSpreadRadius * 0.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
} 