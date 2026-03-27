// lib/search_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_theme.dart';
import 'note_list_tile.dart';
import 'notes_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<NotesProvider>().searchNotes(_searchController.text);
      setState(() {}); // rebuild for suffix icon
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    // Clear the search when leaving screen
    context.read<NotesProvider>().searchNotes('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<NotesProvider>();
    final allTags = provider.allTags;
    final activeTags = provider.activeTagFilters;
    final results = provider.filteredNotes;
    final hasQuery = _searchController.text.isNotEmpty || activeTags.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search',
          style: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.coral
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: _focusNode.hasFocus ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral
                        .withOpacity(_focusNode.hasFocus ? 0.12 : 0),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: true,
                style: GoogleFonts.syne(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by caption or tag…',
                  hintStyle: GoogleFonts.syne(
                    color: colorScheme.onSurface.withOpacity(0.35),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: Icon(
                      Icons.search_rounded,
                      color: _focusNode.hasFocus
                          ? AppColors.coral
                          : colorScheme.onSurface.withOpacity(0.35),
                      size: 22,
                    ),
                  ),
                  prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.cancel_rounded,
                      color: colorScheme.onSurface.withOpacity(0.4),
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      provider.searchNotes('');
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0, vertical: 16),
                ),
                onTap: () => setState(() {}),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),

          // ── Tag filter chips ─────────────────────────
          if (allTags.isNotEmpty) ...[
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: allTags.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final tag = allTags[i];
                  final isActive = activeTags.contains(tag);
                  return GestureDetector(
                    onTap: () => provider.toggleTagFilter(tag),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.coral
                            : (isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppColors.coral
                              : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: GoogleFonts.syne(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? Colors.white
                              : colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 8),

          // ── Results header ───────────────────────────
          if (hasQuery)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                children: [
                  Text(
                    '${results.length} result${results.length == 1 ? '' : 's'}',
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.coral,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (activeTags.isNotEmpty)
                    GestureDetector(
                      onTap: provider.clearFilters,
                      child: Text(
                        'Clear filters',
                        style: GoogleFonts.syne(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.4),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ).animate(delay: 50.ms).fadeIn(),

          // ── Results list ─────────────────────────────
          Expanded(
            child: results.isEmpty && hasQuery
                ? _EmptySearch()
                : !hasQuery
                ? _SearchPrompt()
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: results.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (_, i) {
                return NoteListTile(note: results[i])
                    .animate(
                    delay: Duration(milliseconds: i * 45))
                    .fadeIn(duration: 300.ms)
                    .slideX(
                    begin: 0.04,
                    duration: 300.ms,
                    curve: Curves.easeOut);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state when search has no matches ────────────────

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.coral.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 40, color: AppColors.coral),
          ),
          const SizedBox(height: 20),
          Text(
            'No notes found',
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or tags',
            style: GoogleFonts.syne(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(
        begin: const Offset(0.9, 0.9),
        curve: Curves.easeOutBack,
      ),
    );
  }
}

// ── Prompt before any query ───────────────────────────────

class _SearchPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.mint.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.manage_search_rounded,
                size: 40, color: AppColors.mint),
          ),
          const SizedBox(height: 20),
          Text(
            'Find your notes',
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search by caption, or tap a tag above',
            style: GoogleFonts.syne(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}