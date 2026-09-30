import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_routes.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/enums.dart';
import '../../data/models/evidence_record.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/evidence_thumb.dart';

/// Full-screen viewer for one piece of captured field evidence.
class EvidenceViewerScreen extends ConsumerWidget {
  const EvidenceViewerScreen({super.key, required this.recordId});

  final String recordId;

  static void open(BuildContext context, {required EvidenceRecord record}) {
    Navigator.of(context).push(
      AppRoutes.zoom(EvidenceViewerScreen(recordId: record.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(foStateProvider).evidence.where((e) => e.id == recordId);
    final record = matches.isEmpty ? null : matches.first;

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Evidence')),
        body: const EmptyState(
          icon: Icons.photo_outlined,
          title: 'Evidence not found',
          message: 'This record is no longer attached to a case.',
        ),
      );
    }

    final captured = DateFormat('d MMM yyyy, h:mm a').format(record.capturedAt);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.viewerBackground,
      appBar: AppBar(
        backgroundColor: AppColors.viewerBackground,
        foregroundColor: Colors.white,
        systemOverlayStyle: null,
        title: Text('Evidence ${record.number}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Insets.lg),
            child: Center(
              child: AppChip(
                label: record.uploadStatus.label,
                color: record.uploadStatus.color,
                filled: true,
                icon: record.uploadStatus == UploadStatus.synced
                    ? Icons.cloud_done
                    : Icons.cloud_upload,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: record.hasPhoto
                  ? Image.file(
                      File(record.filePath!),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      // Decoding a full-resolution capture for a viewer that
                      // is screen-sized was wasting memory on every open.
                      cacheWidth: MediaQuery.sizeOf(context).width.round() * 2,
                      gaplessPlayback: true,
                      errorBuilder: (_, _, _) => EvidenceThumb(record: record),
                    )
                  : EvidenceThumb(record: record, fit: BoxFit.contain),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.viewerFooter,
              border: Border(top: BorderSide(color: AppColors.viewerDivider)),
            ),
            padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, Insets.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.type.toUpperCase(),
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: AppColors.viewerPositive,
                    letterSpacing: 1.1,
                  ),
                ),
                const Gap(Insets.sm),
                Text(
                  record.caption,
                  style: theme.textTheme.bodyLarge!.copyWith(color: Colors.white),
                ),
                const Gap(Insets.md),
                _meta(context, Icons.schedule_outlined, captured),
                if (record.latitude != null && record.longitude != null)
                  _meta(
                    context,
                    Icons.location_on_outlined,
                    '${record.latitude!.toStringAsFixed(5)}, '
                    '${record.longitude!.toStringAsFixed(5)}'
                    '${record.accuracyMetres != null ? ' (±${record.accuracyMetres!.toStringAsFixed(0)} m)' : ''}',
                    highlight: record.gpsTagged,
                  ),
                _meta(context, Icons.folder_outlined, 'Case ${record.caseNo}'),
                if (record.officerId != null)
                  _meta(context, Icons.badge_outlined, 'Officer ${record.officerId}'),
              ],
            ),
          ),
          const SizedBox(height: Insets.sm),
        ],
      ),
    );
  }

  Widget _meta(BuildContext context, IconData icon, String text, {bool highlight = false}) {
    final theme = Theme.of(context);
    final color = highlight ? AppColors.viewerPositive : Colors.white70;

    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.sm),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const Gap(Insets.sm, horizontal: true),
          Expanded(
            child: Text(text, style: theme.textTheme.bodySmall!.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
