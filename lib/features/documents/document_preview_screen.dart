import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/case_document.dart';
import '../../data/models/enums.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/screen_header.dart';
import '../cases/case_detail_screen.dart';
import '../../core/theme/app_routes.dart';

/// Document record sheet + review action.
///
/// The prototype has no binary document store, so instead of a dead PDF icon
/// this renders the official record the document represents, filled from the
/// same case data the rest of the app uses.
class DocumentPreviewScreen extends ConsumerWidget {
  const DocumentPreviewScreen({super.key, required this.documentId});

  final String documentId;

  static void open(BuildContext context, {required CaseDocument document}) {
    Navigator.of(context).push(
      AppRoutes.fadeUp(DocumentPreviewScreen(documentId: document.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foStateProvider);
    final matches = state.documents.where((d) => d.id == documentId);
    final doc = matches.isEmpty ? null : matches.first;

    if (doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Document')),
        body: const EmptyState(
          icon: Icons.description_outlined,
          title: 'Document not found',
          message: 'This document is no longer part of the case file.',
        ),
      );
    }

    final caseData = state.caseByNo(doc.caseNo);
    final dateFmt = DateFormat('d MMM yyyy');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 34),
        child: ScreenHeader(
          title: 'Document',
          subtitle: doc.caseNo,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, Insets.xxl),
        children: [
          SectionCard(
            title: 'Record',
            icon: Icons.description_outlined,
            children: [
              Text(doc.name, style: Theme.of(context).textTheme.titleMedium),
              const Gap(Insets.md),
              Wrap(
                spacing: Insets.sm,
                runSpacing: Insets.xs,
                children: [
                  AppChip(
                    label: doc.status.label,
                    color: doc.status.color,
                    uppercase: false,
                  ),
                  AppChip(label: doc.type, color: AppColors.info),
                ],
              ),
              const Gap(Insets.md),
              const Divider(height: 1),
              const Gap(Insets.sm),
              InfoRow(label: 'Case', value: doc.caseNo),
              InfoRow(label: 'Document type', value: doc.type),
              InfoRow(
                label: 'Received on',
                value: doc.receivedOn == null ? 'Not received' : dateFmt.format(doc.receivedOn!),
              ),
              InfoRow(label: 'Size', value: doc.sizeLabel),
              if (doc.pages != null) InfoRow(label: 'Pages', value: '${doc.pages}'),
            ],
          ),
          const Gap(Insets.lg),
          if (doc.status == DocumentStatus.notAvailable)
            EmptyState(
              icon: Icons.hourglass_empty,
              title: 'Not Yet Received',
              message: 'The issuing office has not uploaded this document. '
                  'Verification for this case stays blocked until it arrives.',
              action: FilledButton.icon(
                onPressed: () {
                  ref.read(foStateProvider.notifier).setDocumentStatus(
                        doc.id,
                        DocumentStatus.pending,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${doc.name} flagged as awaiting issue from the office')),
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: const Text('FLAG FOR FOLLOW-UP'),
              ),
            )
          else
            SectionCard(
              title: 'Document record',
              icon: Icons.folder_open,
              children: [
                const AppBanner(
                  tone: AppBannerTone.neutral,
                  icon: Icons.info_outline,
                  message: 'The prototype holds no binary document store, so this '
                      'is the record sheet the document represents, drawn from the '
                      'same case data the rest of the app uses.',
                ),
                const Gap(Insets.lg),
                _sheet(
                  context: context,
                  reference: doc.id,
                  title: doc.name,
                  caseNo: doc.caseNo,
                  issuedBy: caseData?.projectAuthority ?? '—',
                  received: doc.receivedOn == null
                      ? 'Not recorded'
                      : dateFmt.format(doc.receivedOn!),
                  rows: [
                    ('Parcel ID', caseData?.parcelId ?? '—'),
                    ('Survey number', caseData?.surveyNo ?? '—'),
                    ('Village', caseData?.village ?? '—'),
                    ('Taluk / District',
                        caseData == null ? '—' : '${caseData.taluk}, ${caseData.district}'),
                    ('Extent', caseData?.extentLabel ?? '—'),
                    ('Land type', caseData?.landType ?? '—'),
                    ('Landowner', caseData?.landOwner.name ?? '—'),
                    ('Project', caseData?.projectName ?? '—'),
                  ],
                ),
              ],
            ),
          const Gap(Insets.lg),
          if (caseData != null) ...[
            OutlinedButton.icon(
              onPressed: () => CaseDetailScreen.open(context, caseNo: caseData.caseNo),
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('OPEN CASE FILE'),
            ),
            const Gap(Insets.md),
          ],
          if (doc.status != DocumentStatus.verified)
            FilledButton.icon(
              onPressed: () {
                ref.read(foStateProvider.notifier).setDocumentStatus(
                      doc.id,
                      DocumentStatus.verified,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${doc.name} marked as verified')),
                );
              },
              icon: const Icon(Icons.verified_outlined),
              label: const Text('MARK AS VERIFIED'),
            )
          else
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(foStateProvider.notifier)
                    .setDocumentStatus(doc.id, DocumentStatus.pendingReview);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${doc.name} moved back to review')),
                );
              },
              icon: const Icon(Icons.undo),
              label: const Text('MOVE BACK TO REVIEW'),
            ),
        ],
      ),
    );
  }

  /// Government-record layout: a bordered sheet with a heading block and a
  /// key/value grid, the way a Patta extract or an award notice reads.
  Widget _sheet({
    required BuildContext context,
    required String reference,
    required String title,
    required String caseNo,
    required String issuedBy,
    required String received,
    required List<(String, String)> rows,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: Radii.smAll,
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.brand,
            padding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TERRANEX · REVENUE & LAND ACQUISITION',
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const Gap(2),
                Text(
                  'Government of Tamil Nadu',
                  style: theme.textTheme.bodySmall!.copyWith(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Insets.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const Gap(Insets.sm),
                Text('Reference: $reference', style: theme.textTheme.bodySmall),
                Text('Case: $caseNo', style: theme.textTheme.bodySmall),
                Text('Issued by: $issuedBy', style: theme.textTheme.bodySmall),
                Text('Received: $received', style: theme.textTheme.bodySmall),
                const Gap(Insets.lg),
                const Divider(height: 1),
                const Gap(Insets.md),
                for (final (label, value) in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Insets.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 118,
                          child: Text(
                            label,
                            style: theme.textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            value,
                            style: theme.textTheme.bodyMedium!
                                .copyWith(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Gap(Insets.sm),
                const Divider(height: 1),
                const Gap(Insets.md),
                Text(
                  'This is a representation of the record, not the scanned file. '
                  'The prototype stores no document binaries.',
                  style: theme.textTheme.bodySmall!
                      .copyWith(fontSize: 11.5, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
