// lib/note_detail_screen.dart
import 'dart:io';
import 'dart:ui';
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
        .listen((p) => mounted ? setState(() => _position = p) : null);
    _audioPlayer.onDurationChanged
        .listen((d) => mounted ? setState(() => _total = d) : null);
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() { _isPlaying = false; _position = Duration.zero; });
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
    if (_note.photoPath != null) files.add(XFile(_note.photoPath!));
    if (_note.audioPath != null) files.add(XFile(_note.audioPath!));
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
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteConfirmSheet(),
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
    final hasPhoto = _note.photoPath != null;

    return Scaffold(
      extendBodyBehindAppBar: hasPhoto,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: hasPhoto ? Colors.transparent : null,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasPhoto
                  ? Colors.black.withOpacity(0.35)
                  : (isDark ? AppColors.darkCard : AppColors.lightCard),
              borderRadius: BorderRadius.circular(12),
              border: hasPhoto
                  ? null
                  : Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasPhoto
                  ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: const Icon(Icons.arrow_back_rounded,
                    size: 18, color: Colors.white),
              )
                  : Icon(Icons.arrow_back_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onBackground),
            ),
          ),
        ),
        actions: [
          _AppBarAction(
            icon: fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: fav ? AppColors.neonCoral : null,
            isGlass: hasPhoto,
            onTap: () async {
              await context.read<NotesProvider>().toggleFavorite(_note.id);
              setState(() =>
              _note = _note.copyWith(isFavorite: !_note.isFavorite));
            },
          ),
          _AppBarAction(
            icon: Icons.edit_rounded,
            isGlass: hasPhoto,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddNoteScreen(existingNote: _note)),
              );
              final updated = context
                  .read<NotesProvider>()
                  .allNotes
                  .firstWhere((n) => n?.id == _note.id, orElse: () => _note);
              setState(() => _note = updated);
            },
          ),
          _AppBarAction(
            icon: Icons.share_rounded,
            isGlass: hasPhoto,
            onTap: _shareNote,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Immersive photo ───────────────────────
            if (hasPhoto)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          _FullPhotoView(path: _note.photoPath!)),
                ),
                child: SizedBox(
                  height: 360,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(_note.photoPath!), fit: BoxFit.cover),
                      // Bottom fade
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 120,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Theme.of(context).colorScheme.background,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),

            Padding(
              padding: EdgeInsets.fromLTRB(
                  24, hasPhoto ? 0 : 16, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Caption ────────────────────────
                  if (_note.caption.isNotEmpty) ...[
                    Text(
                      _note.caption,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1.4,
                        color:
                        Theme.of(context).colorScheme.onBackground,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 100.ms)
                        .slideY(begin: 0.1),
                    const SizedBox(height: 12),
                  ],

                  // ── Date chip ──────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCard
                          : AppColors.warmGrey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.5)),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('EEEE, MMM d · h:mm a')
                              .format(_note.createdAt),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 28),

                  // ── Audio player ───────────────────
                  if (_note.audioPath != null)
                    _GlassAudioPlayer(
                      isPlaying: _isPlaying,
                      position: _position,
                      total: _total,
                      onToggle: _togglePlay,
                      onSeek: (v) async {
                        final seekTo = Duration(
                            seconds:
                            (v * _total.inSeconds).toInt());
                        await _audioPlayer.seek(seekTo);
                      },
                      fmt: _fmt,
                      isDark: isDark,
                    )
                        .animate(delay: 200.ms)
                        .fadeIn()
                        .slideY(begin: 0.1),

                  if (_note.audioPath != null)
                    const SizedBox(height: 28),

                  // ── Tags ───────────────────────────
                  if (_note.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _note.tags
                          .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.neonCoral
                                  .withOpacity(0.1),
                              AppColors.electricBlue
                                  .withOpacity(0.06),
                            ],
                          ),
                          borderRadius:
                          BorderRadius.circular(30),
                          border: Border.all(
                              color: AppColors.neonCoral
                                  .withOpacity(0.25)),
                        ),
                        child: Text('#$t',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neonCoral,
                            )),
                      ))
                          .toList(),
                    ).animate(delay: 250.ms).fadeIn(),
                    const SizedBox(height: 36),
                  ],

                  // ── Delete ─────────────────────────
                  GestureDetector(
                    onTap: _deleteNote,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: Colors.red.withOpacity(0.2),
                            width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: Colors.red.shade400, size: 18),
                          const SizedBox(width: 8),
                          Text('Delete Note',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.red.shade400,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              )),
                        ],
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

// ── App bar action button ─────────────────────────────────
class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final bool isGlass;
  final VoidCallback onTap;

  const _AppBarAction({
    required this.icon,
    required this.onTap,
    this.color,
    this.isGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4, top: 10, bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: isGlass
              ? BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black.withOpacity(0.3),
              child: Icon(icon,
                  size: 18,
                  color: color ?? Colors.white),
            ),
          )
              : Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
              isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder),
            ),
            child: Icon(icon,
                size: 18,
                color: color ??
                    Theme.of(context).colorScheme.onBackground),
          ),
        ),
      ),
    );
  }
}

// ── Glass audio player ────────────────────────────────────
class _GlassAudioPlayer extends StatelessWidget {
  final bool isPlaying;
  final Duration position, total;
  final VoidCallback onToggle;
  final void Function(double) onSeek;
  final String Function(Duration) fmt;
  final bool isDark;

  const _GlassAudioPlayer({
    required this.isPlaying,
    required this.position,
    required this.total,
    required this.onToggle,
    required this.onSeek,
    required this.fmt,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total.inMilliseconds == 0
        ? 0.0
        : position.inMilliseconds / total.inMilliseconds;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.warmGrey,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPlaying
              ? AppColors.electricBlue.withOpacity(0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isPlaying ? 1.5 : 1,
        ),
        boxShadow: isPlaying
            ? [
          BoxShadow(
            color: AppColors.electricBlue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ]
            : null,
      ),
      child: Row(
        children: [
          // Play/pause
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPlaying
                      ? [AppColors.neonMint, const Color(0xFF00C878)]
                      : [AppColors.electricBlue, const Color(0xFF738EFF)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isPlaying
                        ? AppColors.neonMint
                        : AppColors.electricBlue)
                        .withOpacity(0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: AppColors.electricBlue,
                    inactiveTrackColor:
                    AppColors.electricBlue.withOpacity(0.15),
                    thumbColor: AppColors.electricBlue,
                    trackHeight: 3,
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
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5))),
                      Text(fmt(total),
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Delete confirmation sheet ─────────────────────────────
class _DeleteConfirmSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCard,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: Colors.red, size: 26),
          ),
          const SizedBox(height: 16),
          Text('Delete Note',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('This will permanently delete your note and cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.55))),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.warmGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('Cancel',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text('Delete',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
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
        backgroundColor: Colors.black.withOpacity(0.5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoView(
        imageProvider: FileImage(File(path)),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}