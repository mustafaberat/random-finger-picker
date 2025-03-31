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

class GameScreen extends StatefulWidget {
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
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.cyan,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];
  
  // Game timing
  static const int kInitialCountdown = 1; //TODO: default 5, debug icin 2 yaptim
  static const Duration kWinnerShowDuration = Duration(milliseconds: 3000);
  static const Duration kGameResetDelay = Duration(seconds: 3);
  
  // Common animation properties
  static const double kMaxScale = 2.4;
  static const double kFinalScale = 1.2;
  static const double kPulseScaleFactor = 0.3;
  static const double kBorderWidth = 3.0;
  static const double kOuterBorderWidth = 4.0;
  static const double kOuterBorderScale = 1.30;
  static const double kBorderOpacity = 0.4;
  static const double kHighlightBorderOpacity = 0.8;
  static const double kDarkenedOpacity = 0.5;
  static const double kGlowBlurRadius = 10.0;
  static const double kGlowSpreadRadius = 5.0;
  static const double kGlowOpacity = 0.3;
  
  // Selection animation properties
  static const int kTotalIterations = 20;
  static const double kSpeedMultiplierMin = 0.1;
  static const double kSpeedMultiplierMax = 1.0;
  static const double kProgressDeltaTime = 0.5;
  
  // Finger tap animation properties
  static const Duration kTapDuration = Duration(milliseconds: 300);
  static const double kTapExpandPhase = 0.7; // 0-70% of animation
  static const double kTapShrinkPhase = 0.3; // 70-100% of animation
  
  // Winner animation properties
  static const double kInitialPause = 0.2;
  static const Duration kWinDuration = Duration(milliseconds: 4000);
  static const Duration kPulseDuration = Duration(milliseconds: 1000);
  static const Duration kConfettiDuration = Duration(seconds: 5);
  static const double kWinnerMaxScale = 8.0;
  static const double kConfettiStartProgress = 0.8;
  static const double kConfettiMultiplier = 5.0;
  
  // Debug mode
  static const bool kDebugMode = true;

  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
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
    _confettiController = ConfettiController(duration: GameScreen.kConfettiDuration);
    
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
    
    // SelectionAnimation sınıfını resetleyelim
    SelectionAnimation.resetSelectedFinger();
    // Sonra kazanan parmağı ayarlayalım
    SelectionAnimation.setSelectedFinger(_gameManager.selectedFinger!);
    
    _animationManager.startSelectionAnimation();
  }

  void _onFinishSelection() {
    print("🎊 Finish selection - Starting win animation for finger: ${_gameManager.selectedFinger}");
    setState(() {
      // Kazanan parmak UI'da güncellendi
    });
    
    // Win animasyonu için biraz bekleyelim
    Future.delayed(Duration(milliseconds: 100), () {
      _animationManager.startWinAnimation();
      _confettiController.play();
      print("🎉 Win animation started for finger: ${_gameManager.selectedFinger}");
    });
  }

  void _onSelectionComplete() {
    print("🌟 Selection completed - Winning finger: ${_gameManager.selectedFinger}");
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
                                  selectionProgress: _animationManager.selectionController.value,
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
                                  isWinAnimationPlaying: _gameManager.isWinAnimationPlaying,
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
                                    fontFamily: GameScreen.kFontFamily,
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
                            fontFamily: GameScreen.kFontFamily,
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