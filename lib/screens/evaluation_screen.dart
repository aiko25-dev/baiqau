import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/formatters.dart';
import '../models/competition.dart';
import '../models/evaluation.dart';
import '../models/user.dart';
import '../providers/platform_provider.dart';
import '../services/scoring_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key, required this.submissionId});
  final String submissionId;
  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  final _form = GlobalKey<FormState>();
  final _comment = TextEditingController();
  List<double> _values = [7, 7, 7];
  bool _initialized = false;
  String? _error;
  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final s = p.submission(widget.submissionId);
    final c = p.competition(s.competitionId);
    final user = p.currentUser!;
    final published = p.status(c) == CompetitionStatus.published;
    final canView =
        published ||
        user.role == UserRole.jury ||
        user.id == s.participantId ||
        user.id == c.organizerId;
    if (!canView) {
      return Scaffold(
        appBar: AppBar(title: const Text('Жұмыс')),
        body: const StateMessage(
          title: 'Жұмыс қолжетімсіз',
          message: 'Нәтиже жарияланғаннан кейін көре аласыз.',
        ),
      );
    }
    final canEvaluate = user.role == UserRole.jury && !published;
    final myGrade = p.myGrade(s.id);
    if (!_initialized) {
      if (myGrade != null) {
        _values = [myGrade.creativity, myGrade.quality, myGrade.presentation];
        _comment.text = myGrade.comment;
      }
      _initialized = true;
    }
    final score = ScoringService.score(_values[0], _values[1], _values[2]);
    final grades = p.gradesFor(s.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(canEvaluate ? 'Жұмысты бағалау' : 'Жұмыс туралы'),
      ),
      body: Form(
        key: _form,
        child: PageBody(
          children: [
            StatusBadge(p.workStatus(s).label, color: AppColors.primaryStrong),
            const SizedBox(height: 18),
            Text(s.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(
              '${p.user(s.participantId).name} • ${shortDate(s.createdAt)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              c.title,
              style: const TextStyle(
                color: AppColors.primaryStrong,
                fontSize: 13,
              ),
            ),
            const SectionTitle('Идея мен шешім'),
            Text(s.description, style: Theme.of(context).textTheme.bodyLarge),
            const SectionTitle('Жұмыс сілтемесі'),
            SelectableText(
              s.link,
              style: const TextStyle(color: AppColors.primaryStrong),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: s.link));
                if (context.mounted) {
                  showMessage(context, 'Сілтеме көшірілді.');
                }
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Сілтемені көшіру'),
            ),
            if (canEvaluate) ...[
              SectionTitle(
                myGrade == null ? 'Сіздің бағаңыз' : 'Бағаны түзету',
              ),
              InfoBanner(
                'Қазы: ${user.name}. Әр критерийді 0–10 аралығында бағалаңыз. Бағаны кейін өзгерте аласыз.',
              ),
              ...List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  EvaluationCriteria.values[i].name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${(EvaluationCriteria.values[i].weight * 100).round()}%',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _values[i].toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColors.primaryStrong,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            key: Key('criterion-$i'),
                            value: _values[i],
                            min: 0,
                            max: 10,
                            divisions: 20,
                            label: _values[i].toStringAsFixed(1),
                            onChanged: p.saving
                                ? null
                                : (value) => setState(() => _values[i] = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppStyles.lavenderGradient,
                  borderRadius: BorderRadius.circular(AppStyles.cardRadius),
                  boxShadow: AppStyles.softShadow,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Сіздің қорытынды\nұпайыңыз',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Text(
                      score.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.primaryStrong,
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      ' / 100',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const Key('jury-comment'),
                controller: _comment,
                maxLines: 4,
                maxLength: 1500,
                decoration: const InputDecoration(
                  labelText: 'Қазы пікірі',
                  hintText: 'Жұмыстың күшті тұстары мен ұсыныстарыңыз',
                ),
                validator: (v) => requiredText(v, min: 5),
              ),
              const SizedBox(height: 16),
              if (_error != null) InfoBanner(_error!, error: true),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('save-evaluation'),
                  onPressed: p.saving
                      ? null
                      : () async {
                          if (!_form.currentState!.validate()) {
                            return;
                          }
                          try {
                            await p.evaluate(
                              submissionId: s.id,
                              creativity: _values[0],
                              quality: _values[1],
                              presentation: _values[2],
                              comment: _comment.text,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              showMessage(
                                context,
                                'Баға сақталды. Рейтинг жаңартылды.',
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => _error = friendlyError(e));
                            }
                          }
                        },
                  icon: p.saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    p.saving
                        ? 'Сақталуда…'
                        : myGrade == null
                        ? 'Бағаны сақтау'
                        : 'Өзгерісті сақтау',
                  ),
                ),
              ),
            ],
            const SectionTitle('Қазылар бағалары'),
            if (grades.isEmpty)
              const StateMessage(
                title: 'Бағалауды күтуде',
                message:
                    'Қазылар бағалағаннан кейін ұпай мен пікір осы жерде көрінеді.',
              ),
            if (grades.isNotEmpty)
              InfoBanner(
                'Орташа ұпай: ${p.scoreFor(s.id)!.toStringAsFixed(1)} / 100 • ${grades.length} қазы',
              ),
            ...grades.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.user(e.juryId).name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              ScoringService.score(
                                e.creativity,
                                e.quality,
                                e.presentation,
                              ).toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryStrong,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Шығармашылық: ${e.creativity} • Сапа: ${e.quality} • Ұсыну: ${e.presentation}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 10),
                        Text(e.comment),
                        const SizedBox(height: 8),
                        Text(
                          'Жаңартылды: ${shortDate(e.updatedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (published)
              const InfoBanner(
                'Нәтижелер жарияланған. Қорытынды бағалар бекітілді.',
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
