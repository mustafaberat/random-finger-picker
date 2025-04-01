import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../animations/selection_animation.dart';

class GameManager {
  final Map<int, Offset> fingers = {};
  final Map<int, Color> fingerColors = {};
  Timer? _waitTimer;
  Timer? _selectionTimer;
  bool isSelecting = false;
  int? selectedFinger;
  int currentFingerIndex = 0;
  int countdown = GameConstants.kInitialCountdown;
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
    if (fingers.length >= GameConstants.kMaxFingers) return;
    
    // Find the next available number
    int nextKey = 1;
    while (fingers.containsKey(nextKey)) {
      nextKey++;
    }
    
    // Add the finger with the next available key
    fingers[nextKey] = position;
    // Get color based on the finger number (1 should get red at index 0)
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
    
    // Store the original mappings of position to color before removing
    final Map<Offset, Color> positionToColorMap = {};
    for (var entry in fingers.entries) {
      positionToColorMap[entry.value] = fingerColors[entry.key]!;
    }
    
    fingers.remove(fingerEntry.key);
    fingerColors.remove(fingerEntry.key);
    
    // Renumber remaining fingers starting from 1
    final remainingFingers = Map<int, Offset>.from(fingers);
    fingers.clear();
    fingerColors.clear();
    
    int newKey = 1;
    for (var entry in remainingFingers.entries) {
      fingers[newKey] = entry.value;
      // Use the original color associated with this position
      fingerColors[newKey] = positionToColorMap[entry.value]!;
      newKey++;
    }
    
    if (fingers.length < 2) {
      _waitTimer?.cancel();
      countdown = GameConstants.kInitialCountdown;
      onCountdownChanged(countdown);
    }
    
    if (isSelecting || isWinAnimationPlaying) {
      reset();
    }
  }

  void _resetWaitTimer() {
    if (fingers.length < 2 || isSelecting || isWinAnimationPlaying) return;
    
    _waitTimer?.cancel();
    countdown = GameConstants.kInitialCountdown;
    onCountdownChanged(countdown);
    
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (fingers.length < 2) {
        timer.cancel();
        countdown = GameConstants.kInitialCountdown;
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

    Future.delayed(GameConstants.kGameResetDelay, () {
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
    countdown = GameConstants.kInitialCountdown;
    onCountdownChanged(countdown);
    onReset();
  }

  Color _getNextColor() {
    // Create a set of already used colors
    final Set<Color> usedColors = fingerColors.values.toSet();
    
    // Try to find a color that isn't already in use
    for (Color color in GameConstants.kGameColors) {
      if (!usedColors.contains(color)) {
        return color;
      }
    }
    
    // If all colors are used (this should rarely happen with 10 colors and 10 max fingers),
    // fall back to getting a color based on the next key number
    int nextKey = 1;
    while (fingers.containsKey(nextKey)) {
      nextKey++;
    }
    
    int colorIndex = (nextKey - 1) % GameConstants.kGameColors.length;
    return GameConstants.kGameColors[colorIndex];
  }
} 