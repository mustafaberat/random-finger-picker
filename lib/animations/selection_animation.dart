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
  
  // Animasyonun tamamlanıp tamamlanmadığını kontrol et
  static bool _isAnimationStopped = false;
  static bool get isAnimationCompleted => _isAnimationStopped;
  
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
    _isAnimationStopped = false; // Animasyon durma flag'ini resetle
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
    
    // Başlangıçta initial log yaz
    if (_isFirstLog) {
      _printInitialLog();
      _isFirstLog = false;
    }
    
    // Zaman bazlı ilerleme güncellemesi
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (_lastUpdateTime == 0.0) {
      _lastUpdateTime = currentTime;
    } else {
      final deltaTime = currentTime - _lastUpdateTime;
      _lastUpdateTime = currentTime;
      
      // İlerlemeyi DAHA HIZLI güncelle - 3x hızlandırılmış (sabit hız)
      if (!_isAnimationStopped) {
        final oldProgress = _totalProgress;
        _totalProgress += deltaTime * 3.0;
        
        // Progress'i her 25% artışında loglayalım
        if ((_totalProgress * 4).floor() > (oldProgress * 4).floor()) {
          final iterCount = (_totalProgress * totalFingers).floor();
          final fingerNum = (iterCount % totalFingers) + 1;
          print('📈 Progress update: ${_totalProgress.toStringAsFixed(2)} | Iter: $iterCount | Finger: $fingerNum');
        }
      }
    }
    
    // Mevcut iterasyonu hesapla (kaçıncı parmaktayız)
    final currentIteration = (_totalProgress * totalFingers).floor(); 
    final currentFingerNumber = (currentIteration % totalFingers) + 1;
    
    // Minimum iterasyon tamamlandı mı kontrol et
    // 1 tur = totalFingers adımsayısı
    final completedFullTurns = currentIteration ~/ totalFingers;
    final minimumIterationsCompleted = completedFullTurns >= GameScreen.kTotalIterations;
    
    // Parmak değiştiğinde log yazdır
    if (currentIteration != _lastLoggedFinger) {
      final transitionText = _previousFingerNumber == -1 
          ? "Başlangıç: $currentFingerNumber" 
          : "$_previousFingerNumber ➔ $currentFingerNumber";
      
      // Son Tur Kuralı: Seçilen parmağa gelinmiş mi?
      final isOnSelectedFinger = _selectedFinger != null && currentFingerNumber == _selectedFinger;
      
      // Duruş koşulları: Minimum iterasyonlar tamamlanmış VE son turda kazanan parmağa gelinmiş olmalı
      final shouldStop = minimumIterationsCompleted && isOnSelectedFinger;
      
      // Detaylı durum bilgisi loglayalım
      print('▶️ F${currentFingerNumber} | Iter: $currentIteration | '
            'Tur: ${completedFullTurns + 1}/${GameScreen.kTotalIterations} | '
            'Progress: ${(_totalProgress * 100).toStringAsFixed(1)}% | '
            'MinIter: $minimumIterationsCompleted | OnWinner: $isOnSelectedFinger | '
            'ShouldStop: $shouldStop | Target: $_selectedFinger');
      
      if (shouldStop) {
        // Animasyonu durdur, kazanan parmağı göster
        print('🏆 DURUŞ: Kazanan Parmak: $_selectedFinger | Tur: ${completedFullTurns + 1}');
        _lastLoggedFinger = currentIteration;
        _previousFingerNumber = currentFingerNumber;
        
        // Bu kritik! Animasyonu tamamen durduruyoruz
        _isAnimationStopped = true;
        print('🛑 Animation stopped: _isAnimationStopped set to true');
      } else {
        // Devam et, normal log yazdır
        print('🔄 İterasyon: ${currentIteration + 1} | '
              'Geçiş: $transitionText | '
              'Tur: ${completedFullTurns + 1}/${GameScreen.kTotalIterations} | '
              '🎯 Kazanan: $_selectedFinger');
        
        _lastLoggedFinger = currentIteration;
        _previousFingerNumber = currentFingerNumber;
      }
    }
    
    // İstenilen parmak mı gösteriliyor?
    bool isLit;
    if (_isAnimationStopped) {
      // Animasyon durdu, sadece kazanan parmağı göster
      isLit = fingerIndex == (_selectedFinger! - 1);
    } else {
      // Normal sırayla parmakları göster
      isLit = currentIteration % totalFingers == fingerIndex;
    }
    
    // Debug - hangi parmağın gösterildiğini logla
    // İlk kez gösterilen parmak değiştiğinde logla
    if (isLit && (fingerIndex + 1) != _previousFingerNumber) {
      print('HIGHLIGHT - Gösterilen Parmak: ${fingerIndex + 1} | Progress: ${_totalProgress.toStringAsFixed(2)}');
    }

    return _buildAnimatedFinger(color, baseScale, isLit, baseOpacity, fingerNumber);
  }

  // Animasyonlu parmak widget'ını oluştur
  static Widget _buildAnimatedFinger(Color color, double baseScale, bool isLit, double baseOpacity, int fingerNumber) {
    // Eğer tamamen durduysa ve seçilen parmak varsa, sadece kazanan parmağa özel efekt ver
    final bool isSelected = _isAnimationStopped && isLit && _selectedFinger != null;
    
    // Kazanan parmağa daha parlak bir görünüm ver
    final borderOpacity = isLit 
        ? (isSelected ? 0.8 : GameScreen.kBorderOpacity)  // Kazanan parmak daha parlak 
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

