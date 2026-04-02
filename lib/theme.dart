import 'package:flutter/material.dart';
import 'package:patres/models/app_theme_mode.dart';

class PatresTheme {
  PatresTheme._();

  // Refined color palette inspired by illuminated manuscripts
  static const _primarySeed = Color(0xFF8B1A1A); // Deep ecclesiastical red
  static const _sepiaPrimary = Color(0xFF6D4C2A); // Warm brown
  static const _sepiaBackground = Color(0xFFF5ECD7); // Aged parchment
  static const _sepiaSurface = Color(0xFFFAF4E8); // Lighter parchment
  static const _sepiaOnBackground = Color(0xFF3E2C1C); // Dark brown ink

  static ThemeData themeFor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return _lightTheme;
      case AppThemeMode.dark:
        return _darkTheme;
      case AppThemeMode.sepia:
        return _sepiaTheme;
    }
  }

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: _primarySeed,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: _primarySeed,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );

  static final _sepiaColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _sepiaPrimary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFDEC8A0),
    onPrimaryContainer: const Color(0xFF3E2C1C),
    secondary: const Color(0xFF8B6914),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFE8D5A8),
    onSecondaryContainer: const Color(0xFF4A3800),
    tertiary: const Color(0xFF6D5E3A),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFD4C4A0),
    onTertiaryContainer: const Color(0xFF3E2C1C),
    error: const Color(0xFF8B1A1A),
    onError: Colors.white,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: _sepiaSurface,
    onSurface: _sepiaOnBackground,
    surfaceContainerHighest: const Color(0xFFE8D8C0),
    outline: const Color(0xFF9C8B72),
    outlineVariant: const Color(0xFFCDBFA8),
    shadow: Colors.brown.withValues(alpha: 0.15),
    inverseSurface: const Color(0xFF3E2C1C),
    onInverseSurface: _sepiaBackground,
    inversePrimary: const Color(0xFFDEC8A0),
    surfaceTint: _sepiaPrimary,
  );

  static final _sepiaTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _sepiaColorScheme,
    scaffoldBackgroundColor: _sepiaBackground,
    fontFamily: 'Roboto',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: _sepiaBackground,
      foregroundColor: _sepiaOnBackground,
      surfaceTintColor: _sepiaPrimary,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: _sepiaSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFFCDBFA8).withValues(alpha: 0.5)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: _sepiaBackground,
      indicatorColor: const Color(0xFFDEC8A0),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFCDBFA8),
    ),
  );
}
