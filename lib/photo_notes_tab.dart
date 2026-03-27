// lib/photo_notes_tab.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
        subtitle: 'Tap + to capture your first visual memory.',
      );
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: notes.length,
      itemBuilder: (context, i) => _PhotoCard(note: notes[i], index: i),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final Note note;
  final int index;
  const _PhotoCard({required this.note, required this.index});

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
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          SlidableAction(
            onPressed: (_) =>
                context.read<NotesProvider>().deleteNote(note.id),
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          _heroRoute(NoteDetailScreen(note: note), 'photo_${note.id}'),
        ),
        child: Hero(
          tag: 'photo_${note.id}',
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
                      .withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo with overlay
                if (note.photoPath != null)
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: index.isEven ? 0.82 : 1.05,
                        child: Image.file(
                          File(note.photoPath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Bottom gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Color(0xAA000000),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Favorite badge
                      if (note.isFavorite)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter:
                              ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                color: Colors.black.withOpacity(0.25),
                                child: const Icon(Icons.favorite_rounded,
                                    color: AppColors.neonCoral, size: 14),
                              ),
                            ),
                          ),
                        ),
                    ],
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
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                            Theme.of(context).colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),

                      const SizedBox(height: 8),

                      Text(
                        DateFormat('MMM d').format(note.createdAt),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.35),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      if (note.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: note.tags
                              .take(2)
                              .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.neonCoral
                                  .withOpacity(0.1),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text('#$t',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neonCoral,
                                )),
                          ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 55))
        .fadeIn(duration: 400.ms)
        .scale(
      begin: const Offset(0.9, 0.9),
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  Route _heroRoute(Widget page, String tag) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 350),
  );
}