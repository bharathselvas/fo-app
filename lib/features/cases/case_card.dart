import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/land_case.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import 'case_detail_screen.dart';

/// One row of the case list: everything the officer needs at a glance.
class CaseCard extends StatelessWidget {
  const CaseCard({super.key, required this.caseData});

  final LandCase caseData;

  static final _dueFmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overdue = caseData.isOverdue;

    return TappableCard(
      onTap: () => CaseDetailScreen.open(context, caseNo: caseData.caseNo),
      padding: const EdgeInsets.all(Insets.md + 2),
      borderColor: overdue ? AppColors.danger.withValues(alpha: 0.28) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  caseData.caseNo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium!.copyWith(letterSpacing: 0.2),
                ),
              ),
              const Gap(Insets.sm, horizontal: true),
              PriorityChip(priority: caseData.priority, dense: true),
            ],
          ),
          const Gap(Insets.xs),
          Text(
            caseData.projectName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(2),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 13, color: AppColors.textTertiary),
              const Gap(3, horizontal: true),
              Expanded(
                child: Text(
                  '${caseData.village} · ${caseData.taluk}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const Gap(Insets.md),
          Wrap(
            spacing: Insets.sm,
            runSpacing: Insets.xs,
            children: [
              CaseStatusChip(status: caseData.status, dense: true),
              AppChip(
                label: caseData.stage,
                color: AppColors.info,
                icon: Icons.flag_outlined,
                dense: true,
              ),
            ],
          ),
          const Gap(Insets.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.sm),
            decoration: BoxDecoration(
              color: overdue ? AppColors.dangerSoft : AppColors.surfaceSunken,
              borderRadius: Radii.smAll,
            ),
            child: Row(
              children: [
                Icon(
                  overdue ? Icons.warning_amber_rounded : Icons.event_outlined,
                  size: 14,
                  color: overdue ? AppColors.danger : AppColors.textTertiary,
                ),
                const Gap(Insets.sm, horizontal: true),
                Expanded(
                  child: Text(
                    'Due ${_dueFmt.format(caseData.dueDate)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: overdue ? AppColors.danger : AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  caseData.dueLabel,
                  style: theme.textTheme.labelSmall!.copyWith(
                    fontSize: 11,
                    color: overdue ? AppColors.danger : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
