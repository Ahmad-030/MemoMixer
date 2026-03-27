// lib/splash_screen.dart
import 'dart:math';
import 'dart:ui';
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
    with TickerProviderStateMixin {
  late AnimationController _orbController;
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoGlow;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();

    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));

    _logoGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 300), () {
      _logoController.forward();
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Stack(
        children: [
          // ── Animated orbs background ──────────────
          ..._buildOrbs(size),

          // ── Noise texture overlay (simulated) ─────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.transparent,
                    (isDark ? AppColors.darkBg : AppColors.lightBg)
                        .withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with glow
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, __) => Transform.scale(
                    scale: _logoScale.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.neonCoral
                                    .withOpacity(0.25 * _logoGlow.value),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        // Inner glow
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCoral
                                    .withOpacity(0.5 * _logoGlow.value),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: AppColors.electricBlue
                                    .withOpacity(0.3 * _logoGlow.value),
                                blurRadius: 60,
                                spreadRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        // Logo circle
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.neonCoral,
                                Color(0xFFFF8FA3),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // App name
                Text(
                  'MemoMixer',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.offWhite : AppColors.navy,
                    letterSpacing: -2,
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.4, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 10),

                // Tagline
                Text(
                  'Capture  ·  Speak  ·  Remember',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neonCoral,
                    letterSpacing: 2,
                  ),
                )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 64),

                // Loading bar
                _LoadingBar()
                    .animate(delay: 1000.ms)
                    .fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrbs(Size size) {
    final orbData = [
      _OrbData(
          x: -0.3, y: -0.35, size: 320, color: AppColors.neonCoral, phase: 0),
      _OrbData(
          x: 0.5,
          y: -0.15,
          size: 280,
          color: AppColors.electricBlue,
          phase: 0.33),
      _OrbData(
          x: -0.1, y: 0.4, size: 250, color: AppColors.neonMint, phase: 0.66),
    ];

    return orbData
        .map((orb) => AnimatedBuilder(
      animation: _orbController,
      builder: (_, __) {
        final t = _orbController.value;
        final dx = sin((t + orb.phase) * 2 * pi) * 30;
        final dy = cos((t + orb.phase) * 2 * pi) * 20;

        return Positioned(
          left: size.width * (orb.x + 0.5) + dx - orb.size / 2,
          top: size.height * (orb.y + 0.5) + dy - orb.size / 2,
          child: Container(
            width: orb.size,
            height: orb.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  orb.color.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    ))
        .toList();
  }
}

class _OrbData {
  final double x, y, size, phase;
  final Color color;
  const _OrbData(
      {required this.x,
        required this.y,
        required this.size,
        required this.color,
        required this.phase});
}

// ── Animated loading bar ──────────────────────────────────
class _LoadingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.darkBorder,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCoral),
          minHeight: 4,
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1200.ms, color: AppColors.neonCoral),
      ),
    );
  }
}