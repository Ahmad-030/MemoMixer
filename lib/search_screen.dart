// lib/search_screen.dart
import 'dart:ui';
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
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<NotesProvider>().searchNotes(_searchController.text);
      setState(() {});
    });
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    context.read<NotesProvider>().searchNotes('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<NotesProvider>();
    final allTags = provider.allTags;
    final activeTags = provider.activeTagFilters;
    final results = provider.filteredNotes;
    final hasQuery =
        _searchController.text.isNotEmpty || activeTags.isNotEmpty;
    final isFocused = _focusNode.hasFocus;

    return Scaffold(
      backgroundColor: cs.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: cs.background,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                ),
                child: Icon(Icons.arrow_back_rounded,
                    size: 18, color: cs.onBackground),
              ),
            ),
            title: Text(
              'Search',
              style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isFocused
                          ? AppColors.neonCoral
                          : (isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                      width: isFocused ? 2 : 1.5,
                    ),
                    boxShadow: isFocused
                        ? [
                      BoxShadow(
                        color: AppColors.neonCoral.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                        : null,
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    autofocus: true,
                    style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Caption, tag, anything…',
                      hintStyle: GoogleFonts.spaceGrotesk(
                          color: cs.onSurface.withOpacity(0.35),
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 10),
                        child: Icon(
                          Icons.search_rounded,
                          color: isFocused
                              ? AppColors.neonCoral
                              : cs.onSurface.withOpacity(0.35),
                          size: 22,
                        ),
                      ),
                      prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.cancel_rounded,
                            color: cs.onSurface.withOpacity(0.4),
                            size: 20),
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
                          horizontal: 0, vertical: 18),
                    ),
                    onTap: () => setState(() {}),
                  ),
                ),
              ),
            ),
          ),

          // ── Tag chips ──────────────────────────────
          if (allTags.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
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
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? const LinearGradient(colors: [
                            AppColors.neonCoral,
                            Color(0xFFFF8FA3)
                          ])
                              : null,
                          color: isActive
                              ? null
                              : (isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isActive
                                ? AppColors.neonCoral
                                : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                            width: 1.5,
                          ),
                          boxShadow: isActive
                              ? [
                            BoxShadow(
                              color:
                              AppColors.neonCoral.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : null,
                        ),
                        child: Text(
                          '#$tag',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    )
                        .animate(
                        delay: Duration(milliseconds: i * 40))
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.1, duration: 300.ms);
                  },
                ),
              ),
            ),

          if (allTags.isNotEmpty)
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Results header ─────────────────────────
          if (hasQuery)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.neonCoral.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.neonCoral.withOpacity(0.25)),
                      ),
                      child: Text(
                        '${results.length} result${results.length == 1 ? '' : 's'}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neonCoral,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (activeTags.isNotEmpty)
                      GestureDetector(
                        onTap: provider.clearFilters,
                        child: Text(
                          'Clear all',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.38),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ).animate(delay: 50.ms).fadeIn(),
            ),

          // ── Results ────────────────────────────────
          if (!hasQuery)
            SliverFillRemaining(child: _SearchPrompt())
          else if (results.isEmpty)
            SliverFillRemaining(child: _EmptySearch())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: NoteListTile(note: results[i])
                        .animate(
                        delay: Duration(milliseconds: i * 45))
                        .fadeIn(duration: 300.ms)
                        .slideX(
                        begin: 0.05,
                        duration: 300.ms,
                        curve: Curves.easeOut),
                  ),
                  childCount: results.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.neonCoral.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.neonCoral.withOpacity(0.2), width: 1.5),
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 38, color: AppColors.neonCoral),
          ),
          const SizedBox(height: 24),
          Text('No results found',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7))),
          const SizedBox(height: 8),
          Text('Try different keywords or tags',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.38))),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(
        begin: const Offset(0.9, 0.9),
        curve: Curves.easeOutBack,
      ),
    );
  }
}

class _SearchPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.electricBlue.withOpacity(0.2), width: 1.5),
            ),
            child: const Icon(Icons.manage_search_rounded,
                size: 38, color: AppColors.electricBlue),
          ),
          const SizedBox(height: 24),
          Text('Find your notes',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7))),
          const SizedBox(height: 8),
          Text('Search by caption, or tap a tag above',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.38))),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}