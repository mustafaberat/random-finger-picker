import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();
  
  LocalizationService._();
  
  Map<String, dynamic>? _localizedStrings;
  String _currentLanguage = 'en';
  
  Future<void> init() async {
    final jsonString = await rootBundle.loadString('assets/localization/languages.json');
    _localizedStrings = json.decode(jsonString);
  }
  
  String getString(String key, [BuildContext? context]) {
    if (_localizedStrings == null) return '';
    
    if (context != null) {
      _currentLanguage = Localizations.localeOf(context).languageCode;
    }
    
    final languageMap = _localizedStrings![_currentLanguage] ?? _localizedStrings!['en'];
    return languageMap[key] ?? key;
  }
  
  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
  }
} 