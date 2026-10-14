import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/competition.dart';
import '../providers/platform_provider.dart';
import '../services/scoring_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'evaluation_screen.dart';

Color medalColor(int rank) => switch (rank) {
  1 => AppColors.warningInk,
  2 => AppColors.silverInk,
  3 => AppColors.bronzeInk,
  _ => AppColors.primaryStrong,
};

Color medalSurface(int rank) => switch (rank) {
  1 => AppColors.warningSurface,
  2 => AppColors.silverSurface,
  3 => AppColors.bronzeSurface,
  _ => AppColors.softPurple,
};

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, this.competitionId, this.embedded = false});
  final String? competitionId;
  final bool embedded;
  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String? _selected;
  @override
  void initState() {
    super.initState();
    _selected = widget.competitionId;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final contests = p.competitions.where(p.canSeeResults).toList();
    final selectedId = contests.any((c) => c.id == _selected)
        ? _selected
        : contests.firstOrNull?.id;
    final c = selectedId == null ? null : p.competition(selectedId);
    final rows = c == null ? <RankedSubmission>[] : p.ranking(c.id);
    final body = PageBody(
      children: [
        Text('Жеңіс тұғыры', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        const Text(
          'Үздік идеялар. Лайықты жеңімпаздар.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        if (contests.isEmpty)
          const StateMessage(
            title: 'Нәтижелер әлі жарияланбады',
            message:
                'Ұйымдастырушы нәтижені жариялағаннан кейін рейтинг ашылады.',
            icon: Icons.emoji_events_outlined,
          ),
        if (c != null) ...[
          DropdownButtonFormField<String>(
            key: ValueKey(selectedId),
            initialValue: selectedId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Байқауды таңдаңыз'),
            items: contests
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.title, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (id) => setState(() => _selected = id),
          ),
          const SizedBox(height: 18),
          InfoBanner(
            p.status(c) == CompetitionStatus.published
                ? 'Қорытынды нәтижелер жарияланды. ${rows.length} жұмыс бағаланды.'
                : 'Алдын ала рейтинг. Жаңа бағалар қосылғанда орындар өзгереді. Қатысушыларға жарияланбаған.',
          ),
          if (rows.isEmpty)
            const StateMessage(
              title: 'Рейтингті бағалар ашады',
              message:
                  'Алғашқы баға сақталғаннан кейін рейтинг автоматты қалыптасады.',
              icon: Icons.leaderboard_outlined,
            ),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Podium(rows: rows.take(3).toList()),
            const SectionTitle('Қорытынды рейтинг'),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  color: row.submission.participantId == p.currentUser?.id
                      ? AppColors.softPurple
                      : AppColors.surface,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EvaluationScreen(submissionId: row.submission.id),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: medalSurface(row.rank),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${row.rank}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: medalColor(row.rank),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.user(row.submission.participantId).name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  row.submission.title,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${row.rank}-орын • ${row.juryCount} қазы',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                row.score.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryStrong,
                                ),
                              ),
                              Text(
                                'ұпай',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ұпай: 0–100. Бірнеше қазының бағасы орташа мәнмен есептеледі. Тең ұпайға тең орын беріледі.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ],
        ],
        const SizedBox(height: 24),
      ],
    );
    return widget.embedded
        ? body
        : Scaffold(
            appBar: AppBar(title: const Text('Нәтижелер мен рейтинг')),
            body: body,
          );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.rows});
  final List<RankedSubmission> rows;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final order = rows.length >= 2
        ? [rows[1], rows[0], if (rows.length >= 3) rows[2]]
        : rows;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: order.map((row) {
            final color = medalColor(row.rank);
            final winner = identical(row, rows.first);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (winner)
                      Icon(Icons.emoji_events_outlined, color: color, size: 30),
                    const SizedBox(height: 8),
                    CircleAvatar(
                      radius: winner ? 30 : 24,
                      backgroundColor: medalSurface(row.rank),
                      child: Text(
                        p.user(row.submission.participantId).initials,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p.user(row.submission.participantId).name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${row.score.toStringAsFixed(1)} ұпай',
                      style: TextStyle(
                        color: AppColors.primaryStrong,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      height: winner
                          ? 102
                          : row.rank == 2
                          ? 74
                          : 56,
                      decoration: BoxDecoration(
                        color: medalSurface(row.rank),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${row.rank}',
                        style: TextStyle(
                          color: color,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
