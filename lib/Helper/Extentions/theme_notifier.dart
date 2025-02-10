import 'package:flutter/material.dart';
import '../../Models/Theme/theme_model.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme = AppTheme.lightTheme;

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    _currentTheme = _currentTheme == AppTheme.lightTheme ? AppTheme.darkTheme : AppTheme.lightTheme;
    notifyListeners();
  }
}