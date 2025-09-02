import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../utils/easy_loading_config.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey);

      if (themeString != null) {
        switch (themeString) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      // If there's an error, default to system mode
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    // Update EasyLoading theme
    if (mode == ThemeMode.dark) {
      EasyLoadingConfig.configureForDarkMode();
    } else if (mode == ThemeMode.light) {
      EasyLoadingConfig.configureForLightMode();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;

      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
        default:
          themeString = 'system';
          break;
      }

      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      // Handle error silently
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  ThemeData getThemeData(Brightness brightness) {
    if (_themeMode == ThemeMode.system) {
      return brightness == Brightness.dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme;
    } else if (_themeMode == ThemeMode.dark) {
      return AppTheme.darkTheme;
    } else {
      return AppTheme.lightTheme;
    }
  }
}
