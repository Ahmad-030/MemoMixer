// lib/add_note_screen.dart
import 'dart:io';
import 'dart:ui';
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

class _AddNoteScreenState extends State<AddNoteScreen>
    with TickerProviderStateMixin {
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

  late AnimationController _recordPulse;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _recordPulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _waveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

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
    _recordPulse.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // ── Real-time Permission Helper ───────────────────────
  Future<bool> _requestPermission(Permission permission, String name) async {
    final status = await permission.status;

    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      if (mounted) _showPermanentlyDenied(name);
      return false;
    }

    final result = await permission.request();
    if (result.isGranted) return true;

    if (result.isPermanentlyDenied && mounted) {
      _showPermanentlyDenied(name);
    } else if (!result.isGranted && mounted) {
      _showSnack('$name permission is required for this feature.');
    }
    return false;
  }

  void _showPermanentlyDenied(String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PermissionSheet(
        name: name,
        onOpenSettings: () {
          Navigator.pop(context);
          openAppSettings();
        },
      ),
    );
  }

  void _showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.spaceGrotesk()),
        backgroundColor: color ?? AppColors.neonCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Image – uses Android Photo Picker on Android 13+ ──
  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        // Real-time camera permission
        final granted = await _requestPermission(Permission.camera, 'Camera');
        if (!granted) return;
      }
      // For gallery: image_picker uses Android Photo Picker (no storage perm needed on API 33+)
      // On older Android, it handles READ_EXTERNAL_STORAGE internally
      // On iOS we still need photos permission
      if (source == ImageSource.gallery && Platform.isIOS) {
        final status = await Permission.photos.status;
        if (status.isDenied) {
          final result = await Permission.photos.request();
          if (!result.isGranted && !result.isLimited) {
            if (mounted) _showPermanentlyDenied('Photos');
            return;
          }
        }
      }

      final xFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 2048,
      );
      if (xFile != null && mounted) {
        setState(() => _photoPath = xFile.path);
      }
    } catch (e) {
      if (mounted) _showSnack('Could not access media: ${e.toString()}');
    }
  }

  // ── Audio Recording ───────────────────────────────────
  Future<void> _toggleRecording() async {
    // Real-time microphone permission
    final granted =
    await _requestPermission(Permission.microphone, 'Microphone');
    if (!granted) return;

    if (_isRecording) {
      final path = await _audioRecorder.stop();
      _recordPulse.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
        _recordDuration = Duration.zero;
      });
      _showSnack('Recording saved!', color: AppColors.neonMint);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/memo_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
        path: path,
      );
      _recordPulse.repeat(reverse: true);
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
    tag = tag.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
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
      _showSnack('Add a photo or audio recording to continue.');
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
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar ──────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.background,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            title: Text(
              isEditing ? 'Edit Note' : 'New Note',
              style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
            ),
            actions: [
              GestureDetector(
                onTap: _save,
                child: Container(
                  margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.neonCoral, Color(0xFFFF8FA3)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCoral.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    isEditing ? 'Update' : 'Save',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Content ─────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Photo ──
                _NeonSectionLabel(label: 'Photo', color: AppColors.neonCoral),
                const SizedBox(height: 14),
                _PhotoPickerCard(
                  photoPath: _photoPath,
                  onCamera: () => _pickImage(ImageSource.camera),
                  onGallery: () => _pickImage(ImageSource.gallery),
                  onRemove: () => setState(() => _photoPath = null),
                  isDark: isDark,
                ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08),

                const SizedBox(height: 28),

                // ── Audio ──
                _NeonSectionLabel(
                    label: 'Audio', color: AppColors.electricBlue),
                const SizedBox(height: 14),
                _AudioCard(
                  isRecording: _isRecording,
                  isPlaying: _isPlaying,
                  audioPath: _audioPath,
                  recordDuration: _recordDuration,
                  onToggleRecord: _toggleRecording,
                  onTogglePlay: _togglePlayback,
                  onRemove: () => setState(() {
                    _audioPath = null;
                    _isPlaying = false;
                  }),
                  fmtDuration: _fmtDuration,
                  isDark: isDark,
                  pulseController: _recordPulse,
                ).animate(delay: 80.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08),

                const SizedBox(height: 28),

                // ── Caption ──
                _NeonSectionLabel(
                    label: 'Caption', color: AppColors.neonMint),
                const SizedBox(height: 14),
                TextField(
                  controller: _captionController,
                  maxLines: 4,
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w500, fontSize: 15, height: 1.5),
                  decoration: const InputDecoration(
                    hintText: 'What\'s on your mind?',
                  ),
                ).animate(delay: 160.ms).fadeIn(duration: 350.ms),

                const SizedBox(height: 28),

                // ── Tags ──
                _NeonSectionLabel(label: 'Tags', color: AppColors.amber),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w500, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Add a tag…',
                        ),
                        onSubmitted: _addTag,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _addTag(_tagController.text),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.amber, Color(0xFFFFD166)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.amber.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ).animate(delay: 240.ms).fadeIn(duration: 350.ms),

                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags
                        .map((t) => _TagChip(
                      tag: t,
                      onRemove: () => _removeTag(t),
                      isDark: isDark,
                    ))
                        .toList(),
                  ).animate(delay: 50.ms).fadeIn(),
                ],

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Permission bottom sheet ───────────────────────────────
class _PermissionSheet extends StatelessWidget {
  final String name;
  final VoidCallback onOpenSettings;
  const _PermissionSheet({required this.name, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: AppColors.neonCoral.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.neonCoral.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline_rounded,
                color: AppColors.neonCoral, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            '$name Access Required',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '$name permission has been denied. Please enable it in Settings to use this feature.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onOpenSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCoral,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Open Settings',
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not Now',
                style: GoogleFonts.spaceGrotesk(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4))),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────
class _NeonSectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _NeonSectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }
}

// ── Photo picker card ─────────────────────────────────────
class _PhotoPickerCard extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onCamera, onGallery, onRemove;
  final bool isDark;

  const _PhotoPickerCard({
    required this.photoPath,
    required this.onCamera,
    required this.onGallery,
    required this.onRemove,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPath != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.file(
              File(photoPath!),
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Overlay gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          // Remove
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onRemove,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black.withOpacity(0.35),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ),
          // Change
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: onGallery,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    color: Colors.black.withOpacity(0.35),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_rounded,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text('Change',
                            style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
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
            subtitle: 'Take photo',
            gradient: const [AppColors.neonCoral, Color(0xFFFF8FA3)],
            onTap: onCamera,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MediaButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            subtitle: 'Pick image',
            gradient: const [AppColors.electricBlue, Color(0xFF738EFF)],
            onTap: onGallery,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  final bool isDark;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: gradient.first)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.38),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Audio card ────────────────────────────────────────────
class _AudioCard extends StatelessWidget {
  final bool isRecording, isPlaying;
  final String? audioPath;
  final Duration recordDuration;
  final VoidCallback onToggleRecord, onTogglePlay, onRemove;
  final String Function(Duration) fmtDuration;
  final bool isDark;
  final AnimationController pulseController;

  const _AudioCard({
    required this.isRecording,
    required this.isPlaying,
    required this.audioPath,
    required this.recordDuration,
    required this.onToggleRecord,
    required this.onTogglePlay,
    required this.onRemove,
    required this.fmtDuration,
    required this.isDark,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isRecording
              ? AppColors.neonCoral.withOpacity(0.6)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isRecording ? 2 : 1.5,
        ),
        boxShadow: isRecording
            ? [
          BoxShadow(
            color: AppColors.neonCoral.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ]
            : null,
      ),
      child: Row(
        children: [
          // Record button with pulse
          Stack(
            alignment: Alignment.center,
            children: [
              if (isRecording)
                AnimatedBuilder(
                  animation: pulseController,
                  builder: (_, __) => Container(
                    width: 70 + pulseController.value * 14,
                    height: 70 + pulseController.value * 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonCoral
                          .withOpacity(0.15 * (1 - pulseController.value)),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: onToggleRecord,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isRecording
                          ? [Colors.red, const Color(0xFFFF6584)]
                          : [AppColors.neonCoral, const Color(0xFFFF8FA3)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                        (isRecording ? Colors.red : AppColors.neonCoral)
                            .withOpacity(0.45),
                        blurRadius: 20,
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
            ],
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
                      ? 'Audio ready ✓'
                      : 'Tap mic to record',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: audioPath != null && !isRecording
                        ? AppColors.neonMint
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                if (isRecording)
                  Text(
                    fmtDuration(recordDuration),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 600.ms)
                else if (audioPath == null)
                  Text(
                    'Voice memo',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.38),
                    ),
                  ),
              ],
            ),
          ),

          if (audioPath != null && !isRecording) ...[
            GestureDetector(
              onTap: onTogglePlay,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPlaying
                        ? [AppColors.neonMint, const Color(0xFF00E58A)]
                        : [AppColors.electricBlue, const Color(0xFF738EFF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (isPlaying
                          ? AppColors.neonMint
                          : AppColors.electricBlue)
                          .withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.red.withOpacity(0.3), width: 1),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Tag chip ──────────────────────────────────────────────
class _TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback onRemove;
  final bool isDark;
  const _TagChip(
      {required this.tag, required this.onRemove, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8, right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonCoral.withOpacity(0.12),
            AppColors.electricBlue.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: AppColors.neonCoral.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('#$tag',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.neonCoral,
              )),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.neonCoral.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 12, color: AppColors.neonCoral),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).scale(
      begin: const Offset(0.8, 0.8),
      curve: Curves.easeOutBack,
      duration: 250.ms,
    );
  }
}