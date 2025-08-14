import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeMode get currentTheme => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDark = value;
    notifyListeners();
  }
}
