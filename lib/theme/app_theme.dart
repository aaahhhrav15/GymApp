import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF4CAF50); // Green primary
  static const Color lightPrimaryVariant = Color(0xFF388E3C);
  static const Color lightSecondary = Color(0xFF2196F3); // Blue accent
  static const Color lightSecondaryVariant = Color(0xFF1976D2);
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Colors.white;
  static const Color lightError = Color(0xFFE57373);

  // Text colors for light theme
  static const Color lightOnPrimary = Colors.white;
  static const Color lightOnSecondary = Colors.white;
  static const Color lightOnBackground = Color(0xFF212121);
  static const Color lightOnSurface = Color(0xFF212121);
  static const Color lightOnError = Colors.white;

  // Additional light theme colors
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextHint = Color(0xFFBDBDBD);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightCardBackground = Colors.white;
  static const Color lightNavBarBackground = Color(0xFF1C1C1E);

  // Dark Theme Colors
  static const Color darkPrimary =
      Color(0xFF66BB6A); // Lighter green for dark theme
  static const Color darkPrimaryVariant = Color(0xFF4CAF50);
  static const Color darkSecondary =
      Color(0xFF42A5F5); // Lighter blue for dark theme
  static const Color darkSecondaryVariant = Color(0xFF2196F3);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkError = Color(0xFFCF6679);

  // Text colors for dark theme
  static const Color darkOnPrimary = Color(0xFF121212);
  static const Color darkOnSecondary = Color(0xFF121212);
  static const Color darkOnBackground = Color(0xFFE0E0E0);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkOnError = Color(0xFF121212);

  // Additional dark theme colors
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextHint = Color(0xFF757575);
  static const Color darkDivider = Color(0xFF424242);
  static const Color darkCardBackground = Color(0xFF2C2C2C);
  static const Color darkNavBarBackground = Color(0xFF2C2C2C);

  // Widget-specific colors for light theme
  static const Color lightNutritionPrimary = Color(0xFFE91E63); // Pink
  static const Color lightNutritionBackground = Color(0xFFFCE4EC);
  static const Color lightNutritionSecondary = Color(0xFFAD1457);

  static const Color lightWaterPrimary = Color(0xFF2196F3); // Blue
  static const Color lightWaterBackground = Color(0xFFE1F5FE);
  static const Color lightWaterSecondary = Color(0xFF1565C0);

  static const Color lightStepsPrimary = Color(0xFFFF9800); // Orange
  static const Color lightStepsBackground = Color(0xFFFFF3CD);
  static const Color lightStepsSecondary = Color(0xFFE65100);

  static const Color lightSleepPrimary = Color(0xFF9C27B0); // Purple
  static const Color lightSleepBackground = Color(0xFFF3E5F5);
  static const Color lightSleepSecondary = Color(0xFF6A1B9A);

  static const Color lightBmiPrimary = Color(0xFF4CAF50); // Green
  static const Color lightBmiBackground = Color(0xFFE8F5E8);
  static const Color lightBmiSecondary = Color(0xFF2E7D32);

  // Widget-specific colors for dark theme
  static const Color darkNutritionPrimary = Color(0xFFF06292); // Lighter pink
  static const Color darkNutritionBackground = Color(0xFF2C1B1F);
  static const Color darkNutritionSecondary = Color(0xFFE91E63);

  static const Color darkWaterPrimary = Color(0xFF42A5F5); // Lighter blue
  static const Color darkWaterBackground = Color(0xFF1A252F);
  static const Color darkWaterSecondary = Color(0xFF2196F3);

  static const Color darkStepsPrimary = Color(0xFFFFB74D); // Lighter orange
  static const Color darkStepsBackground = Color(0xFF2F251A);
  static const Color darkStepsSecondary = Color(0xFFFF9800);

  static const Color darkSleepPrimary = Color(0xFFBA68C8); // Lighter purple
  static const Color darkSleepBackground = Color(0xFF2A1B2F);
  static const Color darkSleepSecondary = Color(0xFF9C27B0);

  static const Color darkBmiPrimary = Color(0xFF66BB6A); // Lighter green
  static const Color darkBmiBackground = Color(0xFF1B2F1B);
  static const Color darkBmiSecondary = Color(0xFF4CAF50);

  // Gradient colors for widgets (work for both themes)
  static const List<Color> sleepGradient = [
    Color(0xFFFFE082),
    Color(0xFFFFF3C4),
  ];

  static const List<Color> stepsGradient = [
    Color(0xFFFFB74D),
    Color(0xFFFFF8E1),
  ];

  static const List<Color> bmiGradient = [
    Color(0xFF7986CB),
    Color(0xFFE8EAF6),
  ];

  // Status colors (same for both themes)
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
}

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      primaryContainer: AppColors.lightPrimaryVariant,
      secondary: AppColors.lightSecondary,
      secondaryContainer: AppColors.lightSecondaryVariant,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      error: AppColors.lightError,
      onPrimary: AppColors.lightOnPrimary,
      onSecondary: AppColors.lightOnSecondary,
      onBackground: AppColors.lightOnBackground,
      onSurface: AppColors.lightOnSurface,
      onError: AppColors.lightOnError,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCardBackground,
    dividerColor: AppColors.lightDivider,

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'SF Pro Display',
      ),
      displayMedium: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'SF Pro Display',
      ),
      displaySmall: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
      headlineLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
      headlineMedium: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
      headlineSmall: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
      bodyLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'SF Pro Display',
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: 'SF Pro Display',
      ),
      bodySmall: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: 'SF Pro Display',
      ),
      labelLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'SF Pro Display',
      ),
      labelMedium: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'SF Pro Display',
      ),
      labelSmall: TextStyle(
        color: AppColors.lightTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: 'SF Pro Display',
      ),
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.lightCardBackground,
      elevation: 2,
      shadowColor: const Color(0x1A000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    useMaterial3: true,
    fontFamily: 'SF Pro Display',
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      primaryContainer: AppColors.darkPrimaryVariant,
      secondary: AppColors.darkSecondary,
      secondaryContainer: AppColors.darkSecondaryVariant,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
      onPrimary: AppColors.darkOnPrimary,
      onSecondary: AppColors.darkOnSecondary,
      onBackground: AppColors.darkOnBackground,
      onSurface: AppColors.darkOnSurface,
      onError: AppColors.darkOnError,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCardBackground,
    dividerColor: AppColors.darkDivider,

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'SF Pro Display',
      ),
      displayMedium: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'SF Pro Display',
      ),
      displaySmall: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
      headlineLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
      headlineMedium: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
      headlineSmall: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
      bodyLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'SF Pro Display',
      ),
      bodyMedium: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: 'SF Pro Display',
      ),
      bodySmall: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: 'SF Pro Display',
      ),
      labelLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'SF Pro Display',
      ),
      labelMedium: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'SF Pro Display',
      ),
      labelSmall: TextStyle(
        color: AppColors.darkTextHint,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: 'SF Pro Display',
      ),
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.darkCardBackground,
      elevation: 4,
      shadowColor: const Color(0x4D000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    useMaterial3: true,
    fontFamily: 'SF Pro Display',
  );
}

// Extension for easy access to theme-aware colors
extension AppThemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Widget-specific colors that adapt to theme
  Color get nutritionPrimary => isDarkMode
      ? AppColors.darkNutritionPrimary
      : AppColors.lightNutritionPrimary;

  Color get nutritionBackground => isDarkMode
      ? AppColors.darkNutritionBackground
      : AppColors.lightNutritionBackground;

  Color get nutritionSecondary => isDarkMode
      ? AppColors.darkNutritionSecondary
      : AppColors.lightNutritionSecondary;

  Color get waterPrimary =>
      isDarkMode ? AppColors.darkWaterPrimary : AppColors.lightWaterPrimary;

  Color get waterBackground => isDarkMode
      ? AppColors.darkWaterBackground
      : AppColors.lightWaterBackground;

  Color get waterSecondary =>
      isDarkMode ? AppColors.darkWaterSecondary : AppColors.lightWaterSecondary;

  Color get stepsPrimary =>
      isDarkMode ? AppColors.darkStepsPrimary : AppColors.lightStepsPrimary;

  Color get stepsBackground => isDarkMode
      ? AppColors.darkStepsBackground
      : AppColors.lightStepsBackground;

  Color get stepsSecondary =>
      isDarkMode ? AppColors.darkStepsSecondary : AppColors.lightStepsSecondary;

  Color get sleepPrimary =>
      isDarkMode ? AppColors.darkSleepPrimary : AppColors.lightSleepPrimary;

  Color get sleepBackground => isDarkMode
      ? AppColors.darkSleepBackground
      : AppColors.lightSleepBackground;

  Color get sleepSecondary =>
      isDarkMode ? AppColors.darkSleepSecondary : AppColors.lightSleepSecondary;

  Color get bmiPrimary =>
      isDarkMode ? AppColors.darkBmiPrimary : AppColors.lightBmiPrimary;

  Color get bmiBackground =>
      isDarkMode ? AppColors.darkBmiBackground : AppColors.lightBmiBackground;

  Color get bmiSecondary =>
      isDarkMode ? AppColors.darkBmiSecondary : AppColors.lightBmiSecondary;

  Color get navBarBackground => isDarkMode
      ? AppColors.darkNavBarBackground
      : AppColors.lightNavBarBackground;
}
