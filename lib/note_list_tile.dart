// lib/note_list_tile.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';
import 'note_model.dart';
import 'note_detail_screen.dart';

class NoteListTile extends StatelessWidget {
  final Note note;
  const NoteListTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = note.photoPath != null;
    final hasAudio = note.audioPath != null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.navy)
                  .withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Thumbnail
            if (hasPhoto)
              SizedBox(
                width: 88,
                height: 88,
                child: Image.file(
                  File(note.photoPath!),
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: hasAudio
                        ? [
                      AppColors.electricBlue.withOpacity(0.15),
                      AppColors.neonCoral.withOpacity(0.08),
                    ]
                        : [
                      AppColors.neonMint.withOpacity(0.12),
                      AppColors.electricBlue.withOpacity(0.06),
                    ],
                  ),
                ),
                child: Icon(
                  hasAudio ? Icons.mic_rounded : Icons.note_rounded,
                  color: hasAudio
                      ? AppColors.electricBlue
                      : AppColors.neonMint,
                  size: 30,
                ),
              ),

            const SizedBox(width: 14),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.caption.isNotEmpty
                          ? note.caption
                          : 'Untitled Note',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 10,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.35),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          DateFormat('MMM d · h:mm a').format(note.createdAt),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.35),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        if (hasPhoto)
                          _Badge(
                              icon: Icons.photo_camera_rounded,
                              color: AppColors.neonMint),
                        if (hasAudio)
                          _Badge(
                              icon: Icons.mic_rounded,
                              color: AppColors.electricBlue),
                        if (note.isFavorite)
                          _Badge(
                              icon: Icons.favorite_rounded,
                              color: Colors.pink),
                        if (note.tags.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            note.tags.take(2).map((t) => '#$t').join(' '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neonCoral,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.2),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _Badge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 10, color: color),
    );
  }
}