// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('About MemoMixer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.coral,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withOpacity(0.35),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 48),
            )
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut)
                .fadeIn(),

            const SizedBox(height: 24),

            Text(
              'MemoMixer',
              style: GoogleFonts.syne(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),

            const SizedBox(height: 8),

            Text(
              'Capture · Speak · Remember',
              style: GoogleFonts.syne(
                fontSize: 14,
                color: AppColors.coral,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ).animate(delay: 150.ms).fadeIn(),

            const SizedBox(height: 32),

            _FeatureCard(
              icon: Icons.photo_library_rounded,
              color: AppColors.coral,
              title: 'Photo Notes',
              desc: 'Capture moments with your camera or pick from gallery.',
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 12),

            _FeatureCard(
              icon: Icons.mic_rounded,
              color: AppColors.mint,
              title: 'Audio Notes',
              desc: 'Record voice memos with real-time waveform display.',
            ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 12),

            _FeatureCard(
              icon: Icons.layers_rounded,
              color: AppColors.amber,
              title: 'Combined Notes',
              desc: 'Combine photo + audio in one rich note.',
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 12),

            _FeatureCard(
              icon: Icons.tag_rounded,
              color: AppColors.navy,
              title: 'Tags & Search',
              desc: 'Organize and retrieve notes instantly.',
            ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 48),

            Text(
              'Version 1.0.0',
              style: GoogleFonts.syne(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.35),
              ),
            ).animate(delay: 400.ms).fadeIn(),

            const SizedBox(height: 4),

            Text(
              'Made with ♥ by the MemoMixer Team',
              style: GoogleFonts.syne(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.3),
              ),
            ).animate(delay: 450.ms).fadeIn(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, desc;
  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.syne(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc,
                    style: GoogleFonts.syne(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.55),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}