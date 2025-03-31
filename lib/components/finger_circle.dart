import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class FingerCircle extends StatelessWidget {
  final Color color;
  final double scale;
  final int fingerNumber;
  final double borderOpacity;
  final bool showOuterCircle;
  final bool isLit;
  final double? customFontSize;

  const FingerCircle({
    super.key,
    required this.color,
    required this.scale,
    required this.fingerNumber,
    this.borderOpacity = 1.0,
    this.showOuterCircle = true,
    this.isLit = true,
    this.customFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
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
            color: color.withOpacity(GameScreen.kGlowOpacity * (isLit ? 0.7 : 0.3)),
            blurRadius: GameScreen.kGlowBlurRadius,
            spreadRadius: GameScreen.kGlowSpreadRadius * 0.7,
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            width: GameScreen.kFingerSize * 0.8,
            height: GameScreen.kFingerSize * 0.8,
            alignment: Alignment.center,
            child: Text(
              fingerNumber.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: customFontSize ?? (GameScreen.kFingerSize * 0.9),
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