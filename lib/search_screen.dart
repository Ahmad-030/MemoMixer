import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'notes_provider.dart';
import 'note_list_tile.dart'; // ✅ Fix: import NoteListTile

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<NotesProvider>().searchNotes(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Fix: removed unused 'isDark' variable
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<NotesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: GoogleFonts.syne(fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: GoogleFonts.syne(
                  color: colorScheme.onSurface.withValues(alpha: 0.4), // ✅ Fix: withValues instead of withOpacity
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.4), // ✅ Fix
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    context.read<NotesProvider>().searchNotes('');
                  },
                )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: provider.filteredNotes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.2), // ✅ Fix: onSurface instead of onBackground
            ),
            const SizedBox(height: 16),
            Text(
              'No notes found',
              style: GoogleFonts.syne(
                fontSize: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.4), // ✅ Fix
              ),
            ),
          ],
        ).animate().fadeIn(),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.filteredNotes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final note = provider.filteredNotes[i];
          return NoteListTile(note: note) // ✅ Fix: NoteListTile now imported and defined
              .animate(delay: Duration(milliseconds: i * 50))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.05);
        },
      ),
    );
  }
}