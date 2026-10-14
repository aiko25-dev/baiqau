import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/formatters.dart';
import '../providers/platform_provider.dart';
import '../widgets/common.dart';
import 'competition_details_screen.dart';

class CreateCompetitionScreen extends StatefulWidget {
  const CreateCompetitionScreen({super.key});
  @override
  State<CreateCompetitionScreen> createState() =>
      _CreateCompetitionScreenState();
}

class _CreateCompetitionScreenState extends State<CreateCompetitionScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _rules = TextEditingController(
    text:
        'Жұмыс авторлық болуы тиіс. Жоба сипаттамасы мен қолжетімді сілтемесін жіберіңіз. Бір қатысушы бір жұмыс ұсынады.',
  );
  String _category = categories.first;
  DateTime? _deadline;
  String? _error;
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _rules.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    _deadline ??= DateTime(p.now.year, p.now.month, p.now.day + 14, 23, 59, 59);
    return Scaffold(
      appBar: AppBar(title: const Text('Жаңа байқау')),
      body: Form(
        key: _form,
        child: PageBody(
          children: [
            const InfoBanner(
              'Жаңа байқау бірден қатысушыларға қолжетімді болады. Барлық дерек құрылғыда сақталады.',
            ),
            TextFormField(
              key: const Key('contest-title'),
              controller: _title,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Байқау атауы',
                hintText: 'Мысалы: Жас инноватор',
              ),
              validator: requiredText,
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('contest-description'),
              controller: _description,
              maxLines: 4,
              maxLength: 2000,
              decoration: const InputDecoration(
                labelText: 'Сипаттама',
                hintText: 'Байқаудың мақсаты мен тақырыбы',
              ),
              validator: (v) => requiredText(v, min: 10),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Санат'),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: p.saving
                  ? null
                  : (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: p.saving
                  ? null
                  : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _deadline,
                        firstDate: DateTime(p.now.year, p.now.month, p.now.day),
                        lastDate: DateTime(p.now.year + 3),
                        helpText: 'Қабылдаудың соңғы күні',
                        cancelText: 'Бас тарту',
                        confirmText: 'Таңдау',
                      );
                      if (date != null && mounted) {
                        setState(
                          () => _deadline = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            23,
                            59,
                            59,
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text('Мерзім: ${shortDate(_deadline!)} • 23:59'),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _rules,
              maxLines: 4,
              maxLength: 2000,
              decoration: const InputDecoration(labelText: 'Қатысу ережелері'),
              validator: (v) => requiredText(v, min: 10),
            ),
            const SizedBox(height: 20),
            if (_error != null) InfoBanner(_error!, error: true),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('save-contest'),
                onPressed: p.saving
                    ? null
                    : () async {
                        if (!_form.currentState!.validate()) {
                          return;
                        }
                        setState(() => _error = null);
                        try {
                          final id = await p.createCompetition(
                            title: _title.text,
                            description: _description.text,
                            category: _category,
                            deadline: _deadline!,
                            rules: _rules.text,
                          );
                          if (context.mounted) {
                            showMessage(context, 'Байқау құрылды!');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CompetitionDetailsScreen(competitionId: id),
                              ),
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
                    : const Icon(Icons.add_rounded),
                label: Text(p.saving ? 'Сақталуда…' : 'Байқауды жариялау'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
