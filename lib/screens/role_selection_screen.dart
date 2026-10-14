import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/platform_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key, this.switching = false});
  final bool switching;
  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _role = UserRole.participant;
  String? _userId;
  String? _error;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final users = p.users.where((u) => u.role == _role).toList();
    final selectedId = _userId ?? users.first.id;
    return Scaffold(
      appBar: widget.switching
          ? AppBar(title: const Text('Demo рөлін ауыстыру'))
          : null,
      body: SafeArea(
        child: PageBody(
          children: [
            const SizedBox(height: 24),
            const Row(
              children: [
                BrandLogo(),
                SizedBox(width: 14),
                Text(
                  'baiqau',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            const StatusBadge(
              'ИДЕЯДАН ЖЕҢІСКЕ',
              color: AppColors.primaryStrong,
            ),
            const SizedBox(height: 16),
            Text(
              'Талантыңа\nжол аш.',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontSize: 38, height: 1.2),
            ),
            const SizedBox(height: 14),
            const Text(
              'Байқаулар, жаңа мүмкіндіктер және әділ бағалау — бір платформада.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SectionTitle('Қай рөлмен кіресіз?'),
            ...UserRole.values.map(
              (role) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _role == role
                        ? AppColors.softPurple
                        : AppColors.surface,
                    border: Border.all(
                      color: _role == role
                          ? AppColors.accent
                          : AppColors.border,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AppStyles.cardRadius),
                    boxShadow: AppStyles.softShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppStyles.cardRadius),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      leading: SoftIcon(
                        roleIcon(role),
                        background: _role == role
                            ? AppColors.surface
                            : AppColors.softPurple,
                      ),
                      title: Text(
                        role.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          role.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        _role == role
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: _role == role
                            ? AppColors.primaryStrong
                            : AppColors.accent,
                      ),
                      onTap: p.saving
                          ? null
                          : () => setState(() {
                              _role = role;
                              _userId = null;
                              _error = null;
                            }),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(_role),
              initialValue: selectedId,
              decoration: const InputDecoration(
                labelText: 'Demo қолданушысы',
                prefixIcon: Icon(Icons.person_outline),
              ),
              isExpanded: true,
              items: users
                  .map(
                    (u) => DropdownMenuItem(value: u.id, child: Text(u.name)),
                  )
                  .toList(),
              onChanged: p.saving ? null : (id) => setState(() => _userId = id),
            ),
            const SizedBox(height: 18),
            if (_error != null) InfoBanner(_error!, error: true),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('enter-role'),
                onPressed: p.saving
                    ? null
                    : () async {
                        try {
                          await p.selectUser(selectedId);
                          if (context.mounted && widget.switching) {
                            Navigator.pop(context);
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
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(p.saving ? 'Сақталуда…' : 'Осы рөлмен кіру'),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'DEMO MODE  •  Интернетсіз жұмыс істейді',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  letterSpacing: .4,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
