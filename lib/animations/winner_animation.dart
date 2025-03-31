import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class WinnerAnimation extends StatelessWidget {
  static const Duration duration = GameScreen.kWinDuration;
  static const int lucyFingerId = 1;
  static bool _isFirstLog = true;

  final Color color;
  final double progress;
  final double baseScale;
  final int fingerNumber;

  const WinnerAnimation({
    super.key,
    required this.color,
    required this.progress,
    required this.baseScale,
    required this.fingerNumber,
  });

  static Widget create({
    required Color color,
    required double progress,
    required double baseScale,
    required int fingerNumber,
  }) {
    if (_isFirstLog) {
      debugPrint('🎊 Kazanan Animasyonu Başladı | Parmak: $fingerNumber');
      _isFirstLog = false;
    }

    return WinnerAnimation(
      color: color,
      progress: progress,
      baseScale: baseScale,
      fingerNumber: fingerNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double delayedProgress = _calculateDelayedProgress(progress);
    final double currentScale = _calculateScale(baseScale, delayedProgress);
    final double numberOpacity = _calculateNumberOpacity(delayedProgress);
    final double confettiProgress = _calculateConfettiProgress(progress);

    return Container(
      width: GameScreen.kFingerSize,
      height: GameScreen.kFingerSize,
      child: Stack(
        fit: StackFit.loose,
        children: [
          // Dış border dairesi
          Center(
            child: AnimatedScale(
              scale: currentScale,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
                height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Büyüyen daire
          Center(
            child: AnimatedScale(
              scale: currentScale,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: GameScreen.kFingerSize,
                height: GameScreen.kFingerSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: GameScreen.kBorderWidth,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 15,
                    ),
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: GameScreen.kGlowBlurRadius,
                      spreadRadius: GameScreen.kGlowSpreadRadius * 0.7,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Numara
          Center(
            child: AnimatedScale(
              scale: currentScale * 0.7,
              duration: const Duration(milliseconds: 100),
              child: Text(
                fingerNumber.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: GameScreen.kFingerSize * 0.9,
                  fontFamily: GameScreen.kFontFamily,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Konfeti
          if (confettiProgress > 0)
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: ConfettiPainter(progress: confettiProgress),
            ),
        ],
      ),
    );
  }

  double _calculateDelayedProgress(double progress) {
    const double initialPause = 0.2;
    return progress < initialPause
        ? 0.0
        : Curves.easeOutCubic.transform((progress - initialPause) / (1 - initialPause)).clamp(0.0, 1.0);
  }

  double _calculateScale(double baseScale, double progress) {
    const double maxScale = 8.0;
    return baseScale + (maxScale * progress);
  }

  double _calculateNumberOpacity(double progress) {
    return 1.0;
  }

  double _calculateConfettiProgress(double progress) {
    return progress > 0.8 ? (progress - 0.8) * 5 : 0.0;
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;

  ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final random = Random(42);
    final confettiCount = 30;

    for (var i = 0; i < confettiCount; i++) {
      final x = size.width / 2 + (random.nextDouble() - 0.5) * size.width * progress;
      final y = size.height / 2 + (random.nextDouble() - 0.5) * size.height * progress;
      final rotation = random.nextDouble() * 2 * pi * progress;
      final color = HSLColor.fromAHSL(
        1,
        random.nextDouble() * 360,
        0.8,
        0.6,
      ).toColor();

      paint.color = color;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      if (i % 3 == 0) {
        canvas.drawCircle(Offset.zero, 6, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: 10,
            height: 5,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => progress != oldDelegate.progress;
}
