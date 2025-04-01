import 'package:flutter/material.dart';

class GameConstants {
  // Global constants
  static const double kFingerSize = 100.0;
  static const Color kBackgroundColor = Color(0xFF202121);
  static const int kMaxFingers = 10; // Maximum number of fingers allowed
  static const String kFontFamily = 'LuckiestGuy'; // Global font family

  // Game colors
  static const List<Color> kGameColors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.teal,
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.brown,
    Colors.cyan,
    Colors.pink,
  ];

  // Game timing
  static const int kInitialCountdown = kDebugMode ? 1 : 5;
  static const Duration kWinnerShowDuration = Duration(milliseconds: 3000);
  static const Duration kGameResetDelay = Duration(seconds: 3);

  // Common animation properties
  static const double kMaxScale = 2.0;
  static const double kFinalScale = 1.2;
  static const double kBorderWidth = 3.0;
  static const double kOuterBorderWidth = 4.0;
  static const double kOuterBorderScale = 1.30;
  static const double kBorderOpacity = 0.4;
  static const double kHighlightBorderOpacity = 0.9;
  static const double kDarkenedOpacity = 0.2;
  static const double kGlowBlurRadius = 10.0;
  static const double kGlowSpreadRadius = 5.0;
  static const double kGlowOpacity = 0.3;

  // Selection animation properties
  static const int kTotalIterations = 15;
  static const double kSelectedFingerBorderOpacity = 0.9;
  static const double kUnselectedFingerBorderOpacity = 0.15;
  static const double kStopDelayDuration = 500;
  static const double kInitialSpeed = 4.0;
  static const double kFinalSpeed = 0.2;

  // Finger tap animation properties
  static const Duration kTapDuration = Duration(milliseconds: 300);
  static const double kTapExpandPhase = 0.7;
  static const double kTapShrinkPhase = 0.3;

  // Winner animation properties
  static const double kInitialPause = 0.2;
  static const Duration kWinDuration = Duration(milliseconds: 4000);
  static const Duration kPulseDuration = Duration(milliseconds: 1000);
  static const Duration kConfettiDuration = Duration(seconds: 5);
  static const double kWinnerMaxScale = 8.0;
  static const double kConfettiStartProgress = 0.8;
  static const double kConfettiMultiplier = 5.0;

  // Debug mode
  static const bool kDebugMode = false;
}
