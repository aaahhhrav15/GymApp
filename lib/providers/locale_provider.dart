// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('en'); // Default locale

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  /// Load saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);

      if (languageCode != null) {
        _locale = Locale(languageCode);
        notifyListeners();
        print('Loaded locale: $languageCode');
      }
    } catch (e) {
      print('Error loading locale: $e');
    }
  }

  /// Set and save new locale
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      print('Locale saved: ${locale.languageCode}');
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  /// Toggle between English and Hindi
  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'en') {
      await setLocale(const Locale('hi'));
    } else {
      await setLocale(const Locale('en'));
    }
  }

  /// Check if current language is English
  bool get isEnglish => _locale.languageCode == 'en';

  /// Check if current language is Hindi
  bool get isHindi => _locale.languageCode == 'hi';

  /// Get current language name
  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      default:
        return 'English';
    }
  }
}
