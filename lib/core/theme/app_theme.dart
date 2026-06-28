import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6366F1),
        secondary: Color(0xFFC0C1FF),
        surface: Color(0xFF13131B),
        onSurface: Color(0xFFE4E1ED),
        error: Color(0xFFFFB4AB),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .apply(bodyColor: const Color(0xFFE4E1ED), displayColor: const Color(0xFFE4E1ED)),
      dividerColor: const Color(0xFF262626),
      useMaterial3: true,
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F8FB),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6366F1),
        secondary: Color(0xFF6366F1),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF1A1A2E),
        error: Color(0xFFB3261E),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .apply(bodyColor: const Color(0xFF1A1A2E), displayColor: const Color(0xFF1A1A2E)),
      dividerColor: const Color(0xFFE5E5EA),
      useMaterial3: true,
    );
  }
}
