import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class SelectionAnimation {
  static const Duration duration = Duration(milliseconds: 15500);
  static const double speedMultiplier = 0.25; // Controls animation speed (lower = slower)

  // Deceleration curve function
  static double decelerateCurve(double progress) {
    // Start fast and decelerate exponentially
    return 1.0 - pow(1.0 - progress, 3);
  }

  static Widget build({
    required Color color,
    required double scale,
    required bool isSelected,
    required double selectionProgress,
    required int fingerIndex,
    required int totalFingers,
  }) {
    final baseOpacity = GameScreen.kDarkenedOpacity;

    // Calculate the current circle index with proper cycling
    final progressPerCircle = 1.0 / totalFingers;
    final currentCircle = (selectionProgress / progressPerCircle).floor() % totalFingers;

    final isLit = currentCircle == fingerIndex;

    if (isLit) {
      // Improved glow and highlight effects with deceleration
      final glowIntensity = (1.2 + sin(selectionProgress * pi * 2)) * 0.7;
      final highlightIntensity = 1.2 + (glowIntensity * 0.6);

      return AnimatedContainer(
        duration: Duration(milliseconds: 200), // Smooth transitions
        width: GameScreen.kFingerSize * scale,
        height: GameScreen.kFingerSize * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              decoration: BoxDecoration(
                color: color.withOpacity((GameScreen.kBorderOpacity * glowIntensity * 0.6).clamp(0.0, 1.0)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity((GameScreen.kBorderOpacity * 0.8).clamp(0.0, 1.0)),
                  width: GameScreen.kOuterBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity((GameScreen.kGlowOpacity * glowIntensity * 1.2).clamp(0.0, 1.0)),
                    blurRadius: GameScreen.kGlowBlurRadius * 2.5,
                    spreadRadius: GameScreen.kGlowSpreadRadius * glowIntensity * 1.3,
                  ),
                ],
              ),
            ),
            Container(
              width: GameScreen.kFingerSize,
              height: GameScreen.kFingerSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(GameScreen.kHighlightBorderOpacity.clamp(0.0, 1.0)),
                  width: GameScreen.kBorderWidth * 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity((GameScreen.kGlowOpacity * highlightIntensity * 1.3).clamp(0.0, 1.0)),
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
      return AnimatedContainer(
        duration: Duration(milliseconds: 200), // Smooth fading
        width: GameScreen.kFingerSize * scale,
        height: GameScreen.kFingerSize * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              decoration: BoxDecoration(
                color: color.withOpacity((GameScreen.kBorderOpacity * 0.3).clamp(0.0, 1.0)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity((GameScreen.kBorderOpacity * 0.6).clamp(0.0, 1.0)),
                  width: GameScreen.kOuterBorderWidth * 0.8,
                ),
              ),
            ),
            Container(
              width: GameScreen.kFingerSize,
              height: GameScreen.kFingerSize,
              decoration: BoxDecoration(
                color: color.withOpacity(baseOpacity.clamp(0.0, 1.0)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity((GameScreen.kBorderOpacity * 0.7).clamp(0.0, 1.0)),
                  width: GameScreen.kBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity((GameScreen.kGlowOpacity * 0.3).clamp(0.0, 1.0)),
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
