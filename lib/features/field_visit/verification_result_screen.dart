import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../widgets/common.dart';
import '../cases/case_detail_screen.dart';

/// Confirmation after the officer submits a field verification: what was
/// captured, where it went (local queue) and what happens next.
class VerificationResultScreen extends StatelessWidget {
  const VerificationResultScreen({
    super.key,
    required this.caseNo,
    required this.evidenceCount,
    required this.gpsCaptured,
    required this.gpsIsMock,
    required this.queuedOffline,
    required this.visitId,
  });

  final String caseNo;
  final int evidenceCount;
  final bool gpsCaptured;
  final bool gpsIsMock;
  final bool queuedOffline;
  final String visitId;

  void _openCase(BuildContext context) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    CaseDetailScreen.open(context, caseNo: caseNo);
  }

  void _toDashboard(BuildContext context) {
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verification Submitted')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.xl, Insets.lg, Insets.xxl),
        children: [
          Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.successSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 52,
                ),
              ),
              const Gap(Insets.lg),
              Text(
                'FIELD VERIFICATION SUBMITTED',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge!.copyWith(letterSpacing: 0.4),
              ),
              const Gap(Insets.xs),
              Text(
                caseNo,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
          const Gap(Insets.xxl),
          SectionCard(
            title: 'Submission summary',
            icon: Icons.summarize_outlined,
            children: [
              InfoRow(label: 'Case', value: caseNo, highlight: true),
              InfoRow(label: 'Visit ID', value: visitId),
              InfoRow(label: 'Evidence files', value: '$evidenceCount'),
              InfoRow(
                label: 'GPS',
                value: gpsCaptured ? (gpsIsMock ? 'Tagged (demo fix)' : 'Locked') : 'Unavailable',
              ),
              InfoRow(
                label: 'Storage',
                value: queuedOffline ? 'On device (offline)' : 'Queued for sync',
              ),
              InfoRow(label: 'Status', value: 'Awaiting Officer Review', highlight: true),
            ],
          ),
          const Gap(Insets.lg),
          SectionCard(
            title: 'What happens next',
            icon: Icons.route_outlined,
            children: [
              _step(context, '1', 'Your record is saved on this device — no internet was required.'),
              _step(
                context,
                '2',
                queuedOffline
                    ? 'It uploads automatically as soon as connectivity returns.'
                    : 'It syncs with the district server on the next queue run.',
              ),
              _step(
                context,
                '3',
                'The District Authority reviews the verification and updates the case status.',
              ),
              _step(context, '4', 'Track progress from the case dossier timeline.'),
            ],
          ),
          const Gap(Insets.xxl),
          FilledButton.icon(
            onPressed: () => _openCase(context),
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('VIEW CASE'),
          ),
          const Gap(Insets.sm),
          OutlinedButton.icon(
            onPressed: () => _toDashboard(context),
            icon: const Icon(Icons.home_outlined, size: 18),
            label: const Text('BACK TO DASHBOARD'),
          ),
        ],
      ),
    );
  }

  Widget _step(BuildContext context, String n, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              n,
              style: theme.textTheme.labelMedium!.copyWith(color: AppColors.success),
            ),
          ),
          const Gap(Insets.md, horizontal: true),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
