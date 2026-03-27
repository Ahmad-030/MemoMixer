// lib/add_note_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_theme.dart';
import 'note_model.dart';
import 'notes_provider.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? existingNote;
  const AddNoteScreen({super.key, this.existingNote});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _captionController = TextEditingController();
  final _tagController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();

  String? _photoPath;
  String? _audioPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _recordDuration = Duration.zero;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      final n = widget.existingNote!;
      _captionController.text = n.caption;
      _photoPath = n.photoPath;
      _audioPath = n.audioPath;
      _tags = List.from(n.tags);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ── Image ─────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        // Request camera permission explicitly
        final cameraPerm = await Permission.camera.request();
        if (!cameraPerm.isGranted) {
          if (mounted) {
            _showPermissionDenied('Camera');
          }
          return;
        }
      }
      // For gallery, image_picker handles permissions internally on modern Android/iOS
      // Only request photos permission on iOS or older Android
      if (source == ImageSource.gallery && Platform.isIOS) {
        final photosPerm = await Permission.photos.request();
        if (!photosPerm.isGranted && !photosPerm.isLimited) {
          if (mounted) _showPermissionDenied('Photos');
          return;
        }
      }

      final xFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (xFile != null && mounted) {
        setState(() => _photoPath = xFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showPermissionDenied(String permName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$permName permission denied. Enable it in Settings.'),
        backgroundColor: Colors.redAccent,
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: openAppSettings,
        ),
      ),
    );
  }

  // ── Audio ─────────────────────────────────────────────
  Future<void> _toggleRecording() async {
    final perm = await Permission.microphone.request();
    if (!perm.isGranted) {
      if (mounted) _showPermissionDenied('Microphone');
      return;
    }

    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
      });
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/memo_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      setState(() {
        _isRecording = true;
        _recordDuration = Duration.zero;
      });
      Stream.periodic(const Duration(seconds: 1)).listen((_) {
        if (_isRecording && mounted) {
          setState(() => _recordDuration += const Duration(seconds: 1));
        }
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_audioPath == null) return;
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
      setState(() => _isPlaying = true);
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  // ── Tags ──────────────────────────────────────────────
  void _addTag(String tag) {
    tag = tag.trim().toLowerCase();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _tagController.clear();
    });
  }

  void _removeTag(String tag) => setState(() => _tags.remove(tag));

  // ── Save ──────────────────────────────────────────────
  Future<void> _save() async {
    if (_photoPath == null && _audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add a photo or audio to continue.',
            style: GoogleFonts.syne(),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final provider = context.read<NotesProvider>();

    if (widget.existingNote != null) {
      final updated = widget.existingNote!.copyWith(
        caption: _captionController.text.trim(),
        photoPath: _photoPath,
        audioPath: _audioPath,
        tags: _tags,
      );
      await provider.updateNote(updated);
    } else {
      final note = Note(
        id: const Uuid().v4(),
        caption: _captionController.text.trim(),
        photoPath: _photoPath,
        audioPath: _audioPath,
        tags: _tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await provider.addNote(note);
    }
    if (mounted) Navigator.pop(context);
  }

  String _fmtDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingNote != null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.warmGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Note' : 'New Note',
          style: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _save,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coral.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  isEditing ? 'Update' : 'Save',
                  style: GoogleFonts.syne(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo Section ──
            _SectionLabel(label: 'Photo'),
            const SizedBox(height: 12),
            _PhotoPicker(
              photoPath: _photoPath,
              onCamera: () => _pickImage(ImageSource.camera),
              onGallery: () => _pickImage(ImageSource.gallery),
              onRemove: () => setState(() => _photoPath = null),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 28),

            // ── Audio Section ──
            _SectionLabel(label: 'Audio'),
            const SizedBox(height: 12),
            _AudioRecorderWidget(
              isRecording: _isRecording,
              isPlaying: _isPlaying,
              audioPath: _audioPath,
              recordDuration: _recordDuration,
              onToggleRecord: _toggleRecording,
              onTogglePlay: _togglePlayback,
              onRemove: () => setState(() => _audioPath = null),
              fmtDuration: _fmtDuration,
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 28),

            // ── Caption ──
            _SectionLabel(label: 'Caption'),
            const SizedBox(height: 12),
            TextField(
              controller: _captionController,
              maxLines: 3,
              style: GoogleFonts.syne(fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: 'Add a caption…',
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 28),

            // ── Tags ──
            _SectionLabel(label: 'Tags'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    style: GoogleFonts.syne(fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: 'Add tag (e.g. work, idea…)',
                    ),
                    onSubmitted: _addTag,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _addTag(_tagController.text),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.coral,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coral.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags
                    .map(
                      (t) => Chip(
                    label: Text('#$t',
                        style:
                        GoogleFonts.syne(fontWeight: FontWeight.w600)),
                    onDeleted: () => _removeTag(t),
                    deleteIcon:
                    const Icon(Icons.close_rounded, size: 16),
                    backgroundColor: isDark
                        ? AppColors.darkBorder
                        : AppColors.warmGrey,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                )
                    .toList(),
              ).animate(delay: 50.ms).fadeIn(),
            ],

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.coral,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.syne(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.coral,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onCamera, onGallery, onRemove;
  const _PhotoPicker({
    required this.photoPath,
    required this.onCamera,
    required this.onGallery,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPath != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              File(photoPath!),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
          // Change photo button
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: onGallery,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Change',
                      style: GoogleFonts.syne(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _MediaButton(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            subtitle: 'Take a photo',
            color: AppColors.coral,
            onTap: onCamera,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MediaButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            subtitle: 'Pick from library',
            color: AppColors.mint,
            onTap: onGallery,
          ),
        ),
      ],
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _MediaButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.syne(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.syne(
                fontSize: 10,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioRecorderWidget extends StatelessWidget {
  final bool isRecording, isPlaying;
  final String? audioPath;
  final Duration recordDuration;
  final VoidCallback onToggleRecord, onTogglePlay, onRemove;
  final String Function(Duration) fmtDuration;

  const _AudioRecorderWidget({
    required this.isRecording,
    required this.isPlaying,
    required this.audioPath,
    required this.recordDuration,
    required this.onToggleRecord,
    required this.onTogglePlay,
    required this.onRemove,
    required this.fmtDuration,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecording
              ? Colors.red.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isRecording ? 2 : 1.5,
        ),
        boxShadow: isRecording
            ? [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: Row(
        children: [
          // Record button
          GestureDetector(
            onTap: onToggleRecord,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isRecording ? Colors.red : AppColors.coral,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? Colors.red : AppColors.coral)
                        .withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
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
                Text(
                  isRecording
                      ? 'Recording…'
                      : audioPath != null
                      ? 'Audio recorded ✓'
                      : 'Tap to record',
                  style: GoogleFonts.syne(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: audioPath != null && !isRecording
                        ? AppColors.mint
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (isRecording) ...[
                  const SizedBox(height: 4),
                  Text(
                    fmtDuration(recordDuration),
                    style: GoogleFonts.syne(
                      fontSize: 13,
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 500.ms),
                ] else if (audioPath == null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Voice memo',
                    style: GoogleFonts.syne(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (audioPath != null && !isRecording) ...[
            IconButton(
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_filled_rounded,
                color: AppColors.mint,
                size: 38,
              ),
              onPressed: onTogglePlay,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 22),
              onPressed: onRemove,
            ),
          ],
        ],
      ),
    );
  }
}