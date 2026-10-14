import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/submission.dart';
import '../providers/platform_provider.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class SubmissionCard extends StatelessWidget {
  const SubmissionCard({
    super.key,
    required this.submission,
    required this.onTap,
    this.action,
  });
  final Submission submission;
  final VoidCallback onTap;
  final String? action;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    final status = p.workStatus(submission);
    final score = p.scoreFor(submission.id);
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
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: AppColors.softPurple,
                      child: Text(
                        p.user(submission.participantId).initials,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryStrong,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.user(submission.participantId).name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primaryLight,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  submission.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  p.competition(submission.competitionId).title,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusBadge(
                      status.label,
                      color: status == SubmissionStatus.submitted
                          ? AppColors.textSecondary
                          : AppColors.primaryStrong,
                    ),
                    if (score != null)
                      Text(
                        '${score.toStringAsFixed(1)} / 100',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryStrong,
                        ),
                      ),
                    if (action != null)
                      Text(
                        action!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryStrong,
                        ),
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
