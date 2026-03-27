// lib/screens/home_screen.dart
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

  final _tabs = const [
    Tab(icon: Icon(Icons.photo_library_rounded), text: 'Photos'),
    Tab(icon: Icon(Icons.mic_rounded), text: 'Audio'),
    Tab(icon: Icon(Icons.layers_rounded), text: 'Combined'),
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          'MemoMixer',
          style: GoogleFonts.syne(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.warmGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(14),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: isDark
                  ? AppColors.offWhite.withOpacity(0.5)
                  : AppColors.navy.withOpacity(0.5),
              labelStyle: GoogleFonts.syne(
                  fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.syne(
                  fontSize: 12, fontWeight: FontWeight.w500),
              tabs: _tabs,
            ),
          ),
        ),
      ),
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
      floatingActionButton: FloatingActionButton.extended(
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
                  parent: anim,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        label: Text(
          'New Note',
          style: GoogleFonts.syne(fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.add_rounded),
      )
          .animate()
          .scale(delay: 400.ms, duration: 400.ms, curve: Curves.elasticOut),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
    isDark ? AppColors.darkCard : AppColors.warmGrey;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(20),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.1)),
    );
  }
}