import 'package:flutter/material.dart';

class AppColors {
  // 1. Semantic Tokens (USE THESE IN UI)
  static const Color primary = Color(0xFFFF8A71);    // Coral (Acción)
  static const Color secondary = Color(0xFF9083ED);  // Especial/Wellness
  static const Color accent = Color(0xFFA7E6D7);     // Salud/Menta
  
  static const Color bgLight = Color(0xFFFAFBFF); 
  static const Color bgDark = Color(0xFF0F172A); 
  
  static const Color surfaceLight = Color(0xFFF1EEFB); // Fondo suave para campos
  static const Color surfaceAccent = Color(0xFFE8F8F5); // Fondo mint para campos
  static const Color surfaceSupport = Color(0xFFFFF2ED); // Fondo coral suave 
  static const Color surfaceDark = Color(0xFF1E293B); 

  // 2. Functional Colors
  static const Color success = Color(0xFF4ADE80); 
  static const Color warning = Color(0xFFFBBF24); 
  static const Color error = Color(0xFFF87171); 
  
  // 3. Text Colors
  static const Color textPrimaryLight = Color(0xFF1E293B); 
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9); 
  static const Color textSecondaryDark = Color(0xFF94A3B8); 

  // 4. DEPRECATED ALIASES (Do not use in new code)
  static const Color coral = primary;
  static const Color lavender = secondary;
  static const Color mint = accent;
  static const Color mintLight = surfaceAccent;
  static const Color lavenderLight = surfaceLight;
  static const Color softPurple = Color(0xFFB1AFFF);
  static const Color peach = Color(0xFFFFD5C2);
  static const Color peachLight = Color(0xFFFFF2ED);

  // 5. Gradients (Dynamic & Modern)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFFB09C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient wavyGradient = LinearGradient(
    colors: [secondary, Color(0xFFB1AFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient wellnessGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
