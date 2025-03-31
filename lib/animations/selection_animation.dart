import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';

class SelectionAnimation {
  static const int totalIterations = 100; // Toplam iterasyon sayısı
  static const Duration duration = Duration(milliseconds: 2000); // Her iterasyon için süre
  static int _lastLoggedFinger = -1; // Son loglanan parmağı takip etmek için
  static bool _isFirstLog = true; // İlk log için kontrol
  static double _totalProgress = 0.0; // Toplam ilerlemeyi takip etmek için
  static int? _selectedFinger; // Seçilen parmağı takip etmek için
  static int _previousFingerNumber = -1; // Önceki parmak numarasını takip etmek için
  
  // Seçilen parmağı dışarıdan erişilebilir yap
  static int? get selectedFinger => _selectedFinger;
  
  // Seçilen parmağı ayarla
  static void setSelectedFinger(int finger) {
    if (_selectedFinger == null) {
      _selectedFinger = finger;
      print('Seçilen Parmak: $finger');
    }
  }
  
  // Seçilen parmağı sıfırla
  static void resetSelectedFinger() {
    _selectedFinger = null;
    _isFirstLog = true;
    _lastLoggedFinger = -1;
    _previousFingerNumber = -1;
    _totalProgress = 0.0;
  }

  // İterasyon bilgilerini hesapla
  static Map<String, dynamic> _calculateIterationInfo(int currentIteration, double calculatedProgress, int totalFingers) {
    final currentFingerNumber = (currentIteration % totalFingers) + 1;
    final transitionText = _previousFingerNumber == -1 
        ? "Başlangıç: $currentFingerNumber" 
        : "$_previousFingerNumber ➔ $currentFingerNumber";
    
    // 100 iterasyon sonrası kazanan parmağa ulaşıldığında durmalı
    final shouldStop = currentIteration >= totalIterations && currentFingerNumber == _selectedFinger;
    
    return {
      'currentFingerNumber': currentFingerNumber,
      'transitionText': transitionText,
      'shouldStop': shouldStop,
    };
  }

  // Log mesajını yazdır
  static void _printLog(int currentIteration, double calculatedProgress, String transitionText) {
    final iterationText = currentIteration >= totalIterations 
        ? '${currentIteration + 1}+' 
        : '${currentIteration + 1}';
    
    print('İterasyon: $iterationText/$totalIterations | '
          'İlerleme: ${calculatedProgress.toStringAsFixed(1)}% | '
          'Geçiş: $transitionText | '
          '🎯 Kazanan: $_selectedFinger');
  }

  // İlk log mesajını yazdır
  static void _printInitialLog() {
    if (_isFirstLog && _selectedFinger != null) {
      print('🎯 Seçilen Parmak: $_selectedFinger');
    }
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
    
    // Mevcut iterasyonu hesapla
    final currentIteration = (_totalProgress * totalIterations).floor();
    
    // Toplam ilerlemeyi güncelle (100 iterasyon sonrası yavaşlat)
    if (currentIteration >= totalIterations) {
      _totalProgress = (_totalProgress + (selectionProgress * 0.005)).clamp(0.0, 2.0); // Yavaşlatılmış ilerleme
    } else {
      _totalProgress = (_totalProgress + (selectionProgress * 0.01)).clamp(0.0, 2.0);
    }
    
    // İlerleme değerini hesapla (0-100 arasında)
    final calculatedProgress = (_totalProgress * 100).clamp(0.0, 100.0);
    
    // Sadece ilk log veya parmak değiştiğinde log yazdır
    if (_isFirstLog || currentIteration != _lastLoggedFinger) {
      _printInitialLog();

      final info = _calculateIterationInfo(currentIteration, calculatedProgress, totalFingers);
      
      if (!info['shouldStop']) {
        _printLog(currentIteration, calculatedProgress, info['transitionText']);
        
        _lastLoggedFinger = currentIteration;
        _previousFingerNumber = info['currentFingerNumber'];
        _isFirstLog = false;
      }
    }

    // Parmakları sırayla göster, 100 iterasyon sonrası kazanan parmağa gelene kadar devam et
    final currentFingerNumber = (currentIteration % totalFingers) + 1;
    final isLit = currentIteration >= totalIterations
        ? fingerIndex == (_selectedFinger! - 1) // Kazanan parmağı göster
        : currentIteration % totalFingers == fingerIndex;

    return _buildAnimatedFinger(color, scale, isLit, baseOpacity, fingerNumber);
  }

  // Animasyonlu parmak widget'ını oluştur
  static Widget _buildAnimatedFinger(Color color, double scale, bool isLit, double baseOpacity, int fingerNumber) {
    final borderOpacity = isLit 
        ? GameScreen.kBorderOpacity 
        : (GameScreen.kBorderOpacity * 0.3).clamp(0.0, GameScreen.kBorderOpacity);

    return Transform.scale(
      scale: scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildOuterCircle(color, borderOpacity),
          _buildMainCircle(color, isLit, baseOpacity, borderOpacity, fingerNumber),
        ],
      ),
    );
  }

  // Dış çember widget'ını oluştur
  static Widget _buildOuterCircle(Color color, double borderOpacity) {
    return Container(
      width: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
      height: GameScreen.kFingerSize * GameScreen.kOuterBorderScale,
      decoration: BoxDecoration(
        color: color.withOpacity(borderOpacity * 0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  // Ana çember widget'ını oluştur
  static Widget _buildMainCircle(Color color, bool isLit, double baseOpacity, double borderOpacity, int fingerNumber) {
    return Container(
      width: GameScreen.kFingerSize,
      height: GameScreen.kFingerSize,
      decoration: BoxDecoration(
        color: isLit ? color : color.withOpacity(baseOpacity),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(borderOpacity),
          width: GameScreen.kBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(GameScreen.kGlowOpacity * (isLit ? 0.7 : 0.3)),
            blurRadius: GameScreen.kGlowBlurRadius,
            spreadRadius: GameScreen.kGlowSpreadRadius * (isLit ? 0.7 : 0.3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          fingerNumber.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: GameScreen.kFingerSize * 0.4,
            fontFamily: GameScreen.kFontFamily,
            fontWeight: FontWeight.bold,
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
    );
  }
}
