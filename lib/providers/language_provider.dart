import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language {
  final String code;
  final String name;

  Language({required this.code, required this.name});
}

class LanguageProvider with ChangeNotifier {
  String _currentLanguageCode = 'en';

  String get currentLanguageCode => _currentLanguageCode;

  final List<Language> supportedLanguages = [
    Language(code: 'en', name: 'English'),
    Language(code: 'es', name: 'Español'),
    Language(code: 'fr', name: 'Français'),
    Language(code: 'de', name: 'Deutsch'),
  ];

  LanguageProvider() {
    _loadLanguageFromPrefs();
  }

  void _loadLanguageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguageCode = prefs.getString('languageCode') ?? 'en';
    notifyListeners();
  }

  void changeLanguage(String languageCode) async {
    _currentLanguageCode = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    notifyListeners();
  }

  Locale get locale => Locale(_currentLanguageCode);
}