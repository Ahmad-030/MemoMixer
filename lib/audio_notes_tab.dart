// lib/widgets/audio_notes_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';
import 'note_detail_screen.dart';
import 'note_model.dart';
import 'notes_provider.dart';


class AudioNotesTab extends StatelessWidget {
  const AudioNotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>().audioNotes;

    if (notes.isEmpty) {
      return const EmptyState(
        icon: Icons.mic_none_rounded,
        title: 'No Audio Notes',
        subtitle: 'Record a voice memo using the + button.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _AudioNoteCard(note: notes[i], index: i),
    );
  }
}

class _AudioNoteCard extends StatefulWidget {
  final Note note;
  final int index;
  const _AudioNoteCard({required this.note, required this.index});

  @override
  State<_AudioNoteCard> createState() => _AudioNoteCardState();
}

class _AudioNoteCardState extends State<_AudioNoteCard> {
  final _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (widget.note.audioPath == null) return;
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(DeviceFileSource(widget.note.audioPath!));
      setState(() => _isPlaying = true);
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final note = widget.note;

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              await context.read<NotesProvider>().toggleFavorite(note.id);
            },
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            icon: note.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
          ),
          SlidableAction(
            onPressed: (_) async {
              await context.read<NotesProvider>().deleteNote(note.id);
            },
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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            children: [
              // Play button
              GestureDetector(
                onTap: _togglePlay,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isPlaying ? AppColors.mint : AppColors.coral,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isPlaying ? AppColors.mint : AppColors.coral)
                            .withOpacity(0.35),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.caption.isNotEmpty ? note.caption : 'Voice Memo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.syne(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4)),
                        const SizedBox(width: 4),
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
                        if (note.isFavorite) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.favorite_rounded,
                              color: AppColors.coral, size: 12),
                        ],
                      ],
                    ),
                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        note.tags.map((t) => '#$t').join('  '),
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

              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.coral, size: 20),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 60))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.05, duration: 350.ms, curve: Curves.easeOut);
  }
}