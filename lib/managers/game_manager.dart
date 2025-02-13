import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class GameManager {
  final Map<int, Offset> fingers = {};
  final Map<int, Color> fingerColors = {};
  Timer? _waitTimer;
  Timer? _selectionTimer;
  Timer? _updateThrottleTimer;
  bool isSelecting = false;
  int? selectedFinger;
  int currentFingerIndex = 0;
  int countdown = GameScreen.kInitialCountdown;
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
    _updateThrottleTimer?.cancel();
  }

  void addFinger(int fingerKey, Offset position) {
    if (fingers.length >= GameScreen.kMaxFingers) return;
    
    fingers[fingerKey] = position;
    fingerColors[fingerKey] = _getRandomColor();
    _resetWaitTimer();
  }

  void updateFingerPosition(int fingerKey, Offset position) {
    if (!fingers.containsKey(fingerKey)) return;
    
    // Throttle updates to prevent excessive state changes
    _updateThrottleTimer?.cancel();
    _updateThrottleTimer = Timer(const Duration(milliseconds: 16), () {
      fingers[fingerKey] = position;
    });
  }

  void removeFinger(int fingerKey) {
    fingers.remove(fingerKey);
    fingerColors.remove(fingerKey);
    
    if (fingers.length < 2) {
      _waitTimer?.cancel();
      countdown = GameScreen.kInitialCountdown;
      onCountdownChanged(countdown);
    }
  }

  void _resetWaitTimer() {
    _waitTimer?.cancel();
    if (fingers.length >= 2) {
      countdown = GameScreen.kInitialCountdown;
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
    
    // Select the winner at the start
    final random = Random();
    final fingerKeys = fingers.keys.toList();
    selectedFinger = fingerKeys[random.nextInt(fingerKeys.length)];
    
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
        // End on the selected finger
        currentFingerIndex = fingers.keys.toList().indexOf(selectedFinger!);
        onStartSelection();
        finishSelection();
      }
    });
  }

  void finishSelection() {
    isSelecting = false;
    isWinAnimationPlaying = true;
    onFinishSelection();

    Future.delayed(GameScreen.kGameResetDelay, () {
      reset();
    });
  }

  void reset() {
    fingers.clear();
    fingerColors.clear();
    selectedFinger = null;
    currentFingerIndex = 0;
    countdown = GameScreen.kInitialCountdown;
    isWinAnimationPlaying = false;
    onReset();
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