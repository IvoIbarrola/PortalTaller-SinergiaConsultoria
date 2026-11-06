import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF10242D);
  static const navy = ink;
  static const teal = Color(0xFF127E78);
  static const tealInk = Color(0xFF0D625D);
  static const mint = Color(0xFF83D9CA);
  static const coral = Color(0xFFEF6848);
  static const background = Color(0xFFF7F4ED);
  static const surface = Color(0xFFFFFEFB);
  static const text = ink;
  static const mutedText = Color(0xFF53656A);
  static const border = Color(0xFFDEDFD6);
  static const success = teal;
  static const warning = Color(0xFF9A5B18);
  static const attention = Color(0xFFB84D38);

  static ThemeData get light => _createTheme(Brightness.light);

  static ThemeData get dark => _createTheme(Brightness.dark);

  static ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0B191E) : background;
    final surfaceColor = isDark ? const Color(0xFF17272C) : surface;
    final borderColor = isDark ? const Color(0xFF34464A) : border;
    final primaryColor = isDark ? mint : teal;
    final textColor = isDark ? const Color(0xFFF3F4EF) : ink;
    final secondaryColor = isDark ? mint : teal;
    final colorScheme = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: teal,
      primary: primaryColor,
      onPrimary: isDark ? ink : Colors.white,
      secondary: secondaryColor,
      tertiary: coral,
      surface: surfaceColor,
      onSurface: isDark ? const Color(0xFFE9EFEB) : text,
      error: isDark ? const Color(0xFFFFB4AB) : attention,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'DM Sans',
      textTheme: ThemeData(brightness: brightness, useMaterial3: true).textTheme
          .apply(
            bodyColor: textColor,
            displayColor: textColor,
            fontFamily: 'DM Sans',
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: textColor,
          fontFamily: 'Manrope',
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
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
            ? const Color(0xFF34464A)
            : const Color(0xFFE7E8DE),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: secondaryColor,
        thumbColor: primaryColor,
        overlayColor: secondaryColor.withValues(alpha: 0.16),
      ),
    );
  }
}
