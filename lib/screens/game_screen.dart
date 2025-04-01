import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../animations/finger_tap_animation.dart';
import '../animations/winner_animation.dart';
import '../animations/selection_animation.dart';
import '../animations/confetti_animation.dart';
import '../managers/game_manager.dart';
import '../managers/animation_manager.dart';
import '../services/localization_service.dart';
import '../constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Animasyon süreleri
  static const Duration kSelectionAnimationDuration =
      SelectionAnimation.duration;
  static const Duration kFingerTapAnimationDuration =
      FingerTapAnimation.duration;
  static const Duration kWinAnimationDuration = WinnerAnimation.duration;
  static const Duration kPulseAnimationDuration = Duration(milliseconds: 1000);

  late GameManager _gameManager;
  late AnimationManager _animationManager;
  late ConfettiController _confettiController;
  bool _isInteractionEnabled = true;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: GameConstants.kConfettiDuration);

    _animationManager = AnimationManager(
      vsync: this,
      onSelectionComplete: _onSelectionComplete,
    );

    _gameManager = GameManager(
      onStartSelection: _onStartSelection,
      onFinishSelection: _onFinishSelection,
      onReset: _onReset,
      onCountdownChanged: _onCountdownChanged,
    );

    // Add debug fingers if in debug mode
    if (GameConstants.kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final size = MediaQuery.of(context).size;
        final centerX = size.width / 2;
        final centerY = size.height / 2;
        final radius = 300.0;

        // Add 10 fingers in a circular pattern
        for (int i = 1; i <= 10; i++) {
          final angle = (i - 1) * (2 * pi / 12);
          final x = centerX + radius * cos(angle);
          final y = centerY + radius * sin(angle);
          _gameManager.addFinger(i, Offset(x, y));
          _animationManager.addFingerAnimation(i);
        }
      });
    }
  }

  @override
  void dispose() {
    _gameManager.dispose();
    _animationManager.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onStartSelection() {
    setState(() {
      _isInteractionEnabled = false;
    });

    // SelectionAnimation sınıfını resetleyelim
    SelectionAnimation.resetSelectedFinger();
    // Sonra kazanan parmağı ayarlayalım
    SelectionAnimation.setSelectedFinger(_gameManager.selectedFinger!);

    _animationManager.startSelectionAnimation();
  }

  void _onFinishSelection() {
    setState(() {
      // Kazanan parmak UI'da güncellendi
    });

    // Win animasyonu için biraz bekleyelim
    Future.delayed(Duration(milliseconds: 100), () {
      _animationManager.startWinAnimation();
      _confettiController.play();
    });
  }

  void _onSelectionComplete() {
    _gameManager.finishSelection();
  }

  void _onReset() {
    setState(() {
      _isInteractionEnabled = true;
    });
    _animationManager.reset();
    _confettiController.stop();
  }

  void _onCountdownChanged(int value) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _gameManager.selectedFinger != null
        ? _gameManager.fingerColors[_gameManager.selectedFinger]
        : null;
    final winAnimation = _animationManager.getWinAnimation();

    return Scaffold(
      backgroundColor: GameConstants.kBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            AnimatedBuilder(
              animation: _animationManager.winAnimationController,
              builder: (context, child) {
                final backgroundColor =
                    _gameManager.isWinAnimationPlaying && selectedColor != null
                        ? Color.lerp(GameConstants.kBackgroundColor, selectedColor,
                            _animationManager.winAnimationController.value)
                        : GameConstants.kBackgroundColor;

                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: backgroundColor ?? GameConstants.kBackgroundColor,
                  child: Stack(
                    children: [
                      // Fingers
                      ..._gameManager.fingers.entries.map((entry) {
                        final fingerIndex = _gameManager.fingers.keys
                            .toList()
                            .indexOf(entry.key);
                        final isSelected = _gameManager.isSelecting &&
                            _gameManager.currentFingerIndex == fingerIndex;
                        final animation = _animationManager
                            .fingerAnimationControllers[entry.key];
                        final isWinner =
                            _gameManager.selectedFinger == entry.key;
                        final fingerColor =
                            _gameManager.fingerColors[entry.key];

                        if (fingerColor == null) return const SizedBox.shrink();

                        double finalScale = 1.0;
                        double opacity = 1.0;

                        if (_gameManager.isWinAnimationPlaying) {
                          if (isWinner) {
                            opacity = 1.0;
                          } else {
                            opacity = 0.0;
                            finalScale = 0.0;
                          }
                        }

                        return Positioned(
                          left: entry.value.dx - (GameConstants.kFingerSize / 2),
                          top: entry.value.dy - (GameConstants.kFingerSize / 2),
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              animation ?? const AlwaysStoppedAnimation(1.0),
                              if (_gameManager.isSelecting)
                                _animationManager.selectionController,
                              if (_gameManager.isWinAnimationPlaying)
                                winAnimation,
                            ]),
                            builder: (context, child) {
                              final baseScale =
                                  (animation?.value ?? 1.0) * finalScale;
                              final tapProgress = animation?.value ?? 1.0;

                              if (_gameManager.isWinAnimationPlaying) {
                                if (isWinner) {
                                  return Transform.scale(
                                    scale: 1.0,
                                    child: WinnerAnimation.create(
                                      color: fingerColor,
                                      progress: winAnimation.value,
                                      baseScale: baseScale,
                                      fingerNumber: entry.key,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }

                              if (_gameManager.isSelecting) {
                                return SelectionAnimation.build(
                                  color: fingerColor,
                                  baseScale: baseScale,
                                  isSelected: isSelected,
                                  selectionProgress: _animationManager
                                      .selectionController.value,
                                  fingerIndex: fingerIndex,
                                  totalFingers: _gameManager.fingers.length,
                                  fingerNumber: fingerIndex + 1,
                                );
                              }

                              return Opacity(
                                opacity: opacity,
                                child: FingerTapAnimation.build(
                                  color: fingerColor,
                                  tapProgress: tapProgress,
                                  isSelecting: _gameManager.isSelecting,
                                  isWinAnimationPlaying:
                                      _gameManager.isWinAnimationPlaying,
                                  fingerNumber: entry.key,
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),

            // Confetti
            ConfettiAnimation(
              controller: _confettiController,
              isPlaying: _gameManager.isWinAnimationPlaying,
            ),

            // Gesture Detector and UI
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: _isInteractionEnabled
                  ? (event) {
                      if (_gameManager.isSelecting ||
                          _gameManager.selectedFinger != null ||
                          _gameManager.fingers.length >=
                              GameConstants.kMaxFingers) {
                        return;
                      }

                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final localPosition =
                          renderBox.globalToLocal(event.position);

                      // Center the circle exactly on the touch point
                      final adjustedPosition = Offset(
                        localPosition.dx,
                        localPosition.dy,
                      );

                      // Find the next available number for the finger
                      int nextKey = 1;
                      while (_gameManager.fingers.containsKey(nextKey)) {
                        nextKey++;
                      }

                      _gameManager.addFinger(nextKey, adjustedPosition);
                      _animationManager.addFingerAnimation(nextKey);
                      setState(() {});
                    }
                  : null,
              onPointerMove: _isInteractionEnabled
                  ? (event) {
                      if (_gameManager.isSelecting ||
                          _gameManager.selectedFinger != null) return;

                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final localPosition =
                          renderBox.globalToLocal(event.position);

                      // Find the closest finger to the pointer position
                      final fingerEntry =
                          _gameManager.fingers.entries.firstWhere(
                        (entry) =>
                            (entry.value - localPosition).distance <
                            50, // 50 pixel tolerance
                        orElse: () => MapEntry(-1, Offset.zero),
                      );

                      if (fingerEntry.key != -1) {
                        // Center the circle exactly on the touch point
                        final adjustedPosition = Offset(
                          localPosition.dx,
                          localPosition.dy,
                        );

                        _gameManager.updateFingerPosition(
                            fingerEntry.key, adjustedPosition);
                        setState(() {});
                      }
                    }
                  : null,
              onPointerUp: _isInteractionEnabled
                  ? (event) {
                      if (_gameManager.isSelecting ||
                          _gameManager.selectedFinger != null) return;

                      // Find the finger by position
                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final localPosition =
                          renderBox.globalToLocal(event.position);

                      // Find the closest finger to the pointer up position
                      final fingerEntry =
                          _gameManager.fingers.entries.firstWhere(
                        (entry) =>
                            (entry.value - localPosition).distance <
                            50, // 50 pixel tolerance
                        orElse: () => MapEntry(-1, Offset.zero),
                      );

                      if (fingerEntry.key != -1) {
                        _gameManager.removeFinger(fingerEntry.key);
                        _animationManager
                            .removeFingerAnimation(fingerEntry.key);
                        setState(() {});
                      }
                    }
                  : null,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    if (!_gameManager.isSelecting &&
                        _gameManager.selectedFinger == null &&
                        _gameManager.fingers.length < 2)
                      Align(
                        alignment: const Alignment(0, -0.3),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final maxWidth = constraints.maxWidth * 0.8;
                            return SizedBox(
                              width: maxWidth,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  LocalizationService.instance
                                      .getString('put_fingers_on', context),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: GameConstants.kFontFamily,
                                    height: 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (!_gameManager.isSelecting &&
                        _gameManager.selectedFinger == null &&
                        _gameManager.fingers.length >= 2)
                      Center(
                        child: Text(
                          _gameManager.countdown.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontFamily: GameConstants.kFontFamily,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


