import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../animations/finger_tap_animation.dart';
import '../animations/winner_animation.dart';
import '../animations/selection_animation.dart';
import '../managers/game_manager.dart';
import '../managers/animation_manager.dart';
import '../services/localization_service.dart';

class GameScreen extends StatefulWidget {
  // Global constants
  static const double kFingerSize = 100.0;
  static const Color kBackgroundColor = Color(0xFF202121);
  static const int kMaxFingers = 10; // Maximum number of fingers allowed
  
  // Game colors
  static const List<Color> kGameColors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.cyan,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];
  
  // Game timing
  static const int kInitialCountdown = 5;
  static const Duration kWinnerShowDuration = Duration(milliseconds: 3000);
  static const Duration kGameResetDelay = Duration(seconds: 3);
  
  // Animation durations
  static const Duration kSelectionInterval = Duration(milliseconds: 200);
  static const Duration kSelectionDuration = Duration(milliseconds: 2000);
  static const Duration kTapDuration = Duration(milliseconds: 300);
  static const Duration kWinDuration = Duration(milliseconds: 4000);
  static const Duration kPulseDuration = Duration(milliseconds: 1000);
  static const Duration kConfettiDuration = Duration(seconds: 5);
  
  // Animation scales
  static const double kMaxScale = 2.4;
  static const double kFinalScale = 1.2;
  static const double kPulseScaleFactor = 0.3;
  
  // Circle appearance
  static const double kBorderWidth = 3.0;
  static const double kOuterBorderWidth = 4.0;
  static const double kOuterBorderScale = 1.30;
  static const double kBorderOpacity = 0.4;
  static const double kHighlightBorderOpacity = 0.8;
  static const double kDarkenedOpacity = 0.5;
  
  // Glow effects
  static const double kGlowBlurRadius = 10.0;
  static const double kGlowSpreadRadius = 5.0;
  static const double kGlowOpacity = 0.3;
  static const bool kDebugMode = true; // Debug mode flag

  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Oyun süreleri
  static const int kInitialCountdown = 2; // Geri sayım süresi (saniye)
  static const Duration kWinnerShowDuration = Duration(milliseconds: 3000); // Yenen rengi gösterme süresi
  static const Duration kGameResetDelay = Duration(seconds: 1); // Oyunu sıfırlama gecikmesi

  // Animasyon süreleri
  static const Duration kSelectionAnimationDuration = SelectionAnimation.duration;
  static const Duration kFingerTapAnimationDuration = FingerTapAnimation.duration;
  static const Duration kWinAnimationDuration = WinnerAnimation.duration;
  static const Duration kPulseAnimationDuration = Duration(milliseconds: 1000);

  late GameManager _gameManager;
  late AnimationManager _animationManager;
  late ConfettiController _confettiController;
  bool _isInteractionEnabled = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    
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
    if (GameScreen.kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final size = MediaQuery.of(context).size;
        final centerX = size.width / 2;
        final centerY = size.height / 2;
        final spacing = 300.0;

        // Add 4 fingers in a cross pattern
        _gameManager.addFinger(1, Offset(centerX, centerY - spacing));
        _gameManager.addFinger(2, Offset(centerX + spacing, centerY));
        _gameManager.addFinger(3, Offset(centerX, centerY + spacing));
        _gameManager.addFinger(4, Offset(centerX - spacing, centerY));

        // Add animations for debug fingers
        _animationManager.addFingerAnimation(1);
        _animationManager.addFingerAnimation(2);
        _animationManager.addFingerAnimation(3);
        _animationManager.addFingerAnimation(4);
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
    _animationManager.startSelectionAnimation();
  }

  void _onFinishSelection() {
    setState(() {});
    _animationManager.startWinAnimation();
    _confettiController.play();
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
      backgroundColor: GameScreen.kBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            AnimatedBuilder(
              animation: _animationManager.winAnimationController,
              builder: (context, child) {
                final backgroundColor = _gameManager.isWinAnimationPlaying && selectedColor != null
                    ? Color.lerp(GameScreen.kBackgroundColor, selectedColor, _animationManager.winAnimationController.value)
                    : GameScreen.kBackgroundColor;
                
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: backgroundColor ?? GameScreen.kBackgroundColor,
                  child: Stack(
                    children: [
                      // Fingers
                      ..._gameManager.fingers.entries.map((entry) {
                        final fingerIndex = _gameManager.fingers.keys.toList().indexOf(entry.key);
                        final isSelected = _gameManager.isSelecting && 
                            _gameManager.currentFingerIndex == fingerIndex;
                        final animation = _animationManager.fingerAnimationControllers[entry.key];
                        final isWinner = _gameManager.selectedFinger == entry.key;
                        final fingerColor = _gameManager.fingerColors[entry.key];

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
                          left: entry.value.dx - (GameScreen.kFingerSize / 2),
                          top: entry.value.dy - (GameScreen.kFingerSize / 2),
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              animation ?? const AlwaysStoppedAnimation(1.0),
                              if (_gameManager.isSelecting) _animationManager.selectionController,
                              if (_gameManager.isWinAnimationPlaying) winAnimation,
                            ]),
                            builder: (context, child) {
                              final baseScale = (animation?.value ?? 1.0) * finalScale;
                              final tapProgress = animation?.value ?? 1.0;

                              if (_gameManager.isWinAnimationPlaying) {
                                if (isWinner) {
                                  return Transform.scale(
                                    scale: 1.0,
                                    child: WinnerAnimation.build(
                                      color: fingerColor,
                                      progress: winAnimation.value,
                                      baseScale: baseScale,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }

                              if (_gameManager.isSelecting) {
                                return SelectionAnimation.build(
                                  color: fingerColor,
                                  scale: baseScale,
                                  isSelected: isSelected,
                                  selectionProgress: _animationManager.selectionController.value,
                                  fingerIndex: fingerIndex,
                                  totalFingers: _gameManager.fingers.length,
                                );
                              }

                              return Opacity(
                                opacity: opacity,
                                child: FingerTapAnimation.build(
                                  color: fingerColor,
                                  scale: baseScale,
                                  tapProgress: tapProgress,
                                  isSelecting: _gameManager.isSelecting,
                                  isWinAnimationPlaying: _gameManager.isWinAnimationPlaying,
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
            if (_gameManager.isWinAnimationPlaying) ...[
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  maxBlastForce: 3,
                  minBlastForce: 1,
                  emissionFrequency: 0.03,
                  numberOfParticles: 20,
                  gravity: 0.3,
                  shouldLoop: false,
                  particleDrag: 0.05,
                  colors: GameScreen.kGameColors,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 0,
                  maxBlastForce: 3,
                  minBlastForce: 1,
                  emissionFrequency: 0.03,
                  numberOfParticles: 20,
                  gravity: 0.3,
                  shouldLoop: false,
                  particleDrag: 0.05,
                  colors: GameScreen.kGameColors,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi,
                  maxBlastForce: 3,
                  minBlastForce: 1,
                  emissionFrequency: 0.03,
                  numberOfParticles: 20,
                  gravity: 0.3,
                  shouldLoop: false,
                  particleDrag: 0.05,
                  colors: GameScreen.kGameColors,
                ),
              ),
            ],

            // Gesture Detector and UI
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: _isInteractionEnabled ? (event) {
                if (_gameManager.isSelecting || 
                    _gameManager.selectedFinger != null ||
                    _gameManager.fingers.length >= GameScreen.kMaxFingers) {
                  return;
                }
                
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localPosition = renderBox.globalToLocal(event.position);
                
                // Center the circle exactly on the touch point
                final adjustedPosition = Offset(
                  localPosition.dx,
                  localPosition.dy,
                );
                
                _gameManager.addFinger(event.pointer, adjustedPosition);
                _animationManager.addFingerAnimation(event.pointer);
                setState(() {});
              } : null,
              onPointerMove: _isInteractionEnabled ? (event) {
                if (_gameManager.isSelecting || 
                    _gameManager.selectedFinger != null ||
                    !_gameManager.fingers.containsKey(event.pointer)) return;
                
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final localPosition = renderBox.globalToLocal(event.position);
                
                // Center the circle exactly on the touch point
                final adjustedPosition = Offset(
                  localPosition.dx,
                  localPosition.dy,
                );
                
                _gameManager.updateFingerPosition(event.pointer, adjustedPosition);
                setState(() {});
              } : null,
              onPointerUp: _isInteractionEnabled ? (event) {
                if (_gameManager.isSelecting || _gameManager.selectedFinger != null) return;
                if (_gameManager.fingers.containsKey(event.pointer)) {
                  _gameManager.removeFinger(event.pointer);
                  _animationManager.removeFingerAnimation(event.pointer);
                  setState(() {});
                }
              } : null,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    if (!_gameManager.isSelecting && _gameManager.selectedFinger == null && _gameManager.fingers.length < 2)
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
                                  LocalizationService.instance.getString('put_fingers_on', context),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'LuckiestGuy',
                                    height: 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (!_gameManager.isSelecting && _gameManager.selectedFinger == null && _gameManager.fingers.length >= 2)
                      Center(
                        child: Text(
                          _gameManager.countdown.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontFamily: 'LuckiestGuy',
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