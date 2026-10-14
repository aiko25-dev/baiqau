import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/formatters.dart';
import '../models/competition.dart';
import '../models/user.dart';
import '../providers/platform_provider.dart';
import '../widgets/common.dart';
import '../widgets/competition_card.dart';
import '../theme/app_theme.dart';
import 'competition_details_screen.dart';
import 'create_competition_screen.dart';

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});
  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  String _query = '';
  String? _category;
  CompetitionStatus? _status;
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final rows = p.competitions
        .where(
          (c) =>
              (_category == null || c.category == _category) &&
              (_status == null || p.status(c) == _status) &&
              '${c.title} ${c.description}'.toLowerCase().contains(
                _query.toLowerCase(),
              ),
        )
        .toList();
    return PageBody(
      children: [
        Text(
          'Өзіңді көрсет.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        const Text(
          'Саған лайық келесі мүмкіндікті тап.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _search,
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: 'Байқауды іздеу…',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [null, ...categories]
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category ?? 'Барлығы'),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _category == category
                            ? AppColors.primaryStrong
                            : AppColors.textSecondary,
                      ),
                      side: BorderSide(
                        color: _category == category
                            ? AppColors.accent
                            : AppColors.border,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<CompetitionStatus>(
          isExpanded: true,
          initialValue: _status,
          decoration: const InputDecoration(
            labelText: 'Байқау мәртебесі',
            prefixIcon: Icon(Icons.tune_rounded),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Барлық мәртебе')),
            ...CompetitionStatus.values.map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s.label, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _status = value),
        ),
        SectionTitle(
          '${rows.length} байқау',
          action: p.currentUser?.role == UserRole.organizer
              ? '+ Байқау құру'
              : null,
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCompetitionScreen()),
          ),
        ),
        if (rows.isEmpty)
          StateMessage(
            title: 'Байқау табылмады',
            message: 'Іздеу мәтінін немесе сүзгілерді өзгертіңіз.',
            action: 'Сүзгіні тазалау',
            onAction: () => setState(() {
              _search.clear();
              _query = '';
              _category = null;
              _status = null;
            }),
          ),
        ...rows.map(
          (c) => CompetitionCard(
            competition: c,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompetitionDetailsScreen(competitionId: c.id),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
