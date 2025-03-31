import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';
import '../animations/selection_animation.dart';

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
    fingerColors[fingerKey] = _getNextColor();
    _resetWaitTimer();
  }

  void updateFingerPosition(int fingerKey, Offset position) {
    if (!fingers.containsKey(fingerKey) || isSelecting || isWinAnimationPlaying) return;
    fingers[fingerKey] = position;
  }

  void removeFinger(int fingerKey) {
    if (!fingers.containsKey(fingerKey)) return;
    
    // Don't remove debug mode fingers
    if (GameScreen.kDebugMode && fingerKey <= 4) return;
    
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
    // Randomly select a finger
    final random = Random();
    selectedFinger = fingerKeys[random.nextInt(fingerKeys.length)];
    SelectionAnimation.setSelectedFinger(selectedFinger!);
    print('Manager choose winner finger: $selectedFinger');
    
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
        selectedFinger = SelectionAnimation.selectedFinger;
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
    
    if (GameScreen.kDebugMode) {
      // Keep only debug fingers (1-4)
      final debugFingers = Map<int, Offset>.fromEntries(
        fingers.entries.where((entry) => entry.key <= 4)
      );
      final debugColors = Map<int, Color>.fromEntries(
        fingerColors.entries.where((entry) => entry.key <= 4)
      );
      fingers.clear();
      fingerColors.clear();
      fingers.addAll(debugFingers);
      fingerColors.addAll(debugColors);
    } else {
      fingers.clear();
      fingerColors.clear();
    }
    
    isSelecting = false;
    isWinAnimationPlaying = false;
    currentFingerIndex = 0;
    countdown = GameScreen.kInitialCountdown;
    onCountdownChanged(countdown);
    onReset();
  }

  Color _getNextColor() {
    final usedColors = fingerColors.values.toSet();
    final availableColors = GameScreen.kGameColors.where((color) => !usedColors.contains(color)).toList();
    
    if (availableColors.isEmpty) {
      return GameScreen.kGameColors[Random().nextInt(GameScreen.kGameColors.length)];
    }
    
    return availableColors[Random().nextInt(availableColors.length)];
  }
} 