// lib/screens/add_note_screen.dart
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
    final perm = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();
    if (!perm.isGranted) return;

    final xFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (xFile != null) setState(() => _photoPath = xFile.path);
  }

  // ── Audio ─────────────────────────────────────────────
  Future<void> _toggleRecording() async {
    final perm = await Permission.microphone.request();
    if (!perm.isGranted) return;

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
      // Tick timer
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
        const SnackBar(content: Text('Add a photo or audio to continue.')),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: GoogleFonts.syne(
                color: AppColors.coral,
                fontWeight: FontWeight.w700,
                fontSize: 16,
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
            _AudioRecorder(
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
                    decoration: const InputDecoration(
                      hintText: 'Add tag (e.g. work, idea…)',
                    ),
                    onSubmitted: _addTag,
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
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white),
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
                    label: Text('#$t'),
                    onDeleted: () => _removeTag(t),
                    deleteIcon:
                    const Icon(Icons.close_rounded, size: 16),
                    backgroundColor: isDark
                        ? AppColors.darkBorder
                        : AppColors.warmGrey,
                  ),
                )
                    .toList(),
              ).animate(delay: 50.ms).fadeIn(),
            ],

            const SizedBox(height: 40),
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
    return Text(
      label,
      style: GoogleFonts.syne(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.coral,
        letterSpacing: 1.5,
      ),
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
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child:
                const Icon(Icons.close_rounded, color: Colors.white, size: 18),
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
            color: AppColors.coral,
            onTap: onCamera,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MediaButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
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
  final Color color;
  final VoidCallback onTap;
  const _MediaButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
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
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.syne(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioRecorder extends StatelessWidget {
  final bool isRecording, isPlaying;
  final String? audioPath;
  final Duration recordDuration;
  final VoidCallback onToggleRecord, onTogglePlay, onRemove;
  final String Function(Duration) fmtDuration;

  const _AudioRecorder({
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
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Record button
              GestureDetector(
                onTap: onToggleRecord,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isRecording
                        ? Colors.red
                        : AppColors.coral,
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
                    size: 30,
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
                          ? 'Audio recorded'
                          : 'Tap to record',
                      style: GoogleFonts.syne(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (isRecording)
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
                  ],
                ),
              ),
              if (audioPath != null && !isRecording) ...[
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                    color: AppColors.mint,
                    size: 36,
                  ),
                  onPressed: onTogglePlay,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.redAccent),
                  onPressed: onRemove,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}