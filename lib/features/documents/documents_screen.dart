import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_routes.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/case_document.dart';
import '../../data/models/enums.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../../widgets/screen_header.dart';
import '../auth/auth_providers.dart';
import 'document_preview_screen.dart';

enum _DocFilter { all, verified, pending, notAvailable }

/// Documents belonging to one case (or to the officer's whole file).
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key, this.caseNo});

  final String? caseNo;

  static void open(BuildContext context, {String? caseNo}) {
    Navigator.of(context).push(
      AppRoutes.fadeUp(DocumentsScreen(caseNo: caseNo)),
    );
  }

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  _DocFilter _filter = _DocFilter.all;

  static const _filters = <_DocFilter, String>{
    _DocFilter.all: 'ALL',
    _DocFilter.verified: 'VERIFIED',
    _DocFilter.pending: 'PENDING',
    _DocFilter.notAvailable: 'MISSING',
  };

  List<CaseDocument> _apply(List<CaseDocument> docs) => switch (_filter) {
        _DocFilter.all => docs,
        _DocFilter.verified =>
          docs.where((d) => d.status == DocumentStatus.verified).toList(),
        _DocFilter.pending => docs
            .where((d) =>
                d.status == DocumentStatus.pending ||
                d.status == DocumentStatus.pendingReview)
            .toList(),
        _DocFilter.notAvailable =>
          docs.where((d) => d.status == DocumentStatus.notAvailable).toList(),
      };

  /// Documents the officer added from the field, projected onto the same
  /// shape as the office-issued records so both list in one place.
  List<CaseDocument> _fieldPicked(String caseNo) {
    final rows = ref.watch(visitDocumentsProvider(caseNo)).valueOrNull ?? const [];
    return [
      for (final d in rows)
        CaseDocument(
          id: d.id,
          caseNo: caseNo,
          name: d.localFilePath.split('/').last,
          type: d.type == 'land_record' ? 'Field upload' : d.type,
          status: d.syncStatus == 'SYNCED'
              ? DocumentStatus.verified
              : DocumentStatus.pendingReview,
          receivedOn: d.createdAt.toLocal(),
          sizeLabel: 'On device',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foStateProvider);
    final caseNo = widget.caseNo;
    final fieldPicked = caseNo == null ? const <CaseDocument>[] : _fieldPicked(caseNo);
    final all = [
      // Field-picked files belong to one case; the officer-wide list is the
      // office-issued dossier.
      if (caseNo == null) ...state.documents else ...[
        ...state.documentsFor(caseNo),
        ...fieldPicked,
      ],
    ];
    final docs = _apply(all);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 34),
        child: ScreenHeader(
          title: 'Documents',
          subtitle: caseNo ?? '${all.length} in your file',
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.sm),
              children: [
                for (final f in _DocFilter.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_filters[f]!),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: docs.isEmpty
                ? EmptyState(
                    icon: Icons.folder_open,
                    title: widget.caseNo == null
                        ? 'No Documents Available'
                        : 'No Documents for This Case',
                    message: switch (_filter) {
                      _DocFilter.verified => 'Nothing has been verified yet.',
                      _DocFilter.pending => 'No document is awaiting review.',
                      _DocFilter.notAvailable =>
                        'No missing document is flagged on this case.',
                      _DocFilter.all => widget.caseNo == null
                          ? 'No documents have been issued to you yet.'
                          : 'No documents available for this case.',
                    },
                  )
                : ListView.builder(
                    key: const PageStorageKey('documents-list'),
                    padding: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.xxl),
                    itemCount: docs.length,
                    itemBuilder: (_, i) => Padding(
                      key: ValueKey(docs[i].id),
                      padding: const EdgeInsets.only(bottom: Insets.sm),
                      child: _DocumentRow(
                        document: docs[i],
                        showCase: widget.caseNo == null,
                      ),
                    ),
                  ),
          ),
          Material(
            color: AppColors.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Insets.lg,
                  vertical: Insets.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SHOWING ${docs.length} OF ${all.length}', style: theme.textTheme.labelSmall),
                    Text(
                      _filters[_filter]!,
                      style: theme.textTheme.labelSmall!.copyWith(color: AppColors.brand),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.document, required this.showCase});

  final CaseDocument document;
  final bool showCase;

  static final _dateFmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TappableCard(
      onTap: () => DocumentPreviewScreen.open(context, document: document),
      padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: document.status.color.withValues(alpha: 0.10),
              borderRadius: Radii.smAll,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 20,
              color: document.status.color,
            ),
          ),
          const Gap(Insets.md, horizontal: true),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium!.copyWith(fontSize: 14),
                ),
                const Gap(2),
                Text(
                  '${document.type} · '
                  '${document.receivedOn == null ? 'Not received' : _dateFmt.format(document.receivedOn!)}'
                  '${showCase ? ' · ${document.caseNo}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall!.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const Gap(Insets.sm, horizontal: true),
          AppChip(
            label: document.status.label,
            color: document.status.color,
            dense: true,
            uppercase: false,
          ),
        ],
      ),
    );
  }
}
