// lib/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand - electric & vivid
  static const neonCoral = Color(0xFFFF4D6D);
  static const electricBlue = Color(0xFF4361EE);
  static const neonMint = Color(0xFF06FFA5);
  static const amber = Color(0xFFFFBE0B);
  static const violet = Color(0xFF7B2FBE);

  // Aliases kept for backward compatibility
  static const coral = neonCoral;
  static const mint = neonMint;
  static const navy = Color(0xFF0A0E1A);
  static const slate = Color(0xFF111827);
  static const offWhite = Color(0xFFF0EEF8);
  static const warmGrey = Color(0xFFEBE8F5);

  // Light surfaces
  static const lightBg = Color(0xFFF4F2FF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE4E0F8);

  // Dark surfaces - deep space palette
  static const darkBg = Color(0xFF08090F);
  static const darkCard = Color(0xFF111320);
  static const darkCardElevated = Color(0xFF181B2E);
  static const darkBorder = Color(0xFF252840);
  static const darkBorderBright = Color(0xFF353A60);

  // Glass
  static Color glassLight = Colors.white.withOpacity(0.08);
  static Color glassDark = Colors.black.withOpacity(0.3);
}

class AppTheme {
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    final base = GoogleFonts.spaceGroteskTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
          color: primary,
          fontSize: 48,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5),
      displayMedium: base.displayMedium?.copyWith(
          color: primary,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1),
      displaySmall: base.displaySmall?.copyWith(
          color: primary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5),
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
      bodyLarge:
      base.bodyLarge?.copyWith(color: secondary, fontSize: 16, height: 1.6),
      bodyMedium: base.bodyMedium
          ?.copyWith(color: secondary, fontSize: 14, height: 1.5),
      bodySmall: base.bodySmall?.copyWith(
          color: secondary.withOpacity(0.7), fontSize: 12),
      labelLarge: base.labelLarge?.copyWith(
          color: primary, fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData light() {
    const primary = AppColors.neonCoral;
    const bg = AppColors.lightBg;
    const card = AppColors.lightCard;
    const textPrimary = Color(0xFF0A0E1A);
    const textSecondary = Color(0xFF4A4E6A);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: AppColors.electricBlue,
        tertiary: AppColors.neonMint,
        surface: card,
        background: bg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
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
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 12,
        shape: StadiumBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBorder,
        selectedColor: primary,
        labelStyle: GoogleFonts.spaceGrotesk(
            fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: GoogleFonts.spaceGrotesk(
            color: textSecondary.withOpacity(0.5), fontSize: 14),
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
    const primary = AppColors.neonCoral;
    const bg = AppColors.darkBg;
    const card = AppColors.darkCard;
    const textPrimary = Color(0xFFF0EEF8);
    const textSecondary = Color(0xFF8B90C1);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: AppColors.electricBlue,
        tertiary: AppColors.neonMint,
        surface: card,
        background: bg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        outline: AppColors.darkBorder,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: _buildTextTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 12,
        shape: StadiumBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkBorder,
        selectedColor: primary,
        labelStyle: GoogleFonts.spaceGrotesk(
            fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: GoogleFonts.spaceGrotesk(
            color: textSecondary.withOpacity(0.5), fontSize: 14),
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