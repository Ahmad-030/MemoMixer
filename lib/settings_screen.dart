// lib/screens/settings_screen.dart
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
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'Appearance',
            children: [
              _ToggleTile(
                icon: Icons.dark_mode_rounded,
                iconColor: AppColors.navy,
                label: 'Dark Mode',
                value: isDark,
                onChanged: (_) => settings.toggleDarkMode(),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),

          const SizedBox(height: 16),

          _SettingsSection(
            title: 'Data',
            children: [
              _InfoTile(
                icon: Icons.note_rounded,
                iconColor: AppColors.coral,
                label: 'Total Notes',
                value: '${notes.allNotes.length}',
              ),
              _InfoTile(
                icon: Icons.favorite_rounded,
                iconColor: Colors.pink,
                label: 'Favorites',
                value: '${notes.favoriteNotes.length}',
              ),
              _InfoTile(
                icon: Icons.archive_rounded,
                iconColor: AppColors.amber,
                label: 'Archived',
                value: '${notes.archivedNotes.length}',
              ),
              _ActionTile(
                icon: Icons.backup_rounded,
                iconColor: AppColors.mint,
                label: 'Backup Notes',
                subtitle: settings.lastBackup != null
                    ? 'Last: ${DateFormat('MMM d, h:mm a').format(settings.lastBackup!)}'
                    : 'Never backed up',
                onTap: () async {
                  // In a real app, export JSON to file/cloud
                  await settings.markBackupTime();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Backup saved locally.'),
                      backgroundColor: AppColors.mint,
                    ),
                  );
                },
              ),
            ],
          )
              .animate(delay: 100.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05),

          const SizedBox(height: 16),

          _SettingsSection(
            title: 'About',
            children: [
              _ActionTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.coral,
                label: 'About MemoMixer',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
              _ActionTile(
                icon: Icons.policy_rounded,
                iconColor: AppColors.navy,
                label: 'Privacy Policy',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen())),
              ),

            ],
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05),

          const SizedBox(height: 24),

          Center(
            child: Text(
              'MemoMixer v1.0.0',
              style: GoogleFonts.syne(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.35),
              ),
            ),
          ).animate(delay: 300.ms).fadeIn(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.syne(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.coral,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(label, style: GoogleFonts.syne(fontWeight: FontWeight.w600)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.coral,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(label, style: GoogleFonts.syne(fontWeight: FontWeight.w600)),
      trailing: Text(
        value,
        style: GoogleFonts.syne(
            fontWeight: FontWeight.w700, color: AppColors.coral),
      ),
    );
  }
}

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
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(label, style: GoogleFonts.syne(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle!,
          style: GoogleFonts.syne(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onBackground
                  .withOpacity(0.5)))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded),
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}