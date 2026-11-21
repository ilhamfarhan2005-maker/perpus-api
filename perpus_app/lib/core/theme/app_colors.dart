// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Sentralisasi warna tema "Kampus Modern" (Light & Dark)
class AppColors {
  // === TEMA TERANG (KAMPUS MODERN) ===
  static const Color primary = Color(0xFF0F766E); // Teal kampus
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color background = Color(0xFFF0FDF4); // Latar lembut
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFFCA8A04); // Aksen emas
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFFE2E8F0);
  static const Color inputFill = Color(0xFFF8FAFC);

  // === TEMA GELAP (NAVY & SKY) ===
  static const Color darkBackground = Color(0xFF0F172A); // Navy gelap
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkPrimary = Color(0xFF14B8A6); // Teal cerah
  static const Color darkAccent = Color(0xFF38BDF8); // Aksen sky blue
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkInputFill = Color(0xFF0F172A);

  // === STATUS STOK BUKU ===
  static const Color stockHigh = Color(0xFF16A34A); // >= 10: Hijau
  static const Color stockHighBg = Color(0xFFDCFCE7);
  static const Color stockMedium = Color(0xFFEA580C); // 1 - 9: Oranye
  static const Color stockMediumBg = Color(0xFFFFEDD5);
  static const Color stockZero = Color(0xFFDC2626); // 0: Merah
  static const Color stockZeroBg = Color(0xFFFEE2E2);

  // === SHIMMER LOADING ===
  static const Color shimmerBaseLight = Color(0xFFE2E8F0);
  static const Color shimmerHighlightLight = Color(0xFFF8FAFC);
  static const Color shimmerBaseDark = Color(0xFF334155);
  static const Color shimmerHighlightDark = Color(0xFF475569);
}
