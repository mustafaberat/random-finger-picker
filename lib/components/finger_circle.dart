import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class FingerCircle extends StatelessWidget {
  static const double kFontSizeRatio = 0.9;

  final Color color;
  final int fingerNumber;
  final double borderOpacity;
  final bool showOuterCircle;
  final bool isLit;

  // Animasyon parametreleri
  final double? tapProgress;
  final double? baseScale;

  const FingerCircle({
    super.key,
    required this.color,
    required this.fingerNumber,
    this.borderOpacity = 1.0,
    this.showOuterCircle = true,
    this.isLit = true,
    this.tapProgress,
    this.baseScale,
  });

  double _calculateScale() {
    if (tapProgress != null) {
      // FingerTapAnimation mantığı
      final maxScale = GameScreen.kMaxScale;
      final finalRestScale = GameScreen.kFinalScale;
      final clampedProgress = tapProgress!.clamp(0.0, 1.0);

      if (clampedProgress < GameScreen.kTapExpandPhase) {
        // First phase: Expand (0-70% of animation)
        final expandProgress =
            (clampedProgress / GameScreen.kTapExpandPhase).clamp(0.0, 1.0);
        return 1.0 +
            ((maxScale - 1.0) * Curves.easeOut.transform(expandProgress));
      } else {
        // Second phase: Shrink (70-100% of animation)
        final shrinkProgress = ((clampedProgress - GameScreen.kTapExpandPhase) /
                GameScreen.kTapShrinkPhase)
            .clamp(0.0, 1.0);
        return maxScale -
            ((maxScale - finalRestScale) *
                Curves.easeInOut.transform(shrinkProgress));
      }
    } else if (baseScale != null) {
      // WinnerAnimation mantığı
      return baseScale!;
    }

    // Default scale
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final currentScale = _calculateScale();

    return Transform.scale(
      scale: currentScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showOuterCircle) _buildOuterCircle(),
          _buildMainCircle(),
        ],
      ),
    );
  }

  Widget _buildOuterCircle() {
    return Container(
      width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
      height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
      decoration: BoxDecoration(
        color: color.withOpacity(borderOpacity * 0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMainCircle() {
    return Container(
      width: GameScreen.kFingerSize,
      height: GameScreen.kFingerSize,
      decoration: BoxDecoration(
        color: isLit ? color : color.withOpacity(GameScreen.kDarkenedOpacity),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(borderOpacity),
          width: GameScreen.kBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: color
                .withOpacity(GameScreen.kGlowOpacity * (isLit ? 0.7 : 0.3)),
            blurRadius: GameScreen.kGlowBlurRadius,
            spreadRadius: GameScreen.kGlowSpreadRadius * 0.7,
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            width: GameScreen.kFingerSize,
            height: GameScreen.kFingerSize,
            alignment: Alignment.center,
            child: Text(
              fingerNumber.toString(),
              style: TextStyle(
                color: Colors.white.withOpacity(GameScreen.kHighlightBorderOpacity),
                fontSize: GameScreen.kFingerSize * kFontSizeRatio,
                fontFamily: GameScreen.kFontFamily,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
