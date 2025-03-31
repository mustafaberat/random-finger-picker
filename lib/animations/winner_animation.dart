import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';
import '../components/finger_circle.dart';

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
    final double confettiProgress = _calculateConfettiProgress(progress);

    return Stack(
      children: [
        FingerCircle(
          color: color,
          fingerNumber: fingerNumber,
          baseScale: currentScale,
        ),

        // Konfeti
        if (confettiProgress > 0)
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: ConfettiPainter(progress: confettiProgress),
          ),
      ],
    );
  }

  double _calculateDelayedProgress(double progress) {
    return progress < GameScreen.kInitialPause
        ? 0.0
        : Curves.easeOutCubic.transform((progress - GameScreen.kInitialPause) / (1 - GameScreen.kInitialPause)).clamp(0.0, 1.0);
  }

  double _calculateScale(double baseScale, double progress) {
    return baseScale + (GameScreen.kWinnerMaxScale * progress);
  }

  double _calculateConfettiProgress(double progress) {
    return progress > GameScreen.kConfettiStartProgress 
        ? (progress - GameScreen.kConfettiStartProgress) * GameScreen.kConfettiMultiplier 
        : 0.0;
  }
}

class ConfettiPainter extends CustomPainter {
  static const int confettiCount = 30;
  final double progress;
  
  // Cache confetti properties
  static final List<_ConfettiParticle> _particles = _generateParticles();
  
  ConfettiPainter({required this.progress});

  static List<_ConfettiParticle> _generateParticles() {
    final random = Random(42);
    return List.generate(
      confettiCount,
      (i) => _ConfettiParticle(
        angle: random.nextDouble() * 2 * pi,
        color: HSLColor.fromAHSL(
          1,
          random.nextDouble() * 360,
          0.8,
          0.6,
        ).toColor(),
        isCircle: i % 3 == 0,
        spreadX: random.nextDouble() - 0.5,
        spreadY: random.nextDouble() - 0.5,
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (final particle in _particles) {
      final x = size.width / 2 + particle.spreadX * size.width * progress;
      final y = size.height / 2 + particle.spreadY * size.height * progress;
      final rotation = particle.angle * progress;
      
      paint.color = particle.color;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      if (particle.isCircle) {
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

class _ConfettiParticle {
  final double angle;
  final Color color;
  final bool isCircle;
  final double spreadX;
  final double spreadY;

  const _ConfettiParticle({
    required this.angle,
    required this.color,
    required this.isCircle,
    required this.spreadX,
    required this.spreadY,
  });
}
