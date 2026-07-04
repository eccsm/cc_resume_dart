// lib/theme/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  ThemeProvider() {
    _loadThemeFromPrefs();
  }
  
  // Load theme preference from SharedPreferences
  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themePref = prefs.getString('theme_mode');
    
    _themeMode = themePref == 'dark' 
        ? ThemeMode.dark 
        : themePref == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    notifyListeners();
    }
  
  // Save theme preference to SharedPreferences
  void _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themePref = _themeMode == ThemeMode.dark 
        ? 'dark' 
        : _themeMode == ThemeMode.light
            ? 'light'
            : 'system';
    await prefs.setString('theme_mode', themePref);
  }
  
  // Toggle between light and dark theme
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    _saveThemeToPrefs();
    notifyListeners();
  }
  
  // Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeToPrefs();
    notifyListeners();
  }
}