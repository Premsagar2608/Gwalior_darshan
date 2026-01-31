import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String key = "isDarkMode";
  bool isDarkMode = false;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final pref = await SharedPreferences.getInstance();
    isDarkMode = pref.getBool(key) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final pref = await SharedPreferences.getInstance();
    isDarkMode = !isDarkMode;
    await pref.setBool(key, isDarkMode);
    notifyListeners();
  }

  ThemeMode get currentTheme => isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
