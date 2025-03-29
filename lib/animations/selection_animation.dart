import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class SelectionAnimation {
  static const int totalIterations = 100; // Toplam iterasyon sayısı
  static const Duration duration = Duration(milliseconds: 200); // Her iterasyon için süre
  static int _lastLoggedFinger = -1; // Son loglanan parmağı takip etmek için
  static bool _isFirstLog = true; // İlk log için kontrol
  static double _totalProgress = 0.0; // Toplam ilerlemeyi takip etmek için
  static int? _selectedFinger; // Seçilen parmağı takip etmek için
  
  // Seçilen parmağı dışarıdan erişilebilir yap
  static int? get selectedFinger => _selectedFinger;
  
  // Seçilen parmağı ayarla
  static void setSelectedFinger(int finger) {
    if (_selectedFinger == null) {
      _selectedFinger = finger;
      print('Seçilen Parmak: $_selectedFinger');
    }
  }
  
  // Seçilen parmağı sıfırla
  static void resetSelectedFinger() {
    _selectedFinger = null;
  }
  
  // Parmak widget'ını oluşturan yardımcı metod
  static Widget buildFingerWidget(Color color, double scale, bool isLit, double baseOpacity) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: GameScreen.kFingerSize * scale,
      height: GameScreen.kFingerSize * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
            height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
            decoration: BoxDecoration(
              color: color.withOpacity((GameScreen.kBorderOpacity * 0.3).clamp(0.0, 1.0)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity((GameScreen.kBorderOpacity * 0.6).clamp(0.0, 1.0)),
                width: GameScreen.kOuterBorderWidth * 0.8,
              ),
            ),
          ),
          Container(
            width: GameScreen.kFingerSize,
            height: GameScreen.kFingerSize,
            decoration: BoxDecoration(
              color: color.withOpacity(baseOpacity.clamp(0.0, 1.0)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity((GameScreen.kBorderOpacity * 0.7).clamp(0.0, 1.0)),
                width: GameScreen.kBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity((GameScreen.kGlowOpacity * 0.3).clamp(0.0, 1.0)),
                  blurRadius: GameScreen.kGlowBlurRadius * 0.5,
                  spreadRadius: GameScreen.kGlowSpreadRadius * 0.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget build({
    required Color color,
    required double scale,
    required bool isSelected,
    required double selectionProgress,
    required int fingerIndex,
    required int totalFingers,
    required int fingerNumber,
  }) {
    final baseOpacity = GameScreen.kDarkenedOpacity;
    
    // Her parmak değişiminde log yazdır
    final progressPerCircle = 1.0 / totalFingers;
    
    // Mevcut iterasyonu hesapla
    final currentIteration = (_totalProgress * totalIterations).floor();
    
    // Toplam ilerlemeyi güncelle
    _totalProgress = (_totalProgress + (selectionProgress * 0.01)).clamp(0.0, 1.0);
    
    // Eğer son iterasyona ulaşıldıysa, ilerlemeyi 1.0'a sabitle
    if (currentIteration >= totalIterations - 1) {
      _totalProgress = 1.0;
    }
    
    // İlerleme değerini hesapla (0-100 arasında)
    final calculatedProgress = (_totalProgress * 100).clamp(0.0, 100.0);
    
    // Sadece ilk log veya parmak değiştiğinde log yazdır
    if (_isFirstLog || currentIteration != _lastLoggedFinger) {
      print('İterasyon: ${currentIteration + 1}/$totalIterations | İlerleme: ${calculatedProgress.toStringAsFixed(1)}%');
      _lastLoggedFinger = currentIteration;
      _isFirstLog = false;
    }

    // Parmakları sırayla göster, son iterasyonda seçilen parmağı göster
    final isLit = currentIteration >= totalIterations - 1 
        ? fingerIndex == _selectedFinger 
        : currentIteration % totalFingers == fingerIndex;

    if (isLit) {
      // Improved glow and highlight effects
      final glowIntensity = (1.2 + sin(selectionProgress * pi * 2)) * 0.7;
      final highlightIntensity = 1.2 + (glowIntensity * 0.6);

      return Transform.scale(
        scale: scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              decoration: BoxDecoration(
                color: color.withOpacity((GameScreen.kBorderOpacity * glowIntensity * 0.6).clamp(0.0, 1.0)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity((GameScreen.kBorderOpacity * 0.8).clamp(0.0, 1.0)),
                  width: GameScreen.kOuterBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity((GameScreen.kGlowOpacity * glowIntensity * 1.2).clamp(0.0, 1.0)),
                    blurRadius: GameScreen.kGlowBlurRadius * 2.5,
                    spreadRadius: GameScreen.kGlowSpreadRadius * glowIntensity * 1.3,
                  ),
                ],
              ),
            ),
            Container(
              width: GameScreen.kFingerSize,
              height: GameScreen.kFingerSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(GameScreen.kHighlightBorderOpacity.clamp(0.0, 1.0)),
                  width: GameScreen.kBorderWidth * 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity((GameScreen.kGlowOpacity * highlightIntensity * 1.3).clamp(0.0, 1.0)),
                    blurRadius: GameScreen.kGlowBlurRadius * 1.5,
                    spreadRadius: GameScreen.kGlowSpreadRadius * 1.2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  fingerNumber.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: GameScreen.kFingerSize * 0.4,
                    fontFamily: GameScreen.kFontFamily,
                    fontWeight: FontWeight.bold,
                    height: 1,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Transform.scale(
        scale: scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
              decoration: BoxDecoration(
                color: color.withOpacity((GameScreen.kBorderOpacity * 0.3).clamp(0.0, 1.0)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity((GameScreen.kBorderOpacity * 0.6).clamp(0.0, 1.0)),
                  width: GameScreen.kOuterBorderWidth * 0.8,
                ),
              ),
            ),
            Container(
              width: GameScreen.kFingerSize,
              height: GameScreen.kFingerSize,
              decoration: BoxDecoration(
                color: color.withOpacity(baseOpacity.clamp(0.0, 1.0)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity((GameScreen.kBorderOpacity * 0.7).clamp(0.0, 1.0)),
                  width: GameScreen.kBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity((GameScreen.kGlowOpacity * 0.3).clamp(0.0, 1.0)),
                    blurRadius: GameScreen.kGlowBlurRadius * 0.5,
                    spreadRadius: GameScreen.kGlowSpreadRadius * 0.5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  fingerNumber.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: GameScreen.kFingerSize * 0.4,
                    fontFamily: GameScreen.kFontFamily,
                    fontWeight: FontWeight.bold,
                    height: 1,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
