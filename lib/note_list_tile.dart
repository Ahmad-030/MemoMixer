// lib/note_list_tile.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.navy)
                  .withOpacity(isDark ? 0.25 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Left thumbnail or icon
            if (hasPhoto)
              SizedBox(
                width: 90,
                height: 90,
                child: Image.file(
                  File(note.photoPath!),
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 90,
                height: 90,
                color: hasAudio
                    ? AppColors.coral.withOpacity(0.12)
                    : AppColors.mint.withOpacity(0.12),
                child: Icon(
                  hasAudio ? Icons.mic_rounded : Icons.note_rounded,
                  color: hasAudio ? AppColors.coral : AppColors.mint,
                  size: 32,
                ),
              ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title / Caption
                    Text(
                      note.caption.isNotEmpty ? note.caption : 'Untitled Note',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.syne(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Date + media badges
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          DateFormat('MMM d · h:mm a').format(note.createdAt),
                          style: GoogleFonts.syne(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (hasPhoto)
                          _Badge(
                            icon: Icons.photo_camera_rounded,
                            color: AppColors.mint,
                          ),
                        if (hasAudio)
                          _Badge(
                            icon: Icons.mic_rounded,
                            color: AppColors.coral,
                          ),
                        if (note.isFavorite)
                          _Badge(
                            icon: Icons.favorite_rounded,
                            color: Colors.pink,
                          ),
                      ],
                    ),

                    // Tags
                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        note.tags.take(3).map((t) => '#$t').join('  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.syne(
                          fontSize: 11,
                          color: AppColors.coral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded,
                  color: AppColors.coral, size: 20),
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
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 10, color: color),
    );
  }
}