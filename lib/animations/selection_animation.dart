import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class SelectionAnimation {
  static const Duration duration = Duration(milliseconds: 20000); // 20 saniye
  static const double speedMultiplier = 0.1; // Hızı 10 kat yavaşlattık
  
  // Üstel yavaşlama eğrisi fonksiyonu
  static double exponentialDecelerationCurve(double progress) {
    // Üstel yavaşlama: e^(-x) fonksiyonu
    // 1.0'dan başlayıp 0'a doğru üstel olarak azalır
    final result = exp(-progress * 3); // 3 çarpanı ile yavaşlama
    
    // Her 0.1 ilerlemede bir log yazdır
    if (progress.floor() % 10 == 0) {
      print('Animasyon İlerleme: ${(progress * 100).toStringAsFixed(1)}% | Hız: ${(result * 100).toStringAsFixed(1)}%');
    }
    
    return result;
  }

  // Parmak widget'ını oluşturan yardımcı metod
  static Widget buildFingerWidget(Color color, double scale, bool isLit, double baseOpacity) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
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

  static Widget build({
    required Color color,
    required double scale,
    required bool isSelected,
    required double selectionProgress,
    required int fingerIndex,
    required int totalFingers,
  }) {
    final baseOpacity = GameScreen.kDarkenedOpacity;

    // Üstel yavaşlama eğrisini uygula
    final exponentialProgress = exponentialDecelerationCurve(selectionProgress);
    
    // Her parmak değişiminde log yazdır
    final progressPerCircle = 1.0 / totalFingers;
    // Düzeltme: selectionProgress'i doğrudan kullan, exponentialProgress'i hız için kullan
    final currentCircle = ((selectionProgress * speedMultiplier * 10) / progressPerCircle).floor() % totalFingers;
    
    // Parmak değişimini logla
    if (currentCircle != fingerIndex) {
      print('Parmak Değişimi: $fingerIndex -> $currentCircle | İlerleme: ${(selectionProgress * 100).toStringAsFixed(1)}% | Hız: ${(exponentialProgress * 100).toStringAsFixed(1)}%');
    }

    final isLit = currentCircle == fingerIndex;

    if (isLit) {
      // Improved glow and highlight effects with deceleration
      final glowIntensity = (1.2 + sin(exponentialProgress * pi * 2)) * 0.7;
      final highlightIntensity = 1.2 + (glowIntensity * 0.6);

      return AnimatedContainer(
        duration: Duration(milliseconds: 200000), // Smooth transitions
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
        duration: Duration(milliseconds: 2000000), // Smooth fading
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
