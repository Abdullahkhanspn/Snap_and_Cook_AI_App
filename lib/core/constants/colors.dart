import 'package:flutter/material.dart';

class AppColors {
  // Bio Glow Theme Colors (Extracted from Logo)
  static const Color primary = Color(0xFF4CAF50);    // Vibrant Green (Snap)
  static const Color primaryDark = Color(0xFF388E3C); // Arrow Green
  static const Color secondary = Color(0xFFFF9800);  // Vibrant Orange (and)
  static const Color accent = Color(0xFFF44336);     // Vibrant Red (Strawberry/Apple)
  
  static const Color background = Color(0xFFF8FAF8); // Very light minty white
  static const Color surface = Colors.white;
  
  static const Color textPrimary = Color(0xFF1B5E20);   // Dark Green for readability
  static const Color textSecondary = Color(0xFF455A64); // Blue Grey
  
  // Functional Colors (Mapped to Theme)
  static const Color green = primary;
  static const Color yellow = secondary;
  static const Color red = accent;
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // Glow Effects
  static List<BoxShadow> get bioGlow => [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
}
