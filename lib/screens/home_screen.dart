import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/competition.dart';
import '../models/user.dart';
import '../providers/platform_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/competition_card.dart';
import '../core/formatters.dart';
import 'competition_details_screen.dart';
import 'create_competition_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onCompetitions,
    required this.onWork,
  });
  final VoidCallback onCompetitions;
  final VoidCallback onWork;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final user = p.currentUser!;
    final active = p.competitions
        .where((c) => p.status(c) == CompetitionStatus.active)
        .toList();
    final myWorks = p.submissions
        .where((s) => s.participantId == user.id)
        .length;
    final pending = p.submissions
        .where(
          (s) =>
              p.status(p.competition(s.competitionId)) !=
                  CompetitionStatus.published &&
              p.myGrade(s.id) == null,
        )
        .length;
    final organizer = user.role == UserRole.organizer;
    final jury = user.role == UserRole.jury;
    return PageBody(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сәлем, ${user.name.split(' ').first}! 👋',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    longDate(p.now),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.softPurple,
              child: Text(
                user.initials,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryStrong,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppStyles.lavenderGradient,
            borderRadius: BorderRadius.circular(AppStyles.cardRadius),
            boxShadow: AppStyles.softShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -50,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface.withValues(alpha: .45),
                      width: 28,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 14,
                bottom: 24,
                child: Icon(
                  Icons.emoji_events_outlined,
                  size: 104,
                  color: AppColors.primaryLight.withValues(alpha: .16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_outlined,
                          size: 16,
                          color: AppColors.primaryStrong,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Бүгінгі мүмкіндік',
                            style: TextStyle(
                              color: AppColors.primaryStrong,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      organizer
                          ? 'Таланттарға\nмүмкіндік бер.'
                          : jury
                          ? 'Үздіктерді\nбірге анықтайық.'
                          : 'Үлкен жеңіс\nидеядан басталады.',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        letterSpacing: -.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      organizer
                          ? 'Жаңа байқау жариялап, қатысушыларды шабыттандыр.'
                          : jury
                          ? 'Әр жұмысқа әділ баға, әр идеяға құнды пікір.'
                          : 'Өзіңе сен. Байқау таңда. Жұмысыңды көрсет.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: organizer
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateCompetitionScreen(),
                              ),
                            )
                          : jury
                          ? onWork
                          : onCompetitions,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 50),
                      ),
                      icon: Icon(
                        organizer
                            ? Icons.add_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                      label: Text(
                        organizer
                            ? 'Байқау құру'
                            : jury
                            ? 'Бағалауды бастау'
                            : 'Байқауларды қарау',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${active.length}',
                label: 'Белсенді байқау',
                icon: Icons.emoji_events_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value:
                    '${jury
                        ? pending
                        : organizer
                        ? p.submissions.length
                        : myWorks}',
                label: jury
                    ? 'Бағалауды күтеді'
                    : organizer
                    ? 'Жіберілген жұмыс'
                    : 'Менің жұмысым',
                icon: Icons.description_outlined,
                color: AppColors.science,
              ),
            ),
          ],
        ),
        SectionTitle(
          'Мүмкіндіктерді аш',
          action: 'Барлығы',
          onAction: onCompetitions,
        ),
        if (active.isEmpty)
          const StateMessage(
            title: 'Қабылдау ашық байқау жоқ',
            message: 'Жаңа байқаулар кейін осы жерде көрінеді.',
          ),
        ...active
            .take(2)
            .map(
              (c) => CompetitionCard(
                competition: c,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CompetitionDetailsScreen(competitionId: c.id),
                  ),
                ),
              ),
            ),
        const SectionTitle('Платформа жаңалықтары'),
        ...p.competitions
            .where((c) => p.status(c) == CompetitionStatus.published)
            .take(2)
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CompetitionDetailsScreen(competitionId: c.id),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const SoftIcon(Icons.celebration_outlined),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Жеңімпаздар анықталды',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  c.title,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.primaryLight,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        const SizedBox(height: 10),
        const InfoBanner(
          'Әділ бағалау: шығармашылық 40%, орындау сапасы 35%, ұсыну деңгейі 25%. Әр идеяның өз мүмкіндігі бар.',
        ),
      ],
    );
  }
}
