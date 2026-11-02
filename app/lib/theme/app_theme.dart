import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF142330);
  static const teal = Color(0xFF37B8B0);
  static const tealInk = Color(0xFF176C68);
  static const coral = Color(0xFFF47D65);
  static const background = Color(0xFFF3F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF1B2935);
  static const mutedText = Color(0xFF687783);
  static const border = Color(0xFFDCE4E9);
  static const success = Color(0xFF287F68);
  static const warning = Color(0xFFAA681C);
  static const attention = Color(0xFFB64F43);

  static ThemeData get light => _createTheme(Brightness.light);

  static ThemeData get dark => _createTheme(Brightness.dark);

  static ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF101820) : background;
    final surfaceColor = isDark ? const Color(0xFF1C2730) : surface;
    final borderColor = isDark ? const Color(0xFF36434D) : border;
    final primaryColor = isDark ? teal : navy;
    final textColor = isDark ? const Color(0xFFF1F5F7) : navy;
    final secondaryColor = isDark ? const Color(0xFF74D5CE) : teal;
    final colorScheme = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: isDark ? teal : navy,
      primary: primaryColor,
      onPrimary: isDark ? navy : Colors.white,
      secondary: secondaryColor,
      tertiary: coral,
      surface: surfaceColor,
      onSurface: isDark ? const Color(0xFFE7EDF0) : text,
      error: isDark ? const Color(0xFFFFB4AB) : attention,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: secondaryColor, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: coral,
          foregroundColor: navy,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: secondaryColor,
        linearTrackColor: isDark
            ? const Color(0xFF35434C)
            : const Color(0xFFE5ECEF),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: secondaryColor,
        thumbColor: primaryColor,
        overlayColor: secondaryColor.withValues(alpha: 0.16),
      ),
    );
  }
}
