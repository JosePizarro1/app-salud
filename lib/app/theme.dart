import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Poppins',
  );
}
