// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
      isDark ? AppColors.darkBg : AppColors.offWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.coral,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 56,
              ),
            )
                .animate()
                .scale(
              duration: 600.ms,
              curve: Curves.elasticOut,
              begin: const Offset(0.3, 0.3),
            )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // App name
            Text(
              'MemoMixer',
              style: GoogleFonts.syne(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.offWhite : AppColors.navy,
                letterSpacing: -1,
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 12),

            // Tagline
            Text(
              'Capture · Speak · Remember',
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.coral,
                letterSpacing: 2,
              ),
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 60),

            // Loading dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(
                  delay: Duration(milliseconds: 700 + i * 150),
                  onPlay: (ctrl) => ctrl.repeat(reverse: true),
                )
                    .scale(
                  duration: 500.ms,
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.2, 1.2),
                  curve: Curves.easeInOut,
                )
                    .then()
                    .scale(
                  duration: 500.ms,
                  end: const Offset(0.5, 0.5),
                  curve: Curves.easeInOut,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}