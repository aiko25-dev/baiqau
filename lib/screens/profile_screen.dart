import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/platform_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'role_selection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final user = p.currentUser!;
    final participant = user.role == UserRole.participant;
    final jury = user.role == UserRole.jury;
    final works = p.submissions
        .where((s) => s.participantId == user.id)
        .toList();
    final grades = p.evaluations.where((e) => e.juryId == user.id).length;
    final wins = p.competitions
        .where((c) => p.canSeeResults(c))
        .expand((c) => p.ranking(c.id))
        .where((r) => r.submission.participantId == user.id && r.rank <= 3)
        .length;
    return PageBody(
      children: [
        Card(
          color: AppColors.softPurple,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.surface,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryStrong,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.department,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StatusBadge(user.role.label, color: AppColors.primaryStrong),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value:
                    '${participant
                        ? works.length
                        : jury
                        ? grades
                        : p.competitions.where((c) => c.organizerId == user.id).length}',
                label: participant
                    ? 'Менің жұмысым'
                    : jury
                    ? 'Менің бағаларым'
                    : 'Менің байқауым',
                icon: roleIcon(user.role),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value:
                    '${participant ? wins : p.users.where((u) => u.role == UserRole.participant).length}',
                label: participant ? 'Жүлделі орын' : 'Қатысушы',
                icon: Icons.workspace_premium_outlined,
                color: AppColors.warningInk,
              ),
            ),
          ],
        ),
        const SectionTitle('Demo басқару'),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const SoftIcon(Icons.swap_horiz_rounded),
            title: const Text(
              'Рөлді ауыстыру',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Ұйымдастырушы, қатысушы немесе қазы',
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: p.saving
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const RoleSelectionScreen(switching: true),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 18),
        const InfoBanner(
          'Бұл demo орта: қолданушы мен рөлді еркін ауыстыра аласыз. Байқаулар, жұмыстар және бағалар құрылғыда сақталады.',
        ),
        const SectionTitle('baiqau туралы'),
        const Text(
          'Идеядан жеңіске.',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
        ),
        const SizedBox(height: 8),
        const Text(
          'Байқаулар өткізуге және қатысушылардың жұмыстарын бағалауға арналған қазақша мобильді платформа.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 14),
        const Text(
          '1.0.0 • Flutter + Material 3',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
