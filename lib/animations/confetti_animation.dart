import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../screens/game_screen.dart';

class ConfettiAnimation extends StatefulWidget {
  final ConfettiController controller;
  final bool isPlaying;

  const ConfettiAnimation({
    super.key,
    required this.controller,
    required this.isPlaying,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    if (widget.isPlaying) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _animationController.forward();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                // Üstten konfeti
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: widget.controller,
                    blastDirection: -pi / 2,
                    maxBlastForce: 6,
                    minBlastForce: 3,
                    emissionFrequency: 0.08,
                    numberOfParticles: 12,
                    gravity: 0.2,
                    shouldLoop: false,
                    particleDrag: 0.05,
                    colors: GameScreen.kGameColors,
                    child: const SizedBox(width: 1, height: 1),
                  ),
                ),
                // Soldan konfeti
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConfettiWidget(
                    confettiController: widget.controller,
                    blastDirection: 0,
                    maxBlastForce: 5,
                    minBlastForce: 2,
                    emissionFrequency: 0.08,
                    numberOfParticles: 8,
                    gravity: 0.2,
                    shouldLoop: false,
                    particleDrag: 0.05,
                    colors: GameScreen.kGameColors,
                    child: const SizedBox(width: 1, height: 1),
                  ),
                ),
                // Sağdan konfeti
                Align(
                  alignment: Alignment.centerRight,
                  child: ConfettiWidget(
                    confettiController: widget.controller,
                    blastDirection: pi,
                    maxBlastForce: 5,
                    minBlastForce: 2,
                    emissionFrequency: 0.08,
                    numberOfParticles: 8,
                    gravity: 0.2,
                    shouldLoop: false,
                    particleDrag: 0.05,
                    colors: GameScreen.kGameColors,
                    child: const SizedBox(width: 1, height: 1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 