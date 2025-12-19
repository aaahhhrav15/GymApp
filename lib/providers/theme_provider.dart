import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Get display name for theme mode (localized)
  String themeModeDisplayName(AppLocalizations l10n) {
    switch (_themeMode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkModeLabel;
      case ThemeMode.system:
        return l10n.systemDefault;
    }
  }

  // Get icon for current theme mode
  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  ThemeProvider() {
    _loadThemeMode();
  }

  // Load saved theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeModeIndex = prefs.getInt(_themeModeKey);

      if (savedThemeModeIndex != null &&
          savedThemeModeIndex >= 0 &&
          savedThemeModeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[savedThemeModeIndex];
      }

      notifyListeners();
    } catch (e) {
      // If loading fails, use system default
      _themeMode = ThemeMode.system;
      notifyListeners();
    }
  }

  // Save theme mode to SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, _themeMode.index);
    } catch (e) {
      // Handle save error silently
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      await _saveThemeMode();
    }
  }

  // Toggle between light and dark (skip system)
  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  // Get all available theme options (localized)
  List<ThemeOption> allThemeOptions(AppLocalizations l10n) => [
        ThemeOption(
          mode: ThemeMode.system,
          title: l10n.systemDefault,
          subtitle: l10n.followSystemSettings,
          icon: Icons.brightness_auto_outlined,
        ),
        ThemeOption(
          mode: ThemeMode.light,
          title: l10n.lightMode,
          subtitle: l10n.lightModeDesc,
          icon: Icons.light_mode_outlined,
        ),
        ThemeOption(
          mode: ThemeMode.dark,
          title: l10n.darkModeLabel,
          subtitle: l10n.darkModeDesc,
          icon: Icons.dark_mode_outlined,
        ),
      ];
}

class ThemeOption {
  final ThemeMode mode;
  final String title;
  final String subtitle;
  final IconData icon;

  ThemeOption({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
