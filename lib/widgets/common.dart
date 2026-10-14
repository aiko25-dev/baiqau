import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';

IconData roleIcon(UserRole role) => switch (role) {
  UserRole.organizer => Icons.dashboard_customize_outlined,
  UserRole.participant => Icons.rocket_launch_outlined,
  UserRole.jury => Icons.fact_check_outlined,
};
IconData categoryIcon(String category) => switch (category) {
  'Дизайн' => Icons.palette_outlined,
  'Өнер' => Icons.auto_awesome_outlined,
  'Ғылым' => Icons.science_outlined,
  'Әдебиет' => Icons.menu_book_outlined,
  _ => Icons.code_rounded,
};
Color categoryColor(String category) => switch (category) {
  'Дизайн' => AppColors.design,
  'Өнер' => AppColors.art,
  'Ғылым' => AppColors.science,
  'Әдебиет' => AppColors.literature,
  _ => AppColors.primaryStrong,
};

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 48, this.white = false});
  final double size;
  final bool white;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: white ? Colors.white.withValues(alpha: .20) : AppColors.softPurple,
      borderRadius: BorderRadius.circular(size * .30),
    ),
    child: Icon(
      Icons.emoji_events_outlined,
      color: white ? AppColors.surface : AppColors.primary,
      size: size * .56,
    ),
  );
}

class SoftIcon extends StatelessWidget {
  const SoftIcon(
    this.icon, {
    super.key,
    this.color = AppColors.primaryStrong,
    this.size = 46,
    this.background,
  });
  final IconData icon;
  final Color color;
  final double size;
  final Color? background;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: background ?? AppColors.pastelFor(color),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Icon(icon, size: size * .48, color: color),
  );
}

class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.children,
    this.padding = AppStyles.pagePadding,
  });
  final List<Widget> children;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    bottom: false,
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding:
                  constraints.maxWidth < 360 && padding == AppStyles.pagePadding
                  ? padding.copyWith(left: 20, right: 20)
                  : padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 32, bottom: 18),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    ),
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.color = AppColors.successInk});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.pastelFor(color),
      borderRadius: BorderRadius.circular(40),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.onAction,
  });
  final String title;
  final String message;
  final IconData icon;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: AppColors.softPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.primaryStrong),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.6),
          ),
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: FilledButton(onPressed: onAction, child: Text(action!)),
            ),
        ],
      ),
    ),
  );
}

class InfoBanner extends StatelessWidget {
  const InfoBanner(this.text, {super.key, this.error = false});
  final String text;
  final bool error;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: error ? AppColors.errorSurface : AppColors.softPurple,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          error ? Icons.error_outline_rounded : Icons.lightbulb_outline_rounded,
          size: 20,
          color: error ? AppColors.error : AppColors.primaryStrong,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: error ? AppColors.error : AppColors.primaryStrong,
            ),
          ),
        ),
      ],
    ),
  );
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = AppColors.primaryStrong,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftIcon(icon, color: color, size: 40),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 28,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

void showMessage(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
String friendlyError(Object error) => error.toString().replaceFirst(
  RegExp(r'^(Bad state: |Invalid argument\(s\): )'),
  '',
);
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Бас тарту'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;
