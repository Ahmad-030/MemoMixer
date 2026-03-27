// lib/screens/note_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';


import 'add_note_screen.dart';
import 'app_theme.dart';
import 'note_model.dart';
import 'notes_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Note _note;
  final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _audioPlayer.onPositionChanged
        .listen((p) => setState(() => _position = p));
    _audioPlayer.onDurationChanged
        .listen((d) => setState(() => _total = d));
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_note.audioPath == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(_note.audioPath!));
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _shareNote() async {
    final files = <XFile>[];
    if (_note.photoPath != null) {
      files.add(XFile(_note.photoPath!));
    }
    if (_note.audioPath != null) {
      files.add(XFile(_note.audioPath!));
    }
    String text = _note.caption;
    if (_note.tags.isNotEmpty) {
      text += '\n${_note.tags.map((t) => '#$t').join(' ')}';
    }
    if (files.isNotEmpty) {
      await Share.shareXFiles(files, text: text);
    } else {
      await Share.share(text);
    }
  }

  Future<void> _deleteNote() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Note', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: const Text('This note will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
            const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<NotesProvider>().deleteNote(_note.id);
      if (mounted) Navigator.pop(context);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fav = _note.isFavorite;

    return Scaffold(
      extendBodyBehindAppBar: _note.photoPath != null,
      appBar: AppBar(
        backgroundColor: _note.photoPath != null
            ? Colors.transparent
            : Theme.of(context).colorScheme.background,
        iconTheme: IconThemeData(
          color: _note.photoPath != null ? Colors.white : null,
        ),
        actions: [
          IconButton(
            icon: Icon(
              fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: fav
                  ? AppColors.coral
                  : _note.photoPath != null
                  ? Colors.white
                  : null,
            ),
            onPressed: () async {
              await context
                  .read<NotesProvider>()
                  .toggleFavorite(_note.id);
              setState(() => _note = _note.copyWith(isFavorite: !_note.isFavorite));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: _note.photoPath != null ? Colors.white : null,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddNoteScreen(existingNote: _note),
                ),
              );
              // refresh from provider
              final updated = context
                  .read<NotesProvider>()
                  .allNotes
                  .firstWhere((n) => n?.id == _note.id,
                  orElse: () => _note);
              setState(() => _note = updated);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: _note.photoPath != null ? Colors.white : null,
            ),
            onPressed: _shareNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ─────────────────────────────────
            if (_note.photoPath != null)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _FullPhotoView(path: _note.photoPath!),
                  ),
                ),
                child: SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Image.file(
                    File(_note.photoPath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Caption ───────────────────────
                  if (_note.caption.isNotEmpty) ...[
                    Text(
                      _note.caption,
                      style: GoogleFonts.syne(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                    const SizedBox(height: 12),
                  ],

                  // ── Date ──────────────────────────
                  Text(
                    DateFormat('EEEE, MMM d · h:mm a')
                        .format(_note.createdAt),
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 24),

                  // ── Audio Player ──────────────────
                  if (_note.audioPath != null)
                    _AudioPlayerCard(
                      isPlaying: _isPlaying,
                      position: _position,
                      total: _total,
                      onToggle: _togglePlay,
                      onSeek: (v) async {
                        final seekTo = Duration(
                            seconds: (v * _total.inSeconds).toInt());
                        await _audioPlayer.seek(seekTo);
                      },
                      fmt: _fmt,
                    )
                        .animate(delay: 200.ms)
                        .fadeIn()
                        .slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // ── Tags ──────────────────────────
                  if (_note.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _note.tags
                          .map(
                            (t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.coral.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.coral.withOpacity(0.3)),
                          ),
                          child: Text(
                            '#$t',
                            style: GoogleFonts.syne(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.coral,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ).animate(delay: 250.ms).fadeIn(),

                  const SizedBox(height: 40),

                  // ── Delete ────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _deleteNote,
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.red),
                      label: Text(
                        'Delete Note',
                        style: GoogleFonts.syne(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ).animate(delay: 300.ms).fadeIn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioPlayerCard extends StatelessWidget {
  final bool isPlaying;
  final Duration position, total;
  final VoidCallback onToggle;
  final void Function(double) onSeek;
  final String Function(Duration) fmt;

  const _AudioPlayerCard({
    required this.isPlaying,
    required this.position,
    required this.total,
    required this.onToggle,
    required this.onSeek,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = total.inSeconds == 0
        ? 0.0
        : position.inSeconds / total.inSeconds;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.warmGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: AppColors.coral,
                        inactiveTrackColor:
                        AppColors.coral.withOpacity(0.2),
                        thumbColor: AppColors.coral,
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: onSeek,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fmt(position),
                              style: GoogleFonts.syne(fontSize: 11)),
                          Text(fmt(total),
                              style: GoogleFonts.syne(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FullPhotoView extends StatelessWidget {
  final String path;
  const _FullPhotoView({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoView(
        imageProvider: FileImage(File(path)),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
      ),
    );
  }
}