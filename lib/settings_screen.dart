// lib/settings_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memomixer/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'about_screen.dart';
import 'app_theme.dart';
import 'notes_provider.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final notes = context.watch<NotesProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
              isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                  isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Stats row ──────────────────────────────
          _StatsRow(notes: notes)
              .animate()
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.08),

          const SizedBox(height: 24),

          // ── Appearance ─────────────────────────────
          _Section(
            title: 'Appearance',
            color: AppColors.violet,
            icon: Icons.palette_rounded,
            children: [
              _ToggleTile(
                icon: Icons.dark_mode_rounded,
                iconColor: AppColors.electricBlue,
                label: 'Dark Mode',
                subtitle: isDark ? 'Currently dark' : 'Currently light',
                value: isDark,
                onChanged: (_) => settings.toggleDarkMode(),
              ),
            ],
          ).animate(delay: 80.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08),

          const SizedBox(height: 16),

          // ── Data ───────────────────────────────────
          _Section(
            title: 'Storage',
            color: AppColors.neonMint,
            icon: Icons.storage_rounded,
            children: [
              _ActionTile(
                icon: Icons.backup_rounded,
                iconColor: AppColors.neonMint,
                label: 'Backup Notes',
                subtitle: settings.lastBackup != null
                    ? 'Last: ${DateFormat('MMM d, h:mm a').format(settings.lastBackup!)}'
                    : 'Never backed up',
                onTap: () async {
                  await settings.markBackupTime();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Backup saved!',
                            style: GoogleFonts.spaceGrotesk()),
                        backgroundColor: AppColors.neonMint,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
              ),
            ],
          ).animate(delay: 160.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08),

          const SizedBox(height: 16),

          // ── About ──────────────────────────────────
          _Section(
            title: 'About',
            color: AppColors.amber,
            icon: Icons.info_outline_rounded,
            children: [
              _ActionTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.amber,
                label: 'About MemoMixer',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
              _ActionTile(
                icon: Icons.policy_rounded,
                iconColor: AppColors.electricBlue,
                label: 'Privacy Policy',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen())),
              ),
            ],
          ).animate(delay: 240.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08),

          const SizedBox(height: 32),

          // ── Version ────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.neonCoral, Color(0xFFFF8FA3)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  'MemoMixer',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'v1.0.0 · Made with ♥',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ).animate(delay: 320.ms).fadeIn(),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final NotesProvider notes;
  const _StatsRow({required this.notes});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData(notes.allNotes.length.toString(), 'Total',
          Icons.note_rounded, AppColors.neonCoral),
      _StatData(notes.photoNotes.length.toString(), 'Photos',
          Icons.photo_rounded, AppColors.electricBlue),
      _StatData(notes.audioNotes.length.toString(), 'Audio',
          Icons.mic_rounded, AppColors.neonMint),
      _StatData(notes.favoriteNotes.length.toString(), 'Faves',
          Icons.favorite_rounded, Colors.pink),
    ];

    return Row(
      children: stats
          .asMap()
          .entries
          .map((e) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
          child: _StatCard(data: e.value),
        ),
      ))
          .toList(),
    );
  }
}

class _StatData {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatData(this.value, this.label, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(data.icon, color: data.color, size: 20),
          const SizedBox(height: 6),
          Text(data.value,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: data.color,
                  letterSpacing: -0.5)),
          Text(data.label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.45))),
        ],
      ),
    );
  }
}

// ── Section container ─────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.color,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
              isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ── Toggle tile ───────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(label,
          style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle!,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.4)))
          : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.neonCoral,
      ),
    );
  }
}

// ── Action tile ───────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(label,
          style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle!,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.4)))
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}