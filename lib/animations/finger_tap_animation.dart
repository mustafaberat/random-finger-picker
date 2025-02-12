import 'dart:math';
import 'package:flutter/material.dart';

class FingerTapAnimation {
  static const Duration duration = Duration(milliseconds: 200);
  static const double fingerSize = 100.0;

  static Widget build({
    required Color color,
    required double scale,
    required double tapProgress,
    required bool isSelecting,
    required bool isWinAnimationPlaying,
  }) {
    // Two-phase animation: expand then shrink
    final maxScale = 1.4;
    final finalRestScale = 1.2;
    
    // Calculate scale based on progress
    final double currentScale;
    if (tapProgress < 0.5) {
      // First phase: Expand (0-50% of animation)
      final expandProgress = Curves.easeOut.transform(tapProgress * 2).clamp(0.0, 1.0);
      currentScale = 1.0 + ((maxScale - 1.0) * expandProgress);
    } else {
      // Second phase: Shrink (50-100% of animation)
      final shrinkProgress = Curves.easeOut.transform((tapProgress - 0.5) * 2).clamp(0.0, 1.0);
      currentScale = maxScale - ((maxScale - finalRestScale) * shrinkProgress);
    }

    // Border opacity with smooth fade in
    final borderOpacity = (Curves.easeOut.transform(tapProgress < 0.3 ? tapProgress / 0.3 : 1.0) * 0.4).clamp(0.0, 0.4);

    return Transform.scale(
      scale: scale * currentScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Translucent border circle
          Container(
            width: fingerSize * 1.15,
            height: fingerSize * 1.15,
            decoration: BoxDecoration(
              color: color.withOpacity(borderOpacity),
              shape: BoxShape.circle,
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
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

