// lib/home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memomixer/photo_notes_tab.dart';
import 'package:provider/provider.dart';

import 'add_note_screen.dart';
import 'app_theme.dart';
import 'audio_notes_tab.dart';
import 'combined_notes_tab.dart';
import 'notes_provider.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  final _tabData = const [
    _TabInfo(Icons.photo_library_rounded, 'Photos', AppColors.neonCoral),
    _TabInfo(Icons.mic_rounded, 'Audio', AppColors.electricBlue),
    _TabInfo(Icons.layers_rounded, 'Mixed', AppColors.neonMint),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _currentTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesProvider = context.watch<NotesProvider>();
    final activeColor = _tabData[_currentTab].color;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBody: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            snap: true,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _HomeHeader(isDark: isDark),
            ),
            actions: [
              _NavIconButton(
                icon: Icons.search_rounded,
                onTap: () => Navigator.push(context,
                    _slideRoute(const SearchScreen())),
              ),
              _NavIconButton(
                icon: Icons.settings_rounded,
                onTap: () => Navigator.push(context,
                    _slideRoute(const SettingsScreen())),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: _GlassyTabBar(
                controller: _tabController,
                tabs: _tabData,
                currentIndex: _currentTab,
                isDark: isDark,
              ),
            ),
          ),
        ],
        body: notesProvider.isLoading
            ? const _LoadingShimmer()
            : TabBarView(
          controller: _tabController,
          children: const [
            PhotoNotesTab(),
            AudioNotesTab(),
            CombinedNotesTab(),
          ],
        ),
      ),
      floatingActionButton: _PulseFab(
        color: activeColor,
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, __) => const AddNoteScreen(),
              transitionsBuilder: (_, anim, __, child) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 450),
            ),
          );
        },
      ).animate().scale(
        delay: 600.ms,
        duration: 500.ms,
        curve: Curves.elasticOut,
      ),
    );
  }

  Route _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
            begin: const Offset(0.04, 0), end: Offset.zero)
            .animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );
}

// ── Tab data model ────────────────────────────────────────
class _TabInfo {
  final IconData icon;
  final String label;
  final Color color;
  const _TabInfo(this.icon, this.label, this.color);
}

// ── Home header with animated gradient blob ───────────────
class _HomeHeader extends StatelessWidget {
  final bool isDark;
  const _HomeHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient blobs
        Positioned(
          top: -30,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.neonCoral.withOpacity(isDark ? 0.18 : 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 4000.ms, curve: Curves.easeInOut,
              begin: const Offset(1, 1), end: const Offset(1.15, 1.15)),
        ),
        Positioned(
          top: 10,
          left: -60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.electricBlue.withOpacity(isDark ? 0.15 : 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 5000.ms, curve: Curves.easeInOut,
              begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
        ),
        // Title
        Positioned(
          bottom: 72,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.neonMint,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(end: 1.4, duration: 1200.ms),
                  const SizedBox(width: 8),
                  Text(
                    'MemoMixer',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onBackground,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ],
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1),
        ),
      ],
    );
  }
}

// ── Glassy animated tab bar ────────────────────────────────
class _GlassyTabBar extends StatelessWidget {
  final TabController controller;
  final List<_TabInfo> tabs;
  final int currentIndex;
  final bool isDark;

  const _GlassyTabBar({
    required this.controller,
    required this.tabs,
    required this.currentIndex,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withOpacity(0.8)
            : AppColors.lightCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: tabs[currentIndex].color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: TabBar(
            controller: controller,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tabs[currentIndex].color,
                  tabs[currentIndex].color.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: tabs[currentIndex].color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: isDark
                ? const Color(0xFF8B90C1)
                : const Color(0xFF8A8FA8),
            labelStyle: GoogleFonts.spaceGrotesk(
                fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: GoogleFonts.spaceGrotesk(
                fontSize: 12, fontWeight: FontWeight.w500),
            tabs: tabs
                .map((t) => Tab(
              icon: Icon(t.icon, size: 18),
              text: t.label,
              iconMargin: const EdgeInsets.only(bottom: 2),
            ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ── Nav icon button ────────────────────────────────────────
class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard.withOpacity(0.7)
              : AppColors.lightCard.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
            isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Icon(icon,
            size: 20,
            color: Theme.of(context).colorScheme.onBackground),
      ),
    );
  }
}

// ── Pulsing FAB ───────────────────────────────────────────
class _PulseFab extends StatefulWidget {
  final Color color;
  final VoidCallback onPressed;
  const _PulseFab({required this.color, required this.onPressed});

  @override
  State<_PulseFab> createState() => _PulseFabState();
}

class _PulseFabState extends State<_PulseFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse ring
        AnimatedBuilder(
          animation: _scale,
          builder: (_, __) => Container(
            width: 64 * _scale.value,
            height: 64 * _scale.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.15),
            ),
          ),
        ),
        FloatingActionButton.extended(
          onPressed: widget.onPressed,
          backgroundColor: widget.color,
          foregroundColor: Colors.white,
          elevation: 8,
          label: Text(
            'New Note',
            style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w700, fontSize: 14),
          ),
          icon: const Icon(Icons.add_rounded, size: 22),
        ),
      ],
    );
  }
}

// ── Loading shimmer ────────────────────────────────────────
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkCard : AppColors.warmGrey;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(24),
        ),
      )
          .animate(delay: Duration(milliseconds: i * 100),
          onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
          duration: 1400.ms,
          color: Colors.white.withOpacity(isDark ? 0.06 : 0.4)),
    );
  }
}