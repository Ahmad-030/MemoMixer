// lib/models/note_model.dart
import 'dart:convert';

enum NoteType { photo, audio, combined }

class Note {
  final String id;
  String caption;
  String? photoPath;
  String? audioPath;
  List<String> tags;
  bool isFavorite;
  bool isArchived;
  DateTime createdAt;
  DateTime updatedAt;
  NoteType type;
  Duration? audioDuration;

  Note({
    required this.id,
    this.caption = '',
    this.photoPath,
    this.audioPath,
    this.tags = const [],
    this.isFavorite = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.audioDuration,
  }) : type = _resolveType(photoPath, audioPath);

  static NoteType _resolveType(String? photo, String? audio) {
    if (photo != null && audio != null) return NoteType.combined;
    if (photo != null) return NoteType.photo;
    return NoteType.audio;
  }

  void refreshType() {
    // re-resolve based on current paths (mutable fields)
  }

  NoteType get resolvedType => _resolveType(photoPath, audioPath);

  Map<String, dynamic> toJson() => {
    'id': id,
    'caption': caption,
    'photoPath': photoPath,
    'audioPath': audioPath,
    'tags': tags,
    'isFavorite': isFavorite,
    'isArchived': isArchived,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'audioDurationMs': audioDuration?.inMilliseconds,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    caption: json['caption'] as String? ?? '',
    photoPath: json['photoPath'] as String?,
    audioPath: json['audioPath'] as String?,
    tags: List<String>.from(json['tags'] as List? ?? []),
    isFavorite: json['isFavorite'] as bool? ?? false,
    isArchived: json['isArchived'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    audioDuration: json['audioDurationMs'] != null
        ? Duration(milliseconds: json['audioDurationMs'] as int)
        : null,
  );

  Note copyWith({
    String? caption,
    String? photoPath,
    String? audioPath,
    List<String>? tags,
    bool? isFavorite,
    bool? isArchived,
    DateTime? updatedAt,
    Duration? audioDuration,
  }) =>
      Note(
        id: id,
        caption: caption ?? this.caption,
        photoPath: photoPath ?? this.photoPath,
        audioPath: audioPath ?? this.audioPath,
        tags: tags ?? List.from(this.tags),
        isFavorite: isFavorite ?? this.isFavorite,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        audioDuration: audioDuration ?? this.audioDuration,
      );

  static List<Note> listFromJson(String jsonStr) {
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<Note> notes) =>
      jsonEncode(notes.map((n) => n.toJson()).toList());
}