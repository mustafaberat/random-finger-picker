import 'dart:math';
import 'package:flutter/material.dart';

class SelectionAnimation {
  static const Duration duration = Duration(milliseconds: 2000);
  static const double fingerSize = 100.0;

  static Widget build({
    required Color color,
    required double scale,
    required bool isSelected,
    required double selectionProgress,
  }) {
    double finalScale = scale;
    double opacity = 1.0;
    double ringScale = 1.0;
    double ringOpacity = 0.0;

    if (isSelected) {
      // Create a pulsing effect for the selected finger
      final pulsePhase = (selectionProgress * 8) % 1.0;  // Faster pulse
      final pulseValue = sin(pulsePhase * pi * 2);
      
      finalScale = scale * (1.2 + 0.1 * pulseValue);
      ringScale = 1.3 + 0.2 * pulseValue;
      ringOpacity = 0.8;
    } else {
      // Non-selected fingers slightly fade and shrink
      finalScale = scale * 0.9;
      opacity = 0.7;
    }

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: finalScale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring for selected finger
            if (isSelected)
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: fingerSize,
                  height: fingerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(ringOpacity),
                      width: 4,
                    ),
                  ),
                ),
              ),
            // Main circle with glow
            Container(
              width: fingerSize,
              height: fingerSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(isSelected ? 0.8 : 0.3),
                  width: isSelected ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isSelected ? 0.6 : 0.3),
                    blurRadius: isSelected ? 20 : 10,
                    spreadRadius: isSelected ? 10 : 5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 