// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


import 'app_theme.dart';
import 'notes_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    context.read<NotesProvider>().clearFilters();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: provider.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Search notes…',
            hintStyle: GoogleFonts.syne(
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.4)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
          style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (provider.searchQuery.isNotEmpty || provider.activeTagFilters.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _controller.clear();
                provider.clearFilters();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Tag filters
          if (provider.allTags.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: provider.allTags.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final tag = provider.allTags[i];
                  final active = provider.activeTagFilters.contains(tag);
                  return FilterChip(
                    label: Text('#$tag'),
                    selected: active,
                    onSelected: (_) => provider.toggleTagFilter(tag),
                    selectedColor: AppColors.coral,
                    checkmarkColor: Colors.white,
                    labelStyle: GoogleFonts.syne(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : null,
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 300.ms),

          const Divider(height: 1),

          // Results
          Expanded(
            child: provider.filteredNotes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'No notes found',
                    style: GoogleFonts.syne(
                      fontSize: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.4),
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
                return NoteListTile(note: note)
                    .animate(delay: Duration(milliseconds: i * 50))
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.05);
              },
            ),
          ),
        ],
      ),
    );
  }
}