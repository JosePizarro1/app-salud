import 'package:flutter/material.dart';

class AppColors {
  // 1. Raw Palette (Brand Colors)
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color accent = Color(0xFF8B5CF6); // Violet
  
  // 2. Functional Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Rose
  
  // 3. Neutral / Text Colors (Light Mode)
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50
  
  // 4. Neutral / Text Colors (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color bgDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800

  // 5. Paleta Pastel (Referencia Vitali)
  static const Color mint = Color(0xFFA7E6D7);
  static const Color mintLight = Color(0xFFE8F8F5);
  static const Color lavender = Color(0xFFD4CCF1);
  static const Color lavenderLight = Color(0xFFF1EEFB);
  static const Color softPurple = Color(0xFF7B61FF);

  // 6. Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, softPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient wavyGradient = LinearGradient(
    colors: [lavender, mint],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
