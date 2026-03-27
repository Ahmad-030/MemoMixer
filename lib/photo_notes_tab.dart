// lib/widgets/photo_notes_tab.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'empty_state.dart';
import 'note_detail_screen.dart';
import 'note_model.dart';
import 'notes_provider.dart';

class PhotoNotesTab extends StatelessWidget {
  const PhotoNotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>().photoNotes;

    if (notes.isEmpty) {
      return const EmptyState(
        icon: Icons.photo_library_outlined,
        title: 'No Photo Notes',
        subtitle: 'Tap the + button to add your first photo note.',
      );
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: notes.length,
      itemBuilder: (context, i) {
        final note = notes[i];
        return _PhotoNoteCard(note: note, index: i);
      },
    );
  }
}

class _PhotoNoteCard extends StatelessWidget {
  final Note note;
  final int index;
  const _PhotoNoteCard({required this.note, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              if (note.photoPath != null)
                AspectRatio(
                  aspectRatio: index.isEven ? 0.85 : 1.1,
                  child: Image.file(
                    File(note.photoPath!),
                    fit: BoxFit.cover,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.caption.isNotEmpty)
                      Text(
                        note.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.syne(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        children: note.tags
                            .take(2)
                            .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                            AppColors.coral.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#$t',
                            style: GoogleFonts.syne(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.coral,
                            ),
                          ),
                        ))
                            .toList(),
                      ),
                    ],

                    if (note.isFavorite)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(Icons.favorite_rounded,
                            color: AppColors.coral, size: 14),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 400.ms)
        .scale(
      begin: const Offset(0.92, 0.92),
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }
}