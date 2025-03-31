import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_screen.dart';
import '../components/finger_circle.dart';

class SelectionAnimation {
  static const Duration duration = Duration(milliseconds: 0); // Dummy
  static int _lastLoggedFinger = -1; // Son loglanan parmağı takip etmek için
  static bool _isFirstLog = true; // İlk log için kontrol
  static double _totalProgress = 0.0; // Toplam ilerlemeyi takip etmek için
  static int? _selectedFinger; // Seçilen parmağı takip etmek için
  static int _previousFingerNumber = -1; // Önceki parmak numarasını takip etmek için
  static DateTime? _startTime; // Animasyon başlangıç zamanını takip etmek için
  static double _lastUpdateTime = 0.0; // Son güncelleme zamanını takip etmek için
  
  // Seçilen parmağı dışarıdan erişilebilir yap
  static int? get selectedFinger => _selectedFinger;
  
  // Seçilen parmağı ayarla
  static void setSelectedFinger(int finger) {
    if (_selectedFinger == null) {
      _selectedFinger = finger;
      _startTime = DateTime.now(); // Animasyon başlangıç zamanını kaydet
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
    _startTime = null; // Başlangıç zamanını sıfırla
    _lastUpdateTime = 0.0; // Son güncelleme zamanını sıfırla
  }

  // İterasyon bilgilerini hesapla
  static Map<String, dynamic> _calculateIterationInfo(int currentIteration, double calculatedProgress, int totalFingers) {
    final currentFingerNumber = (currentIteration % totalFingers) + 1;
    final transitionText = _previousFingerNumber == -1 
        ? "Başlangıç: $currentFingerNumber" 
        : "$_previousFingerNumber ➔ $currentFingerNumber";
    
    // Sadece toplam iterasyon sayısına ulaşıldığında dur
    final shouldStop = currentIteration >= GameScreen.kTotalIterations;
    
    return {
      'currentFingerNumber': currentFingerNumber,
      'transitionText': transitionText,
      'shouldStop': shouldStop,
    };
  }

  // Log mesajını yazdır
  static void _printLog(int currentIteration, double calculatedProgress, String transitionText) {
    final iterationText = currentIteration >= GameScreen.kTotalIterations 
        ? '${currentIteration + 1}+' 
        : '${currentIteration + 1}';
    
    final elapsedMs = _startTime != null 
        ? DateTime.now().difference(_startTime!).inMilliseconds 
        : 0;
    
    print('İterasyon: $iterationText/${GameScreen.kTotalIterations} | '
          'İlerleme: ${calculatedProgress.toStringAsFixed(1)}% | '
          'Geçiş: $transitionText | '
          '🎯 Kazanan: $_selectedFinger | '
          'Geçen: ${elapsedMs}ms');
  }

  // İlk log mesajını yazdır
  static void _printInitialLog() {
    if (_isFirstLog && _selectedFinger != null) {
      print('🎯 Seçilen Parmak: $_selectedFinger');
    }
  }

  static Widget build({
    required Color color,
    required double baseScale,
    required bool isSelected,
    required double selectionProgress,
    required int fingerIndex,
    required int totalFingers,
    required int fingerNumber,
  }) {
    final baseOpacity = GameScreen.kDarkenedOpacity;
    
    // Mevcut iterasyonu hesapla
    final currentIteration = (_totalProgress * GameScreen.kTotalIterations).floor();
    
    // İlerleme hızını hesapla (0-1 arasında)
    double speedMultiplier;
    if (currentIteration >= GameScreen.kTotalIterations) {
      // Son aşamada çok yavaş ilerleme
      speedMultiplier = 0.0001;
    } else {
      // Başlangıçta hızlı, sonra yavaşlayan ilerleme
      final progressRatio = _totalProgress / 1.0;
      speedMultiplier = (1.0 - (progressRatio * 0.9)).clamp(GameScreen.kSpeedMultiplierMin, GameScreen.kSpeedMultiplierMax);
    }
    
    // Zaman bazlı ilerleme güncellemesi
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (_lastUpdateTime == 0.0) {
      _lastUpdateTime = currentTime;
    } else {
      final deltaTime = currentTime - _lastUpdateTime;
      _lastUpdateTime = currentTime;
      
      // İlerlemeyi güncelle - daha yavaş ilerleme için çarpanı azalttık
      _totalProgress = (_totalProgress + (deltaTime * GameScreen.kProgressDeltaTime * speedMultiplier)).clamp(0.0, 1.0);
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

    // Parmakları sırayla göster
    final currentFingerNumber = (currentIteration % totalFingers) + 1;
    final isLit = currentIteration >= GameScreen.kTotalIterations
        ? fingerIndex == (_selectedFinger! - 1) // Kazanan parmağı göster
        : currentIteration % totalFingers == fingerIndex;

    return _buildAnimatedFinger(color, baseScale, isLit, baseOpacity, fingerNumber);
  }

  // Animasyonlu parmak widget'ını oluştur
  static Widget _buildAnimatedFinger(Color color, double baseScale, bool isLit, double baseOpacity, int fingerNumber) {
    final borderOpacity = isLit 
        ? GameScreen.kBorderOpacity 
        : (GameScreen.kBorderOpacity * 0.3).clamp(0.0, GameScreen.kBorderOpacity);

    return FingerCircle(
      color: color,
      baseScale: baseScale,
      fingerNumber: fingerNumber,
      borderOpacity: borderOpacity,
      isLit: isLit,
    );
  }
}
