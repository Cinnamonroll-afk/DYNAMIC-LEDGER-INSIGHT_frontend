import 'package:flutter/material.dart';

class AppColors {
  // Shared Colors
  static const Color primary = Color(0xFF1E40AF); // Trust Blue (light mode)

  /// Brighter blue for dark mode — the navy above only has ~2:1 contrast on the
  /// dark background, so blue text/buttons blended in (Feedback #9).
  /// #3B82F6: 4.9:1 on the dark background, 3.7:1 for white text on it.
  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF059669); // Profit Green
  static const Color destructive = Color(0xFFDC2626); // Loss Red
  static const Color border = Color(0x14FFFFFF); // Subtle white border 0.08 opacity

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkGlassCard = Color(0x66192134); // 0.4 opacity
  static const Color darkText = Colors.white;
  static const Color darkMutedText = Color(0xFF94A3B8);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightGlassCard = Color(0x99FFFFFF); // 0.6 opacity
  static const Color lightText = Color(0xFF020617);
  static const Color lightMutedText = Color(0xFF64748B);
}
