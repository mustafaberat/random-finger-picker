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
    
    // Find the next available number
    int nextKey = 1;
    while (fingers.containsKey(nextKey)) {
      nextKey++;
    }
    
    fingers[nextKey] = position;
    fingerColors[nextKey] = _getNextColor();
    _resetWaitTimer();
  }

  void updateFingerPosition(int fingerKey, Offset position) {
    // Find the finger by position instead of key
    final fingerEntry = fingers.entries.firstWhere(
      (entry) => (entry.value - position).distance < 50, // 50 pixel tolerance
      orElse: () => MapEntry(-1, Offset.zero),
    );
    
    if (fingerEntry.key == -1 || isSelecting || isWinAnimationPlaying) return;
    fingers[fingerEntry.key] = position;
  }

  void removeFinger(int fingerKey) {
    // Find the finger by position instead of key
    final fingerEntry = fingers.entries.firstWhere(
      (entry) => entry.key == fingerKey,
      orElse: () => MapEntry(-1, Offset.zero),
    );
    
    if (fingerEntry.key == -1) return;
    
    // Don't remove debug mode fingers
    if (GameScreen.kDebugMode && fingerEntry.key <= 4) return;
    
    fingers.remove(fingerEntry.key);
    fingerColors.remove(fingerEntry.key);
    
    // Renumber remaining fingers starting from 1
    final remainingFingers = Map<int, Offset>.from(fingers);
    final remainingColors = Map<int, Color>.from(fingerColors);
    fingers.clear();
    fingerColors.clear();
    
    int newKey = 1;
    for (var entry in remainingFingers.entries) {
      fingers[newKey] = entry.value;
      fingerColors[newKey] = remainingColors[entry.key]!;
      newKey++;
    }
    
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
    
    // SelectionAnimation'ı önce resetle
    SelectionAnimation.resetSelectedFinger();
    
    // Rastgele parmak seç
    final fingerKeys = fingers.keys.toList();
    final random = Random();
    selectedFinger = fingerKeys[random.nextInt(fingerKeys.length)];
    
    // Seçilen parmağı ayarla
    SelectionAnimation.setSelectedFinger(selectedFinger!);
    
    // Seçilen parmağın index'ini bul
    currentFingerIndex = fingerKeys.indexOf(selectedFinger!);
    
    print('Manager choose winner finger: $selectedFinger (index: $currentFingerIndex)');
    
    _cycleFingers();
    onStartSelection();
  }

  void _cycleFingers() {
    if (!isSelecting || fingers.length < 2) {
      _selectionTimer?.cancel();
      return;
    }
    
    _selectionTimer?.cancel();
    
    // Timer'ı başlat - her 100ms'de bir kontrol et
    _selectionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!isSelecting || fingers.length < 2) {
        timer.cancel();
        return;
      }
      
      // SelectionAnimation'dan seçilen parmağı al
      selectedFinger = SelectionAnimation.selectedFinger;
      if (selectedFinger == null) return;  // Henüz seçilen parmak yoksa geri dön
      
      // Animasyonun bitip bitmediğini kontrol et
      if (SelectionAnimation.isAnimationCompleted) {
        timer.cancel();
        print("⭐ GameManager: Animation completed, calling finishSelection");
        finishSelection();
        return;
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
    
    // Clear all fingers and colors regardless of debug mode
    fingers.clear();
    fingerColors.clear();
    
    isSelecting = false;
    isWinAnimationPlaying = false;
    selectedFinger = null;  // Reset selected finger
    currentFingerIndex = 0;
    countdown = GameScreen.kInitialCountdown;
    onCountdownChanged(countdown);
    onReset();
  }

  Color _getNextColor() {
    // Get the next available number (which will be the index + 1)
    int nextKey = 1;
    while (fingers.containsKey(nextKey)) {
      nextKey++;
    }
    
    // Use the index (nextKey - 1) to get the color from the array
    // If we exceed the array length, wrap around using modulo
    return GameScreen.kGameColors[(nextKey - 1) % GameScreen.kGameColors.length];
  }
} 