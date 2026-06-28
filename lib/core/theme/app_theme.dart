import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData dark() {
    const cs = ColorScheme.dark(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFFC0C1FF),
      surface: Color(0xFF13131B),
      surfaceContainer: Color(0xFF1F1F27),
      surfaceContainerHigh: Color(0xFF292932),
      onSurface: Color(0xFFE4E1ED),
      error: Color(0xFFFFB4AB),
      outlineVariant: Color(0xFF464554),
      outline: Color(0xFF262626),
    );
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      colorScheme: cs,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface),
      dividerColor: const Color(0xFF262626),
      useMaterial3: true,
    );
  }

  static ThemeData light() {
    const cs = ColorScheme.light(
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF6366F1),
      surface: Color(0xFFFFFFFF),
      surfaceContainer: Color(0xFFF0F0F5),
      surfaceContainerHigh: Color(0xFFE8E8F0),
      onSurface: Color(0xFF1A1A2E),
      error: Color(0xFFB3261E),
      outlineVariant: Color(0xFFD1D1D8),
      outline: Color(0xFFE5E5EA),
    );
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F8FB),
      colorScheme: cs,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface),
      dividerColor: const Color(0xFFE5E5EA),
      useMaterial3: true,
    );
  }
}
