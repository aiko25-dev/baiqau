import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/platform_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'home_screen.dart';
import 'competitions_screen.dart';
import 'work_screen.dart';
import 'results_screen.dart';
import 'profile_screen.dart';
import 'role_selection_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final role = p.currentUser!.role;
    final workLabel = role == UserRole.participant
        ? 'Жұмыстарым'
        : role == UserRole.jury
        ? 'Бағалау'
        : 'Жұмыстар';
    final titles = ['baiqau', 'Байқаулар', workLabel, 'Нәтижелер', 'Профиль'];
    final pages = [
      HomeScreen(
        onCompetitions: () => setState(() => _index = 1),
        onWork: () => setState(() => _index = 2),
      ),
      const CompetitionsScreen(),
      const WorkScreen(),
      const ResultsScreen(embedded: true),
      const ProfileScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (_index == 0) ...[
              const BrandLogo(size: 30),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                titles[_index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: _index == 0 ? -.7 : 0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              key: const Key('switch-role'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.softPurple,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: p.saving
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const RoleSelectionScreen(switching: true),
                      ),
                    ),
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: const Text('Demo', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
        bottom: p.saving
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x097041C6),
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Басты бет',
              ),
              const NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events_rounded),
                label: 'Байқаулар',
              ),
              NavigationDestination(
                icon: Icon(
                  role == UserRole.jury
                      ? Icons.fact_check_outlined
                      : Icons.description_outlined,
                ),
                selectedIcon: Icon(
                  role == UserRole.jury
                      ? Icons.fact_check_rounded
                      : Icons.description_rounded,
                ),
                label: workLabel,
              ),
              const NavigationDestination(
                icon: Icon(Icons.leaderboard_outlined),
                selectedIcon: Icon(Icons.leaderboard_rounded),
                label: 'Нәтижелер',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Профиль',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
