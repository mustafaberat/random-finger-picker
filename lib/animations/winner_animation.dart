import 'dart:math';
import 'package:flutter/material.dart';

class WinnerAnimation {
  static const Duration duration = Duration(milliseconds: 3000);
  static const double fingerSize = 100.0;

  static Widget build({
    required Color color,
    required double progress,
    required double baseScale,
  }) {
    // Dramatic scale up with wave effect
    final waveEffect = sin(progress * pi * 2) * 0.2;
    final finalScale = 20.0 * (1.0 + waveEffect) * progress;
    
    return Transform.scale(
      scale: baseScale * finalScale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse glow
          Container(
            width: fingerSize * 1.5,
            height: fingerSize * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3 + (waveEffect * 0.2)),
                  blurRadius: 80,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
          // Main circle with intense glow
          Container(
            width: fingerSize,
            height: fingerSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.6 + (waveEffect * 0.2)),
                width: 6,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.8),
                  blurRadius: 40,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 