// lib/empty_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = color ?? AppColors.neonCoral;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        c.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ).animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
                    .scaleXY(
                    end: 1.15,
                    duration: 2500.ms,
                    curve: Curves.easeInOut),

                // Icon circle
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: c.withOpacity(0.1),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 38, color: c.withOpacity(0.7)),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(
                begin: const Offset(0.7, 0.7),
                curve: Curves.easeOutBack,
                duration: 600.ms),

            const SizedBox(height: 28),

            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.75),
              ),
            ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 10),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                height: 1.6,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.4),
              ),
            ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}