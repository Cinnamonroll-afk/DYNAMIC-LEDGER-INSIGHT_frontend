import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fincontrol/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.destructive,
        surface: AppColors.darkBackground,
      ),
      textTheme: GoogleFonts.promptTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.prompt(color: AppColors.darkText),
        bodyMedium: GoogleFonts.prompt(color: AppColors.darkText),
        bodySmall: GoogleFonts.prompt(color: AppColors.darkMutedText),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkText),
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.destructive,
        surface: AppColors.lightBackground,
      ),
      textTheme: GoogleFonts.promptTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: GoogleFonts.prompt(color: AppColors.lightText),
        bodyMedium: GoogleFonts.prompt(color: AppColors.lightText),
        bodySmall: GoogleFonts.prompt(color: AppColors.lightMutedText),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightText),
        titleTextStyle: TextStyle(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

