import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F8FA),
    );
  }
}