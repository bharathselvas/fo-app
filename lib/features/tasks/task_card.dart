import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/case_task.dart';
import '../../data/models/enums.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../cases/case_detail_screen.dart';

/// One actionable task card (dashboard + tasks screen).
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onOpenCase});

  final CaseTask task;
  final void Function(CaseTask task)? onOpenCase;

  static final _dateFmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = task.status == TaskStatus.completed;
    final overdue = !done && task.isOverdue;

    return TappableCard(
      onTap: () => _openCase(context),
      padding: const EdgeInsets.all(Insets.md + 2),
      borderColor: overdue ? AppColors.danger.withValues(alpha: 0.28) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall!.copyWith(letterSpacing: 0.6),
                ),
              ),
              const Gap(Insets.sm, horizontal: true),
              PriorityChip(priority: task.priority, dense: true),
            ],
          ),
          const Gap(Insets.sm),
          Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          const Gap(2),
          Text('Case ${task.caseNo}', maxLines: 1, overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall),
          const Gap(Insets.md),
          Wrap(
            spacing: Insets.sm,
            runSpacing: Insets.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppChip(
                label: task.status.label,
                color: task.status.color,
                uppercase: false,
                icon: done
                    ? Icons.check_circle
                    : task.status == TaskStatus.inProgress
                        ? Icons.play_circle
                        : Icons.schedule,
              ),
              AppChip(
                label: task.slaLabel,
                color: done
                    ? AppColors.success
                    : overdue
                        ? AppColors.danger
                        : AppColors.neutral,
                icon: done
                    ? Icons.verified
                    : overdue
                        ? Icons.warning_amber
                        : Icons.timer_outlined,
              ),
              if (task.pendingFiles > 0)
                AppChip(
                  label: '${task.pendingFiles} FILES PENDING',
                  color: AppColors.serverDown,
                  icon: Icons.attach_file,
                ),
            ],
          ),
          const Gap(Insets.md),
          Row(
            children: [
              const Icon(Icons.date_range_outlined, size: 13, color: AppColors.textTertiary),
              const Gap(Insets.sm, horizontal: true),
              Expanded(
                child: Text(
                  'Assigned ${_dateFmt.format(task.assignedDate)} · '
                  'Due ${_dateFmt.format(task.dueDate)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall!.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
          const Gap(Insets.md),
          // Buttons sit outside the card's own InkWell so tapping one does not
          // also fire the card's navigate action.
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openCase(context),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                  child: const Text('VIEW CASE'),
                ),
              ),
              const Gap(Insets.sm, horizontal: true),
              Expanded(
                child: done
                    ? FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          backgroundColor: AppColors.success,
                        ),
                        onPressed: () => _openCase(context),
                        icon: const Icon(Icons.verified, size: 18),
                        label: const Text('SUBMITTED'),
                      )
                    : FilledButton.icon(
                        style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                        onPressed: () => _openCase(context, verify: true),
                        icon: Icon(
                          task.status == TaskStatus.inProgress
                              ? Icons.play_arrow
                              : Icons.play_circle_outline,
                          size: 18,
                        ),
                        label: Text(
                          task.status == TaskStatus.inProgress ? 'CONTINUE' : 'START',
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openCase(BuildContext context, {bool verify = false}) {
    if (onOpenCase != null) {
      onOpenCase!(task);
      return;
    }
    // Default: open the case detail (the verification entry point).
    CaseDetailScreen.open(context, caseNo: task.caseNo, startVerification: verify);
  }
}
