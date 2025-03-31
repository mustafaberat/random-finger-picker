import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class WinnerAnimation {
  static const Duration duration = GameScreen.kWinDuration;
  static const int lucyFingerId = 1; // Lucy's finger ID for consistency
  static bool _isFirstLog = true; // İlk log için kontrol

  static Widget build({
    required Color color,
    required double progress,
    required double baseScale,
    required int fingerNumber,
  }) {
    // Log kazanan parmağı sadece bir kez
    if (_isFirstLog) {
      print('🎊 Kazanan Animasyonu Başladı | Parmak: $fingerNumber');
      _isFirstLog = false;
    }

    // Enhanced animation phases with slower timing
    final initialPause = 0.6; // Initial pause for selection animation
    final glowDuration = 0.9; // Longer glow phase
    
    // Calculate phase-specific progress with slower easing
    final delayedProgress = progress < initialPause 
        ? 0.0 
        : ((progress - initialPause) / (1 - initialPause)).clamp(0.0, 1.0);
    
    // Slower scale up animation with gentler easing
    final scaleProgress = Curves.easeOutCirc.transform(delayedProgress);
    final targetScale = 50.0; // Even larger to ensure full screen coverage
    final currentScale = baseScale + (targetScale * scaleProgress * scaleProgress); // Square the progress for even slower growth

    // Enhanced glow effect that intensifies during the animation
    final glowProgress = progress > (1 - glowDuration)
        ? ((progress - (1 - glowDuration)) / glowDuration).clamp(0.0, 1.0)
        : 0.0;
    final glowIntensity = Curves.easeInOut.transform(glowProgress);

    // More dramatic pulse effect for the final phase
    final pulseEffect = progress > 0.6 
        ? sin((progress - 0.6) * 4 * pi) * 0.08 * (1 - ((progress - 0.6) / 0.4))
        : 0.0;

    return Center(
      child: Transform.scale(
        scale: currentScale + pulseEffect,
        alignment: Alignment.center,
        child: Container(
          width: GameScreen.kFingerSize,
          height: GameScreen.kFingerSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Multiple layers of glow for more dramatic effect
              if (glowProgress > 0) ...[
                Container(
                  width: GameScreen.kFingerSize * 1.5,
                  height: GameScreen.kFingerSize * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity((0.4 * glowIntensity).clamp(0.0, 1.0)),
                        blurRadius: 40 * (1 + glowIntensity),
                        spreadRadius: 20 * glowIntensity,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: GameScreen.kFingerSize * 1.2,
                  height: GameScreen.kFingerSize * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity((0.3 * glowIntensity).clamp(0.0, 1.0)),
                        blurRadius: 25 * (1 + glowIntensity),
                        spreadRadius: 10 * glowIntensity,
                      ),
                    ],
                  ),
                ),
              ],
              // Main circle with enhanced effects
              Container(
                width: GameScreen.kFingerSize,
                height: GameScreen.kFingerSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity((0.9 - (0.4 * scaleProgress)).clamp(0.0, 1.0)),
                    width: 5.0 * (1.0 - (0.6 * scaleProgress)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity((0.6 * (1 - scaleProgress)).clamp(0.0, 1.0)),
                      blurRadius: 25 * (1.0 + scaleProgress),
                      spreadRadius: 15 * (1.0 + scaleProgress),
                    ),
                    if (glowProgress > 0) BoxShadow(
                      color: Colors.white.withOpacity((0.4 * glowIntensity).clamp(0.0, 1.0)),
                      blurRadius: 20 * glowIntensity,
                      spreadRadius: 8 * glowIntensity,
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.scale(
                    scale: 1.0 + (scaleProgress * 0.5), // Numarayı da büyüt ama daha kontrollü
                    child: Text(
                      fingerNumber.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: GameScreen.kFingerSize * 0.4,
                        fontFamily: GameScreen.kFontFamily,
                        fontWeight: FontWeight.bold,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 