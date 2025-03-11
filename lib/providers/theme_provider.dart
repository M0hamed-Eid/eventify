import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  MaterialColor _primaryColor = Colors.blue;

  bool get isDarkMode => _isDarkMode;
  MaterialColor get primaryColor => _primaryColor;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    // Predefined MaterialColor options
    final predefinedColors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
    ];

    // Retrieve color index and ensure it's within bounds
    final colorIndex = prefs.getInt('primaryColorIndex') ?? 0;
    _primaryColor = predefinedColors[colorIndex % predefinedColors.length];

    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void setColor(MaterialColor color) async {
    // Predefined MaterialColor options
    final predefinedColors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
    ];

    final index = predefinedColors.indexOf(color);
    if (index != -1) {
      _primaryColor = color;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('primaryColorIndex', index);
      notifyListeners();
    }
  }

  ThemeData getTheme() {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.dark(primary: _primaryColor),
    )
        : ThemeData.light().copyWith(
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.light(primary: _primaryColor),
    );
  }
}