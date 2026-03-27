// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand
  static const coral = Color(0xFFFF6B6B);
  static const amber = Color(0xFFFFBE0B);
  static const mint = Color(0xFF06D6A0);
  static const navy = Color(0xFF0D1B2A);
  static const slate = Color(0xFF1C2B3A);
  static const offWhite = Color(0xFFF5F0EA);
  static const warmGrey = Color(0xFFE8E0D5);

  // Light surface
  static const lightBg = Color(0xFFF5F0EA);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE0D8CC);

  // Dark surface
  static const darkBg = Color(0xFF0D1B2A);
  static const darkCard = Color(0xFF1C2B3A);
  static const darkBorder = Color(0xFF2A3D52);
}

class AppTheme {
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    final base = GoogleFonts.syneTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
          color: primary, fontSize: 48, fontWeight: FontWeight.w800),
      displayMedium: base.displayMedium?.copyWith(
          color: primary, fontSize: 36, fontWeight: FontWeight.w700),
      displaySmall: base.displaySmall?.copyWith(
          color: primary, fontSize: 28, fontWeight: FontWeight.w700),
      headlineLarge: base.headlineLarge?.copyWith(
          color: primary, fontSize: 24, fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium?.copyWith(
          color: primary, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: base.headlineSmall?.copyWith(
          color: primary, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(
          color: primary, fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(
          color: primary, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(color: secondary, fontSize: 16),
      bodyMedium: base.bodyMedium?.copyWith(color: secondary, fontSize: 14),
      bodySmall: base.bodySmall?.copyWith(
          color: secondary.withOpacity(0.7), fontSize: 12),
      labelLarge: base.labelLarge?.copyWith(
          color: primary, fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData light() {
    const primary = AppColors.coral;
    const bg = AppColors.lightBg;
    const card = AppColors.lightCard;
    const textPrimary = AppColors.navy;
    const textSecondary = Color(0xFF4A5568);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: AppColors.amber,
        tertiary: AppColors.mint,
        surface: card,
        background: bg,
        onPrimary: Colors.white,
        onSecondary: AppColors.navy,
        onSurface: textPrimary,
        onBackground: textPrimary,
        outline: AppColors.lightBorder,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: _buildTextTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.syne(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBorder,
        selectedColor: primary,
        labelStyle: GoogleFonts.syne(
            fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFFB0B8C1),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    const primary = AppColors.coral;
    const bg = AppColors.darkBg;
    const card = AppColors.darkCard;
    const textPrimary = AppColors.offWhite;
    const textSecondary = Color(0xFF94A3B8);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: AppColors.amber,
        tertiary: AppColors.mint,
        surface: card,
        background: bg,
        onPrimary: Colors.white,
        onSecondary: AppColors.navy,
        onSurface: textPrimary,
        onBackground: textPrimary,
        outline: AppColors.darkBorder,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: _buildTextTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.syne(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkBorder,
        selectedColor: primary,
        labelStyle: GoogleFonts.syne(
            fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF4A5568),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}