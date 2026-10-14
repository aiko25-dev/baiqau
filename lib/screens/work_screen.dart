import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/competition.dart';
import '../models/user.dart';
import '../providers/platform_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/submission_card.dart';
import 'evaluation_screen.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});
  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  bool _pendingOnly = false;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final user = p.currentUser!;
    final jury = user.role == UserRole.jury;
    final participant = user.role == UserRole.participant;
    final rows = p.submissions.where((s) {
      if (participant) {
        return s.participantId == user.id;
      }
      if (!jury) {
        return p.competition(s.competitionId).organizerId == user.id;
      }
      return !_pendingOnly ||
          (p.myGrade(s.id) == null &&
              p.status(p.competition(s.competitionId)) !=
                  CompetitionStatus.published);
    }).toList();
    return PageBody(
      children: [
        Text(
          jury
              ? 'Әр идеяға әділ баға.'
              : participant
              ? 'Менің жұмыстарым'
              : 'Қатысушылар жұмыстары',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          jury
              ? 'Үш критерий. Құнды пікір. Нақты нәтиже.'
              : 'Жұмыстың мәртебесі мен бағалау нәтижесін бақылаңыз.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        if (jury)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: FilterChip(
              label: const Text('Мен әлі бағаламаған'),
              selected: _pendingOnly,
              onSelected: (v) => setState(() => _pendingOnly = v),
            ),
          ),
        SectionTitle('${rows.length} жұмыс'),
        if (rows.isEmpty)
          StateMessage(
            title: _pendingOnly ? 'Барлығы бағаланды!' : 'Әзірге жұмыс жоқ',
            message: participant
                ? 'Байқау таңдап, алғашқы жұмысыңызды жіберіңіз.'
                : 'Жаңа жұмыстар осы жерде пайда болады.',
          ),
        ...rows.map(
          (s) => SubmissionCard(
            submission: s,
            action:
                jury &&
                    p.status(p.competition(s.competitionId)) !=
                        CompetitionStatus.published
                ? (p.myGrade(s.id) == null ? 'Бағалау' : 'Бағаны түзету')
                : null,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EvaluationScreen(submissionId: s.id),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
