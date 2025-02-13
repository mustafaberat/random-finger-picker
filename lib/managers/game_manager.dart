import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class GameManager {
  final Map<int, Offset> fingers = {};
  final Map<int, Color> fingerColors = {};
  Timer? _waitTimer;
  Timer? _selectionTimer;
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
  }

  void addFinger(int fingerKey, Offset position) {
    if (isSelecting || isWinAnimationPlaying) return;
    if (fingers.length >= GameScreen.kMaxFingers) return;
    
    fingers[fingerKey] = position;
    fingerColors[fingerKey] = _getRandomColor();
    _resetWaitTimer();
  }

  void updateFingerPosition(int fingerKey, Offset position) {
    if (!fingers.containsKey(fingerKey) || isSelecting || isWinAnimationPlaying) return;
    fingers[fingerKey] = position;
  }

  void removeFinger(int fingerKey) {
    if (!fingers.containsKey(fingerKey)) return;
    
    fingers.remove(fingerKey);
    fingerColors.remove(fingerKey);
    
    if (fingers.length < 2) {
      _waitTimer?.cancel();
      countdown = GameScreen.kInitialCountdown;
      onCountdownChanged(countdown);
    }
    
    if (isSelecting || isWinAnimationPlaying) {
      reset();
    }
  }

  void _resetWaitTimer() {
    if (fingers.length < 2 || isSelecting || isWinAnimationPlaying) return;
    
    _waitTimer?.cancel();
    countdown = GameScreen.kInitialCountdown;
    onCountdownChanged(countdown);
    
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (fingers.length < 2) {
        timer.cancel();
        countdown = GameScreen.kInitialCountdown;
        onCountdownChanged(countdown);
        return;
      }
      
      if (countdown > 1) {
        countdown--;
        onCountdownChanged(countdown);
      } else {
        timer.cancel();
        startSelection();
      }
    });
  }

  void startSelection() {
    if (fingers.length < 2 || isSelecting || isWinAnimationPlaying) {
      reset();
      return;
    }
    
    isSelecting = true;
    currentFingerIndex = 0;
    
    final fingerKeys = fingers.keys.toList();
    selectedFinger = fingerKeys[Random().nextInt(fingerKeys.length)];
    
    _cycleFingers();
    onStartSelection();
  }

  void _cycleFingers() {
    if (!isSelecting || fingers.length < 2) {
      _selectionTimer?.cancel();
      return;
    }
    
    _selectionTimer?.cancel();
    _selectionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!isSelecting || fingers.length < 2) {
        timer.cancel();
        return;
      }
      
      currentFingerIndex = (currentFingerIndex + 1) % fingers.length;
      onStartSelection();
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      _selectionTimer?.cancel();
      if (isSelecting && fingers.length >= 2) {
        final fingerKeys = fingers.keys.toList();
        if (fingerKeys.contains(selectedFinger)) {
          currentFingerIndex = fingerKeys.indexOf(selectedFinger!);
          onStartSelection();
          finishSelection();
        } else {
          reset();
        }
      }
    });
  }

  void finishSelection() {
    if (fingers.length < 2) {
      reset();
      return;
    }
    
    isSelecting = false;
    isWinAnimationPlaying = true;
    onFinishSelection();

    Future.delayed(GameScreen.kGameResetDelay, () {
      reset();
    });
  }

  void reset() {
    _waitTimer?.cancel();
    _selectionTimer?.cancel();
    fingers.clear();
    fingerColors.clear();
    selectedFinger = null;
    currentFingerIndex = 0;
    countdown = GameScreen.kInitialCountdown;
    isSelecting = false;
    isWinAnimationPlaying = false;
    onReset();
  }

  Color _getRandomColor() {
    final random = Random();
    final hue = random.nextDouble() * 360;
    return HSLColor.fromAHSL(1, hue, 0.8, 0.5).toColor();
  }
} 