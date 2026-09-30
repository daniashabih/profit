import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accent (Exact match to reference image)
  static const Color primaryLime = Color(0xFF76FF03); // Fluorescent neon lime
  static const Color primaryLimeDark = Color(0xFF64DD17);
  static const Color primaryLimeLight = Color(0xFFB2FF59);

  // Electric Cyan / Aqua Accent (Active capsule, hero play button, begin button)
  static const Color electricCyan = Color(0xFF00E5FF);
  static const Color electricCyanDark = Color(0xFF00B4D8);
  static const Color electricCyanLight = Color(0xFF80F3FF);

  // Dark Theme Colors (Deep dark petrol-slate / cyan-tinted charcoal from reference)
  static const Color darkBackground = Color(0xFF0B1216); // Deep petrol-dark backdrop
  static const Color darkSurface = Color(0xFF132228);    // Translucent petrol card surface
  static const Color darkSurfaceElevated = Color(0xFF192B33);
  static const Color darkCardBackground = darkSurface;
  static const Color darkBorder = Color(0xFF1D3540);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E9CA5);
  static const Color darkTextMuted = Color(0xFF5A6E78);
  static const Color darkProgressUnfilled = Color(0xFF1B2B32);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = lightSurface;
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Functional Accents
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Macro colors
  static const Color proteinColor = Color(0xFF38BDF8); // Cyan
  static const Color carbsColor = Color(0xFFF59E0B);   // Amber
  static const Color fatColor = Color(0xFFEC4899);     // Rose/Pink

  // Neutral grays
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);
}
