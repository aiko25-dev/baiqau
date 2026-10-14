import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/competition.dart';
import '../providers/platform_provider.dart';
import '../core/formatters.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class CompetitionCard extends StatelessWidget {
  const CompetitionCard({
    super.key,
    required this.competition,
    required this.onTap,
  });
  final Competition competition;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final store = context.watch<PlatformProvider>();
    final color = categoryColor(competition.category);
    final status = store.status(competition);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SoftIcon(
                      categoryIcon(competition.category),
                      color: color,
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        competition.category,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.primaryLight,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  competition.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  competition.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusBadge(
                      status.label,
                      color: status == CompetitionStatus.active
                          ? AppColors.successInk
                          : status == CompetitionStatus.published
                          ? AppColors.primaryStrong
                          : AppColors.warningInk,
                    ),
                    Text(
                      '${store.worksFor(competition.id).length} жұмыс',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          shortDate(competition.deadline),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
