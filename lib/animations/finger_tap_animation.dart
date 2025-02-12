import 'dart:math';
import 'package:flutter/material.dart';

class FingerTapAnimation {
  static const Duration duration = Duration(milliseconds: 400);
  static const double fingerSize = 100.0;

  static Widget build({
    required Color color,
    required double scale,
    required double tapProgress,
    required bool isSelecting,
    required bool isWinAnimationPlaying,
  }) {
    // Create a two-phase animation using custom curves
    final firstPhase = tapProgress < 0.5 
        ? Curves.easeOutBack.transform(tapProgress * 2) 
        : 1.0;
    final secondPhase = tapProgress < 0.5 
        ? 0.0 
        : Curves.easeInOut.transform((tapProgress - 0.5) * 2);

    // Grow then shrink effect
    final growScale = 1.0 + (0.4 * firstPhase) - (0.1 * secondPhase);
    final tapScale = scale * growScale;

    // Border and glow effects
    final borderOpacity = (1.0 - tapProgress) * 0.5;
    final borderScale = 1.0 + (0.3 * firstPhase);
    final glowIntensity = firstPhase * (1.0 - secondPhase);

    return Transform.scale(
      scale: tapScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: fingerSize * 1.5,
            height: fingerSize * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3 * glowIntensity),
                  blurRadius: 30,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),
          // Animated border
          Transform.scale(
            scale: borderScale,
            child: Container(
              width: fingerSize * 1.2,
              height: fingerSize * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(borderOpacity),
                  width: 4,
                ),
              ),
            ),
          ),
          // Main circle
          Container(
            width: fingerSize,
            height: fingerSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4 * glowIntensity),
                  blurRadius: 20,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Inner highlight
          Container(
            width: fingerSize,
            height: fingerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.3 * (1.0 - tapProgress)),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
