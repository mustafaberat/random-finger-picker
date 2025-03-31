import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class WinnerAnimation {
  static const Duration duration = GameScreen.kWinDuration;
  static const int lucyFingerId = 1; // Lucy's finger ID for consistency
  static bool _isFirstLog = true;

  static Widget build({
    required Color color,
    required double progress,
    required double baseScale,
    required int fingerNumber,
  }) {
    if (_isFirstLog) {
      debugPrint('🎊 Kazanan Animasyonu Başladı | Parmak: $fingerNumber');
      _isFirstLog = false;
    }

    final double delayedProgress = _calculateDelayedProgress(progress);
    final double currentScale = _calculateScale(baseScale, delayedProgress);
    final double glowProgress = _calculateGlowProgress(progress);
    final double pulseEffect = _calculatePulseEffect(progress);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildGlowEffect(color, glowProgress),
            _buildFingerCircle(color, currentScale, pulseEffect, delayedProgress),
            _buildFingerNumber(fingerNumber, currentScale, pulseEffect),
          ],
        ),
      ),
    );
  }

  static double _calculateDelayedProgress(double progress) {
    const double initialPause = 0.3;
    return progress < initialPause
        ? 0.0
        : Curves.easeOutCubic.transform((progress - initialPause) / (1 - initialPause)).clamp(0.0, 1.0);
  }

  static double _calculateScale(double baseScale, double progress) {
    const double targetScale = 25.0;
    return baseScale + (targetScale * progress);
  }

  static double _calculateGlowProgress(double progress) {
    const double glowDuration = 0.7;
    return progress > (1 - glowDuration)
        ? Curves.easeInOut.transform((progress - (1 - glowDuration)) / glowDuration).clamp(0.0, 1.0)
        : 0.0;
  }

  static double _calculatePulseEffect(double progress) {
    return progress > 0.6 
        ? sin((progress - 0.6) * 3 * pi) * 0.03 * (1 - ((progress - 0.6) / 0.4))
        : 0.0;
  }

  static Widget _buildGlowEffect(Color color, double glowProgress) {
    return glowProgress > 0
        ? Container(
            width: GameScreen.kFingerSize * 2,
            height: GameScreen.kFingerSize * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3 * glowProgress),
                  blurRadius: 30,
                  spreadRadius: 15,
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  static Widget _buildFingerCircle(Color color, double scale, double pulse, double progress) {
    return Transform.scale(
      scale: scale + pulse,
      child: Container(
        width: GameScreen.kFingerSize,
        height: GameScreen.kFingerSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.9 - (0.4 * progress)),
            width: 4.0 * (1.0 - (0.3 * progress)),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4 * (1 - progress)),
              blurRadius: 20,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFingerNumber(int fingerNumber, double scale, double pulse) {
    return Transform.scale(
      scale: scale + pulse,
      child: Container(
        width: GameScreen.kFingerSize,
        height: GameScreen.kFingerSize,
        alignment: Alignment.center,
        padding: EdgeInsets.only(bottom: GameScreen.kFingerSize * 0.05),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            fingerNumber.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: GameScreen.kFingerSize * 0.35,
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
    );
  }
}
