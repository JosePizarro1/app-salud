import 'package:flutter/material.dart';

class AppColors {
  // 1. Colores Oficiales Vitali
  static const Color primary = Color(0xFFA7E6D7);    // Verde Menta
  static const Color secondary = Color(0xFFD4CCF1);  // Lavanda
  static const Color accent = Color(0xFFB8EBE0);     // Menta suave
  
  // 2. Functional Colors
  static const Color success = Color(0xFF10B981); 
  static const Color warning = Color(0xFFF59E0B); 
  static const Color error = Color(0xFFEF4444); 
  
  // 3. Neutral / Text Colors (Light Mode)
  static const Color textPrimaryLight = Color(0xFF0F172A); 
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color bgLight = Color(0xFFF8FAFC); 
  
  // 4. Neutral / Text Colors (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFF8FAFC); 
  static const Color textSecondaryDark = Color(0xFF94A3B8); 
  static const Color bgDark = Color(0xFF0F172A); 
  static const Color surfaceDark = Color(0xFF1E293B); 

  // 5. Paleta Vitali Detallada
  static const Color mint = Color(0xFFA7E6D7);
  static const Color mintLight = Color(0xFFE8F8F5);
  static const Color lavender = Color(0xFFD4CCF1);
  static const Color lavenderLight = Color(0xFFF1EEFB);
  static const Color softPurple = Color(0xFFD4CCF1); // Usamos lavanda en lugar de púrpura
  static const Color peach = Color(0xFFFFD5C2);
  static const Color peachLight = Color(0xFFFFF2ED);

  // 6. Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient wavyGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
