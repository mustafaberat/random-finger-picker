import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameManager {
  static const int kInitialCountdown = 2;
  static const Duration kWinnerShowDuration = Duration(milliseconds: 3000);
  static const Duration kGameResetDelay = Duration(seconds: 1);

  final Map<int, Offset> fingers = {};
  final Map<int, Color> fingerColors = {};
  Timer? _waitTimer;
  Timer? _selectionTimer;
  bool isSelecting = false;
  int? selectedFinger;
  int currentFingerIndex = 0;
  int countdown = kInitialCountdown;
  bool isWinAnimationPlaying = false;

  final VoidCallback onStartSelection;
  final VoidCallback onFinishSelection;
  final VoidCallback onReset;
  final Function(int) onCountdownChanged;

  GameManager({
    required this.onStartSelection,
    required this.onFinishSelection,
    required this.onReset,
    required this.onCountdownChanged,
  });

  void dispose() {
    _waitTimer?.cancel();
    _selectionTimer?.cancel();
  }

  void addFinger(int fingerKey, Offset position) {
    fingers[fingerKey] = position;
    fingerColors[fingerKey] = _getRandomColor();
    _resetWaitTimer();
  }

  void updateFingerPosition(int fingerKey, Offset position) {
    fingers[fingerKey] = position;
  }

  void removeFinger(int fingerKey) {
    // Don't reorder remaining fingers when removing one
    fingers.remove(fingerKey);
    fingerColors.remove(fingerKey);
    
    // If we have less than 2 fingers, cancel the timer
    if (fingers.length < 2) {
      _waitTimer?.cancel();
      countdown = kInitialCountdown;
      onCountdownChanged(countdown);
    }
  }

  void _resetWaitTimer() {
    _waitTimer?.cancel();
    if (fingers.length >= 2) {
      countdown = kInitialCountdown;
      onCountdownChanged(countdown);
      
      _waitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (countdown > 1) {
          countdown--;
          onCountdownChanged(countdown);
        } else {
          timer.cancel();
          startSelection();
        }
      });
    }
  }

  void startSelection() {
    if (fingers.isEmpty) return;
    isSelecting = true;
    currentFingerIndex = 0;
    
    // Start cycling through fingers
    _cycleFingers();
    onStartSelection();
  }

  void _cycleFingers() {
    if (!isSelecting) return;
    
    _selectionTimer?.cancel();
    // Update current finger index
    _selectionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!isSelecting) {
        timer.cancel();
        return;
      }
      
      currentFingerIndex = (currentFingerIndex + 1) % fingers.length;
      onStartSelection();
    });

    // Stop selection after 2 seconds
    Future.delayed(const Duration(milliseconds: 2000), () {
      _selectionTimer?.cancel();
      if (isSelecting) {
        finishSelection();
      }
    });
  }

  void finishSelection() {
    // Randomly select a winner from available fingers
    final random = Random();
    final fingerKeys = fingers.keys.toList();
    selectedFinger = fingerKeys[random.nextInt(fingerKeys.length)];
    
    isSelecting = false;
    isWinAnimationPlaying = true;
    onFinishSelection();

    Future.delayed(kGameResetDelay, () {
      reset();
    });
  }

  void reset() {
    fingers.clear();
    fingerColors.clear();
    selectedFinger = null;
    currentFingerIndex = 0;
    countdown = kInitialCountdown;
    isWinAnimationPlaying = false;
    onReset();
  }

  // TODO: Remove this method after testing - This is only for development purposes
  void addTestFingers(Size screenSize) {
    // Add some random offset to make it look more natural
    final random = Random();
    final padding = 100.0;
    
    // Top-left
    addFinger(1, Offset(
      padding + random.nextDouble() * 50,
      padding + random.nextDouble() * 50,
    ));

    // Top-right
    addFinger(2, Offset(
      screenSize.width - padding - random.nextDouble() * 50,
      padding + random.nextDouble() * 50,
    ));

    // Bottom-left
    addFinger(3, Offset(
      padding + random.nextDouble() * 50,
      screenSize.height - padding - random.nextDouble() * 50,
    ));

    // Bottom-right
    addFinger(4, Offset(
      screenSize.width - padding - random.nextDouble() * 50,
      screenSize.height - padding - random.nextDouble() * 50,
    ));
  }

  Color _getRandomColor() {
    final random = Random();
    final existingHues = fingerColors.values.map((color) {
      final hsl = HSLColor.fromColor(color);
      return hsl.hue;
    }).toList();

    double newHue;
    do {
      newHue = random.nextDouble() * 360;
    } while (existingHues.any((hue) => (newHue - hue).abs() < 60));

    return HSLColor.fromAHSL(1, newHue, 0.8, 0.5).toColor();
  }
} 