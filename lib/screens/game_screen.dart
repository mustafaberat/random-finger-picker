import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Oyun süreleri
  static const int kInitialCountdown = 2; // Geri sayım süresi (saniye)
  static const Duration kWinnerShowDuration = Duration(milliseconds: 15000); // Yenen rengi gösterme süresi
  static const Duration kGameResetDelay = Duration(seconds: 3); // Oyunu sıfırlama gecikmesi

  // Animasyon süreleri
  static const Duration kFingerTapAnimationDuration = Duration(milliseconds: 200);
  static const Duration kSelectionAnimationDuration = Duration(milliseconds: 300);
  static const Duration kWinAnimationDuration = Duration(milliseconds: 5000);
  static const Duration kPulseAnimationDuration = Duration(milliseconds: 1000);
  static const double fingerSize = 100.0;

  final Map<int, Offset> _fingers = {};
  final Map<int, Color> _fingerColors = {};
  final Map<int, AnimationController> _fingerAnimationControllers = {};
  Timer? _waitTimer;
  bool _isSelecting = false;
  int? _selectedFinger;
  late AnimationController _selectionController;
  late AnimationController _winAnimationController;
  late AnimationController _pulseController;
  int _currentFingerIndex = 0;
  int _countdown = kInitialCountdown;
  bool _isWinAnimationPlaying = false;

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(
      vsync: this,
      duration: kSelectionAnimationDuration,
    );

    _winAnimationController = AnimationController(
      vsync: this,
      duration: kWinnerShowDuration,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: kPulseAnimationDuration,
    )..repeat(reverse: true);

    _selectionController.addListener(() {
      if (_isSelecting) {
        setState(() {
          _currentFingerIndex = (_currentFingerIndex + 1) % _fingers.length;
        });
      }
    });

    // TODO: Remove this after testing - This is only for local testing purposes
    _addTestFingers();
  }

  // TODO: Remove this method after testing - This is only for local testing purposes
  void _addTestFingers() {
    final screenWidth = 300.0;
    final screenHeight = 500.0;
    
    _addFingerWithPosition(1, Offset(screenWidth * 0.3, screenHeight * 0.4));
    _addFingerWithPosition(2, Offset(screenWidth * 0.7, screenHeight * 0.4));
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    _selectionController.dispose();
    _winAnimationController.dispose();
    _pulseController.dispose();
    for (var controller in _fingerAnimationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addFingerWithPosition(int fingerKey, Offset position) {
    setState(() {
      _fingers[fingerKey] = position;
      _fingerColors[fingerKey] = _getRandomColor();
    });
    _addFingerAnimation(fingerKey, position);
    _resetWaitTimer();
  }

  void _resetWaitTimer() {
    _waitTimer?.cancel();
    if (_fingers.length >= 2) {
      setState(() {
        _countdown = kInitialCountdown;
      });
      _waitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          if (_countdown > 1) {
            _countdown--;
          } else {
            timer.cancel();
            _startSelection();
          }
        });
      });
    }
  }

  void _addFingerAnimation(int fingerKey, Offset position) {
    final controller = AnimationController(
      vsync: this,
      duration: kFingerTapAnimationDuration,
    );
    _fingerAnimationControllers[fingerKey] = controller;
    controller.forward();
  }

  void _removeFingerAnimation(int fingerKey) {
    _fingerAnimationControllers[fingerKey]?.reverse().then((_) {
      _fingerAnimationControllers[fingerKey]?.dispose();
      _fingerAnimationControllers.remove(fingerKey);
      setState(() {
        _fingers.remove(fingerKey);
        _fingerColors.remove(fingerKey);
      });
    });
  }

  void _startSelection() {
    if (_fingers.isEmpty) return;

    setState(() {
      _isSelecting = true;
      _countdown = kInitialCountdown;
    });

    void selectNext() {
      if (!_isSelecting) return;

      setState(() {
        _currentFingerIndex = (_currentFingerIndex + 1) % _fingers.length;
      });

      if (_currentFingerIndex < _fingers.length - 1) {
        _selectionController.forward(from: 0).then((_) {
          selectNext();
        });
      } else {
        _finishSelection();
      }
    }

    _selectionController.duration = kSelectionAnimationDuration;
    selectNext();
  }

  void _finishSelection() {
    _selectionController.stop();
    setState(() {
      _selectedFinger = _fingers.keys.elementAt(_currentFingerIndex);
      _isSelecting = false;
      _isWinAnimationPlaying = true;
    });

    _winAnimationController.forward(from: 0).then((_) {
      Future.delayed(kGameResetDelay, () {
        if (mounted) {
          setState(() {
            _fingers.clear();
            _fingerColors.clear();
            _selectedFinger = null;
            _currentFingerIndex = 0;
            _countdown = kInitialCountdown;
            _isWinAnimationPlaying = false;
          });
          _winAnimationController.reset();
        }
      });
    });
  }

  Color _getRandomColor() {
    final random = Random();
    
    // Önceden kullanılan renklerin HSL değerlerini al
    final existingHues = _fingerColors.values.map((color) {
      final hsl = HSLColor.fromColor(color);
      return hsl.hue;
    }).toList();

    // Yeni bir renk seç, ama var olan renklerden yeterince farklı olsun
    double newHue;
    do {
      newHue = random.nextDouble() * 360;
    } while (existingHues.any((hue) => (newHue - hue).abs() < 60)); // En az 60 derece fark olsun

    return HSLColor.fromAHSL(1, newHue, 0.8, 0.5).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _selectedFinger != null ? _fingerColors[_selectedFinger] : null;
    final winAnimation = _winAnimationController.drive(
      CurveTween(curve: Curves.easeInOut),
    );
    final pulseAnimation = _pulseController.drive(
      CurveTween(curve: Curves.easeInOut),
    );

    return Scaffold(
      body: GestureDetector(
        onPanDown: (details) {
          if (_isSelecting || _selectedFinger != null) return;
          
          final pointerCount = _fingers.length + 1;
          setState(() {
            _fingers[pointerCount] = details.localPosition;
            _fingerColors[pointerCount] = _getRandomColor();
          });
          _addFingerAnimation(pointerCount, details.localPosition);
          _resetWaitTimer();
        },
        onPanCancel: () {
          if (_isSelecting || _selectedFinger != null) return;
          if (_fingers.isNotEmpty) {
            _removeFingerAnimation(_fingers.keys.last);
          }
        },
        onPanEnd: (details) {
          if (_isSelecting || _selectedFinger != null) return;
          if (_fingers.isNotEmpty) {
            _removeFingerAnimation(_fingers.keys.last);
          }
        },
        child: AnimatedBuilder(
          animation: _winAnimationController,
          builder: (context, child) {
            final backgroundColor = _isWinAnimationPlaying && selectedColor != null
                ? Color.lerp(const Color(0xFF303030), selectedColor, _winAnimationController.value)
                : const Color(0xFF303030);
            
            return Container(
              color: backgroundColor,
              child: Stack(
                children: [
                  if (!_isSelecting && _selectedFinger == null && _fingers.length < 2)
                    const Center(
                      child: Text(
                        'PUT FINGER ON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontFamily: 'LuckiestGuy',
                        ),
                      ),
                    ),
                  if (!_isSelecting && _selectedFinger == null && _fingers.length >= 2)
                    Center(
                      child: Text(
                        _countdown.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontFamily: 'LuckiestGuy',
                        ),
                      ),
                    ),
                  ..._fingers.entries.map((entry) {
                    final isSelected = _isSelecting && 
                        _fingers.keys.toList()[_currentFingerIndex] == entry.key;
                    final animation = _fingerAnimationControllers[entry.key];
                    final isWinner = _selectedFinger == entry.key;

                    double finalScale = 1.0;
                    double opacity = 1.0;
                    double borderScale = 1.0;
                    double borderOpacity = 0.3;

                    if (_isWinAnimationPlaying) {
                      if (isWinner) {
                        finalScale = 20.0 * (1 + sin(winAnimation.value * pi)) * winAnimation.value;
                        opacity = 1.0;
                      } else {
                        opacity = 1.0 - (winAnimation.value);
                        finalScale = 1.0 - (winAnimation.value * 0.5);
                      }
                    } else if (isSelected && _isSelecting) {
                      // Seçim animasyonu - Border'ı büyütüp küçültme
                      final selectionProgress = _selectionController.value;
                      borderScale = 1.0 + (0.3 * sin(selectionProgress * pi * 2));
                      borderOpacity = 0.3 + (0.7 * _selectionController.value);
                    }

                    return Positioned(
                      left: entry.value.dx - fingerSize / 2,
                      top: entry.value.dy - fingerSize / 2,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          animation ?? const AlwaysStoppedAnimation(1.0),
                          if (_isSelecting) _selectionController,
                          if (_isWinAnimationPlaying) winAnimation,
                        ]),
                        builder: (context, child) {
                          final scale = (animation?.value ?? 1.0) * finalScale;
                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: Stack(
                                children: [
                                  if (isSelected && _isSelecting)
                                    Transform.scale(
                                      scale: borderScale,
                                      child: Container(
                                        width: fingerSize,
                                        height: fingerSize,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(borderOpacity),
                                            width: 6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Container(
                                    width: fingerSize,
                                    height: fingerSize,
                                    decoration: BoxDecoration(
                                      color: _fingerColors[entry.key],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _fingerColors[entry.key]!.withOpacity(0.3),
                                          blurRadius: 15,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }
} 