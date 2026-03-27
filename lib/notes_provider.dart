// lib/providers/notes_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_model.dart';

const _kNotesKey = 'mm_notes_v1';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  List<String> _activeTagFilters = [];

  List<Note> get allNotes => _notes.where((n) => !n.isArchived).toList();

  List<Note> get photoNotes => allNotes
      .where((n) => n.resolvedType == NoteType.photo)
      .toList();

  List<Note> get audioNotes => allNotes
      .where((n) => n.resolvedType == NoteType.audio)
      .toList();

  List<Note> get combinedNotes => allNotes
      .where((n) => n.resolvedType == NoteType.combined)
      .toList();

  List<Note> get favoriteNotes => allNotes.where((n) => n.isFavorite).toList();

  List<Note> get archivedNotes => _notes.where((n) => n.isArchived).toList();

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<String> get activeTagFilters => _activeTagFilters;

  List<String> get allTags {
    final tags = <String>{};
    for (final n in _notes) {
      tags.addAll(n.tags);
    }
    return tags.toList()..sort();
  }

  List<Note> get filteredNotes {
    var result = allNotes;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((n) =>
      n.caption.toLowerCase().contains(q) ||
          n.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }
    if (_activeTagFilters.isNotEmpty) {
      result = result
          .where((n) => _activeTagFilters.every((t) => n.tags.contains(t)))
          .toList();
    }
    return result;
  }

  // ── Init ──────────────────────────────────────────────
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kNotesKey);
      if (raw != null && raw.isNotEmpty) {
        _notes = Note.listFromJson(raw);
        // Sort newest first
        _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (_) {
      _notes = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNotesKey, Note.listToJson(_notes));
  }

  // ── CRUD ──────────────────────────────────────────────
  Future<void> addNote(Note note) async {
    _notes.insert(0, note);
    notifyListeners();
    await _persist();
  }

  Future<void> updateNote(Note updated) async {
    final idx = _notes.indexWhere((n) => n.id == updated.id);
    if (idx == -1) return;
    _notes[idx] = updated;
    notifyListeners();
    await _persist();
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final n = _notes[idx];
    _notes[idx] = n.copyWith(isFavorite: !n.isFavorite);
    notifyListeners();
    await _persist();
  }

  Future<void> archiveNote(String id) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    _notes[idx] = _notes[idx].copyWith(isArchived: true);
    notifyListeners();
    await _persist();
  }

  Future<void> unarchiveNote(String id) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    _notes[idx] = _notes[idx].copyWith(isArchived: false);
    notifyListeners();
    await _persist();
  }

  // ── Search & Filter ───────────────────────────────────
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void toggleTagFilter(String tag) {
    if (_activeTagFilters.contains(tag)) {
      _activeTagFilters.remove(tag);
    } else {
      _activeTagFilters.add(tag);
    }
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _activeTagFilters = [];
    notifyListeners();
  }
}