// lib/combined_notes_tab.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';
import 'empty_state.dart';
import 'note_detail_screen.dart';
import 'note_model.dart';
import 'notes_provider.dart';

class CombinedNotesTab extends StatelessWidget {
  const CombinedNotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>().combinedNotes;

    if (notes.isEmpty) {
      return const EmptyState(
        icon: Icons.layers_outlined,
        title: 'No Combined Notes',
        subtitle: 'Add a note with both a photo and audio recording.',
        color: AppColors.neonMint,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _CombinedCard(note: notes[i], index: i),
    );
  }
}

class _CombinedCard extends StatelessWidget {
  final Note note;
  final int index;
  const _CombinedCard({required this.note, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) =>
                context.read<NotesProvider>().toggleFavorite(note.id),
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            icon: note.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            borderRadius:
            const BorderRadius.horizontal(left: Radius.circular(22)),
          ),
          SlidableAction(
            onPressed: (_) =>
                context.read<NotesProvider>().deleteNote(note.id),
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            borderRadius:
            const BorderRadius.horizontal(right: Radius.circular(22)),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color:
                isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.navy)
                    .withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo with badges
              if (note.photoPath != null)
                Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.file(
                        File(note.photoPath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0x88000000),
                            ],
                            stops: [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Audio badge
                    Positioned(
                      bottom: 14,
                      left: 14,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            color: Colors.black.withOpacity(0.35),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.neonMint,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Audio + Photo',
                                  style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Favorite badge
                    if (note.isFavorite)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter:
                            ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              color: Colors.black.withOpacity(0.3),
                              child: const Icon(Icons.favorite_rounded,
                                  color: AppColors.neonCoral, size: 14),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.caption.isNotEmpty)
                      Text(
                        note.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.35)),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('MMM d, y').format(note.createdAt),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.35),
                          ),
                        ),
                        const Spacer(),
                        if (note.tags.isNotEmpty)
                          Text(
                            note.tags.take(2).map((t) => '#$t').join(' '),
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                color: AppColors.neonCoral,
                                fontWeight: FontWeight.w700),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 70))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, curve: Curves.easeOut);
  }
}