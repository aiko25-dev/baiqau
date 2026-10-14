import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/formatters.dart';
import '../models/competition.dart';
import '../models/evaluation.dart';
import '../models/user.dart';
import '../providers/platform_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/submission_card.dart';
import 'submit_work_screen.dart';
import 'evaluation_screen.dart';
import 'results_screen.dart';

class CompetitionDetailsScreen extends StatelessWidget {
  const CompetitionDetailsScreen({super.key, required this.competitionId});
  final String competitionId;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final c = p.competition(competitionId);
    final status = p.status(c);
    final works = p.worksFor(c.id);
    final user = p.currentUser!;
    final organizer =
        user.role == UserRole.organizer && user.id == c.organizerId;
    final mine = works.where((s) => s.participantId == user.id).firstOrNull;
    final visibleWorks =
        organizer ||
            user.role == UserRole.jury ||
            status == CompetitionStatus.published
        ? works
        : works.where((s) => s.participantId == user.id).toList();
    final rated = works.where((s) => p.gradesFor(s.id).isNotEmpty).length;
    final color = categoryColor(c.category);
    return Scaffold(
      appBar: AppBar(title: const Text('Байқау туралы')),
      body: PageBody(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppStyles.lavenderGradient,
              borderRadius: BorderRadius.circular(AppStyles.cardRadius),
              boxShadow: AppStyles.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftIcon(
                  categoryIcon(c.category),
                  size: 56,
                  color: color,
                  background: AppColors.surface,
                ),
                const SizedBox(height: 16),
                Text(
                  c.category.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  c.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                StatusBadge(
                  status.label,
                  color: status == CompetitionStatus.active
                      ? AppColors.successInk
                      : AppColors.primaryStrong,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: '${works.length}',
                  label: 'Жіберілген жұмыс',
                  icon: Icons.description_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  value: '$rated',
                  label: 'Бағаланған жұмыс',
                  icon: Icons.task_alt_rounded,
                  color: AppColors.science,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Қабылдау: ${longDate(c.deadline)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          p.user(c.organizerId).name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('Байқау жайлы'),
          Text(c.description, style: Theme.of(context).textTheme.bodyLarge),
          const SectionTitle('Қатысу ережелері'),
          Text(c.rules, style: Theme.of(context).textTheme.bodyLarge),
          const SectionTitle('Бағалау критерийлері'),
          ...EvaluationCriteria.values.map(
            (criterion) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(criterion.name)),
                      Text(
                        '${(criterion.weight * 100).round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryStrong,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: criterion.weight,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(5),
                    backgroundColor: AppColors.border,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (user.role == UserRole.participant &&
              mine == null &&
              status == CompetitionStatus.active)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('submit-work'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubmitWorkScreen(competitionId: c.id),
                  ),
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Қатысу және жұмыс жіберу'),
              ),
            ),
          if (mine != null)
            const InfoBanner(
              'Сіз байқауға тіркелдіңіз. Жұмысыңыз төменде және «Жұмыстарым» бөлімінде көрсетіледі.',
            ),
          if (user.role == UserRole.participant &&
              mine == null &&
              status != CompetitionStatus.active)
            const InfoBanner('Бұл байқауға жұмыс қабылдау аяқталды.'),
          if (p.canSeeResults(c))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultsScreen(competitionId: c.id),
                    ),
                  ),
                  icon: const Icon(Icons.leaderboard_outlined),
                  label: Text(
                    status == CompetitionStatus.published
                        ? 'Қорытынды рейтинг'
                        : 'Алдын ала рейтинг',
                  ),
                ),
              ),
            ),
          if (organizer && status != CompetitionStatus.published) ...[
            const SectionTitle('Ұйымдастырушы панелі'),
            InfoBanner(
              works.isEmpty
                  ? 'Алдымен қатысушылардың жұмыстарын күтіңіз.'
                  : 'Бағалау барысы: $rated / ${works.length}. Нәтижені жариялау үшін әр жұмысқа кемінде бір баға қажет.',
            ),
            if (status == CompetitionStatus.active)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: p.saving
                      ? null
                      : () async {
                          if (!await confirmAction(
                            context,
                            title: 'Қабылдауды аяқтау',
                            message:
                                'Жаңа жұмыстар қабылданбайды. Қазылар бағалауды жалғастыра алады.',
                            action: 'Аяқтау',
                          )) {
                            return;
                          }
                          try {
                            await p.closeSubmissions(c.id);
                            if (context.mounted) {
                              showMessage(context, 'Бағалау кезеңі басталды.');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showMessage(context, friendlyError(e));
                            }
                          }
                        },
                  icon: const Icon(Icons.lock_clock_outlined),
                  label: const Text('Жұмыс қабылдауды аяқтау'),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('publish-results'),
                onPressed: p.saving || works.isEmpty || rated != works.length
                    ? null
                    : () async {
                        if (!await confirmAction(
                          context,
                          title: 'Нәтижені жариялау',
                          message:
                              'Рейтинг барлық қатысушыға ашылады. Жұмыс қабылдау аяқталып, бағалар бекітіледі.',
                          action: 'Жариялау',
                        )) {
                          return;
                        }
                        try {
                          await p.publishResults(c.id);
                          if (context.mounted) {
                            showMessage(context, 'Нәтижелер жарияланды!');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showMessage(context, friendlyError(e));
                          }
                        }
                      },
                icon: const Icon(Icons.celebration_rounded),
                label: Text(p.saving ? 'Сақталуда…' : 'Нәтижелерді жариялау'),
              ),
            ),
          ],
          SectionTitle(
            user.role == UserRole.participant &&
                    status != CompetitionStatus.published
                ? 'Менің жұмысым'
                : 'Қатысушылар жұмыстары',
          ),
          if (visibleWorks.isEmpty)
            StateMessage(
              title: user.role == UserRole.participant
                  ? 'Сіздің жұмысыңыз әлі жоқ'
                  : 'Алғашқы жұмысты күтеміз',
              message: user.role == UserRole.participant
                  ? 'Қабылдау ашық кезде жұмысыңызды жібере аласыз.'
                  : 'Жіберілген жұмыстар осы жерде көрінеді.',
            ),
          ...visibleWorks.map(
            (s) => SubmissionCard(
              submission: s,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EvaluationScreen(submissionId: s.id),
                ),
              ),
              action:
                  user.role == UserRole.jury &&
                      status != CompetitionStatus.published
                  ? (p.myGrade(s.id) == null ? 'Бағалау' : 'Бағаны түзету')
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
