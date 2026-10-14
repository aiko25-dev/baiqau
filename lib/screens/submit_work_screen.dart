import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/formatters.dart';
import '../providers/platform_provider.dart';
import '../widgets/common.dart';

class SubmitWorkScreen extends StatefulWidget {
  const SubmitWorkScreen({super.key, required this.competitionId});
  final String competitionId;
  @override
  State<SubmitWorkScreen> createState() => _SubmitWorkScreenState();
}

class _SubmitWorkScreenState extends State<SubmitWorkScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _link = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final c = p.competition(widget.competitionId);
    return Scaffold(
      appBar: AppBar(title: const Text('Жұмыс жіберу')),
      body: Form(
        key: _form,
        child: PageBody(
          children: [
            Text(c.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            const InfoBanner(
              'Жұмыс жібергенде байқауға автоматты тіркелесіз. Файлды Drive, GitHub немесе басқа сервиске орналастырып, сілтемесін қосыңыз.',
            ),
            TextFormField(
              key: const Key('work-title'),
              controller: _title,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Жұмыс атауы'),
              validator: requiredText,
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('work-description'),
              controller: _description,
              maxLength: 3000,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Жұмыс сипаттамасы',
                hintText: 'Идея, мақсат және негізгі нәтиже',
              ),
              validator: (v) => requiredText(v, min: 10),
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('work-link'),
              controller: _link,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Жұмыс сілтемесі',
                hintText: 'https://…',
                prefixIcon: Icon(Icons.link_rounded),
              ),
              validator: linkError,
            ),
            const SizedBox(height: 24),
            if (_error != null) InfoBanner(_error!, error: true),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('save-work'),
                onPressed: p.saving
                    ? null
                    : () async {
                        if (!_form.currentState!.validate()) {
                          return;
                        }
                        setState(() => _error = null);
                        try {
                          await p.submitWork(
                            competitionId: c.id,
                            title: _title.text,
                            description: _description.text,
                            link: _link.text,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            showMessage(context, 'Жұмыс жіберілді. Сәттілік!');
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
                    : const Icon(Icons.send_rounded),
                label: Text(p.saving ? 'Сақталуда…' : 'Жұмысты жіберу'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
