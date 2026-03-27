// lib/audio_notes_tab.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';
import 'empty_state.dart';
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
        subtitle: 'Record a voice memo with the + button.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _AudioCard(note: notes[i], index: i),
    );
  }
}

class _AudioCard extends StatefulWidget {
  final Note note;
  final int index;
  const _AudioCard({required this.note, required this.index});

  @override
  State<_AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<_AudioCard>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  late AnimationController _waveAnim;

  @override
  void initState() {
    super.initState();
    _waveAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _player.dispose();
    _waveAnim.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (widget.note.audioPath == null) return;
    if (_isPlaying) {
      await _player.pause();
      _waveAnim.stop();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(DeviceFileSource(widget.note.audioPath!));
      _waveAnim.repeat(reverse: true);
      setState(() => _isPlaying = true);
      _player.onPlayerComplete.listen((_) {
        if (mounted) {
          _waveAnim.stop();
          setState(() => _isPlaying = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final note = widget.note;

    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async =>
            await context.read<NotesProvider>().toggleFavorite(note.id),
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            icon: note.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            borderRadius:
            const BorderRadius.horizontal(left: Radius.circular(20)),
          ),
          SlidableAction(
            onPressed: (_) async =>
            await context.read<NotesProvider>().deleteNote(note.id),
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            borderRadius:
            const BorderRadius.horizontal(right: Radius.circular(20)),
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
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _isPlaying
                  ? AppColors.electricBlue.withOpacity(0.5)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: _isPlaying ? 1.5 : 1,
            ),
            boxShadow: _isPlaying
                ? [
              BoxShadow(
                color: AppColors.electricBlue.withOpacity(0.12),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ]
                : null,
          ),
          child: Row(
            children: [
              // Play button
              GestureDetector(
                onTap: _togglePlay,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isPlaying
                          ? [AppColors.neonMint, const Color(0xFF00C878)]
                          : [
                        AppColors.electricBlue,
                        const Color(0xFF738EFF)
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isPlaying
                            ? AppColors.neonMint
                            : AppColors.electricBlue)
                            .withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
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
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: -0.3,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Mini waveform visualization
                    if (_isPlaying)
                      _MiniWaveform(controller: _waveAnim)
                    else
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.38)),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d · h:mm a')
                                .format(note.createdAt),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.38),
                            ),
                          ),
                          if (note.isFavorite) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.favorite_rounded,
                                color: AppColors.neonCoral, size: 11),
                          ],
                        ],
                      ),

                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        note.tags.take(3).map((t) => '#$t').join('  '),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: AppColors.electricBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.25),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 60))
        .fadeIn(duration: 380.ms)
        .slideX(begin: 0.06, duration: 380.ms, curve: Curves.easeOut);
  }
}

// ── Mini animated waveform ────────────────────────────────
class _MiniWaveform extends StatelessWidget {
  final AnimationController controller;
  const _MiniWaveform({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          children: List.generate(
            20,
                (i) {
              final offset = (i / 20 * 2 * pi + controller.value * pi * 2);
              final h = 4.0 + 12.0 * ((sin(offset) + 1) / 2);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 60),
                  width: 2.5,
                  height: h,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withOpacity(
                        0.5 + 0.5 * ((sin(offset) + 1) / 2)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}