import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:random_finger_picker/managers/game_manager.dart';

void main() {
  late GameManager gameManager;
  
  setUp(() {
    gameManager = GameManager(
      onStartSelection: () {},
      onFinishSelection: () {},
      onReset: () {},
      onCountdownChanged: (_) {},
    );
  });

  test('should add finger and start timer with 2 fingers', () {
    // Add first finger
    gameManager.addFinger(1, const Offset(100, 100));
    expect(gameManager.fingers.length, 1);
    expect(gameManager.countdown, 5);

    // Add second finger
    gameManager.addFinger(2, const Offset(200, 200));
    expect(gameManager.fingers.length, 2);
    expect(gameManager.countdown, 5); // Timer should start
  });

  test('should remove finger and reset timer when less than 2 fingers', () {
    // Add two fingers
    gameManager.addFinger(1, const Offset(100, 100));
    gameManager.addFinger(2, const Offset(200, 200));
    expect(gameManager.fingers.length, 2);

    // Remove one finger
    gameManager.removeFinger(1);
    expect(gameManager.fingers.length, 1);
    expect(gameManager.countdown, 5); // Should reset countdown
  });

  test('should update finger position', () {
    // Add a finger
    const initialPosition = Offset(100, 100);
    const newPosition = Offset(150, 150);
    
    gameManager.addFinger(1, initialPosition);
    expect(gameManager.fingers[1], initialPosition);

    // Update position
    gameManager.updateFingerPosition(1, newPosition);
    expect(gameManager.fingers[1], newPosition);
  });

  test('should not add more than max fingers', () {
    // Add max fingers
    for (int i = 0; i < 10; i++) {
      gameManager.addFinger(i, Offset(i * 100.0, i * 100.0));
    }
    expect(gameManager.fingers.length, 10);

    // Try to add one more
    gameManager.addFinger(11, const Offset(1100, 1100));
    expect(gameManager.fingers.length, 10); // Should still be 10
  });

  test('should reset game state', () {
    // Setup some game state
    gameManager.addFinger(1, const Offset(100, 100));
    gameManager.addFinger(2, const Offset(200, 200));
    
    // Reset game
    gameManager.reset();
    
    expect(gameManager.fingers.isEmpty, true);
    expect(gameManager.fingerColors.isEmpty, true);
    expect(gameManager.selectedFinger, null);
    expect(gameManager.currentFingerIndex, 0);
    expect(gameManager.countdown, 5);
    expect(gameManager.isSelecting, false);
    expect(gameManager.isWinAnimationPlaying, false);
  });
} 