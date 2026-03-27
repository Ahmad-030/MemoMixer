// lib/widgets/combined_notes_tab.dart
import 'dart:io';
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
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) =>
                context.read<NotesProvider>().toggleFavorite(note.id),
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            icon: note.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
          ),
          SlidableAction(
            onPressed: (_) =>
                context.read<NotesProvider>().deleteNote(note.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
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
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              if (note.photoPath != null)
                Stack(
                  children: [
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.file(
                        File(note.photoPath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Audio badge
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.mic_rounded,
                                color: AppColors.mint, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Audio',
                              style: GoogleFonts.syne(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (note.isFavorite)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.coral,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.caption.isNotEmpty)
                      Text(
                        note.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.syne(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, y').format(note.createdAt),
                          style: GoogleFonts.syne(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                        ),
                        const Spacer(),
                        if (note.tags.isNotEmpty)
                          Text(
                            note.tags.take(2).map((t) => '#$t').join(' '),
                            style: GoogleFonts.syne(
                                fontSize: 11,
                                color: AppColors.coral,
                                fontWeight: FontWeight.w600),
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