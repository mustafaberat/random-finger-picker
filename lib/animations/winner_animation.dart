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

    // Daha smooth timing için ayarlanmış değerler
    final initialPause = 0.4; // Daha kısa başlangıç duraklaması
    final glowDuration = 0.7; // Daha kısa glow fazı
    
    // Daha yumuşak progress hesaplaması
    final delayedProgress = progress < initialPause 
        ? 0.0 
        : Curves.easeOutCubic.transform((progress - initialPause) / (1 - initialPause)).clamp(0.0, 1.0);
    
    // Daha smooth scale animasyonu
    final scaleProgress = Curves.easeOutCubic.transform(delayedProgress);
    final targetScale = 40.0; // Daha makul bir maksimum scale
    final currentScale = baseScale + (targetScale * scaleProgress);

    // Daha yumuşak glow efekti
    final glowProgress = progress > (1 - glowDuration)
        ? Curves.easeInOut.transform((progress - (1 - glowDuration)) / glowDuration).clamp(0.0, 1.0)
        : 0.0;
    final glowIntensity = glowProgress;

    // Daha hafif pulse efekti
    final pulseEffect = progress > 0.6 
        ? sin((progress - 0.6) * 3 * pi) * 0.05 * (1 - ((progress - 0.6) / 0.4))
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
              // Optimize edilmiş glow efekti
              if (glowProgress > 0) Container(
                width: GameScreen.kFingerSize * 1.3,
                height: GameScreen.kFingerSize * 1.3,
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
              // Ana circle container
              Container(
                width: GameScreen.kFingerSize,
                height: GameScreen.kFingerSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.9 - (0.4 * scaleProgress)),
                    width: 4.0 * (1.0 - (0.5 * scaleProgress)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4 * (1 - scaleProgress)),
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
                child: Center(
                  child: Transform.scale(
                    scale: 1.0 + (scaleProgress * 0.3),
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