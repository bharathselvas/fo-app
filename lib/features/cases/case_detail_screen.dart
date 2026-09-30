import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_routes.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/case_document.dart';
import '../../data/models/case_task.dart';
import '../../data/models/enums.dart';
import '../../data/models/evidence_record.dart';
import '../../data/models/land_case.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/evidence_thumb.dart';
import '../../widgets/motion.dart';
import '../../widgets/screen_header.dart';
import '../documents/document_preview_screen.dart';
import '../documents/documents_screen.dart';
import '../evidence/evidence_viewer_screen.dart';
import '../field_visit/wizard_screen.dart';
import '../map/parcel_map_screen.dart';
import '../tasks/tasks_screen.dart';

/// Case dossier: parcel, acquisition, landowner, assigned task, map, timeline,
/// documents and evidence — all read from the shared `foStateProvider`.
class CaseDetailScreen extends ConsumerStatefulWidget {
  const CaseDetailScreen({super.key, required this.caseNo, this.startVerification = false});

  final String caseNo;
  final bool startVerification;

  static void open(
    BuildContext context, {
    required String caseNo,
    bool startVerification = false,
  }) {
    Navigator.of(context).push(
      AppRoutes.fadeUp(
        CaseDetailScreen(caseNo: caseNo, startVerification: startVerification),
      ),
    );
  }

  @override
  ConsumerState<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends ConsumerState<CaseDetailScreen> {
  static final _dateFmt = DateFormat('d MMM yyyy');
  static final _dateTimeFmt = DateFormat('d MMM yyyy, h:mm a');

  @override
  void initState() {
    super.initState();
    if (widget.startVerification) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startVerification());
    }
  }

  void _startVerification() {
    final state = ref.read(foStateProvider);
    final caseData = state.caseByNo(widget.caseNo);
    if (caseData == null || !mounted) return;
    if (caseData.verificationStatus.toLowerCase() != 'completed') {
      ref.read(foStateProvider.notifier).beginVerification(widget.caseNo);
    }
    Navigator.of(context).push(
      AppRoutes.fadeUp(FieldVisitWizardScreen(caseData: caseData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foStateProvider);
    final caseData = state.caseByNo(widget.caseNo);

    if (caseData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Case')),
        body: const EmptyState(
          icon: Icons.folder_off,
          title: 'Case not found',
          message: 'This case is no longer assigned to you. Go back to the case list.',
        ),
      );
    }

    final tasks = state.tasksFor(caseData.caseNo);
    final openTask = tasks.firstWhere(
      (t) => t.status != TaskStatus.completed,
      orElse: () => tasks.isNotEmpty ? tasks.first : state.tasks.first,
    );
    final documents = state.documentsFor(caseData.caseNo);
    final evidence = state.evidenceFor(caseData.caseNo);
    final submitted = caseData.verificationStatus.toLowerCase() == 'completed';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 34),
        child: ScreenHeader(
          title: caseData.caseNo,
          subtitle: caseData.village,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, Insets.xxl),
        children: [
          _header(caseData),
          if (submitted) ...[
            const Gap(Insets.md),
            _submittedBanner(caseData),
          ],
          const Gap(Insets.lg),
          _parcelSection(caseData),
          const Gap(Insets.lg),
          _acquisitionSection(caseData),
          const Gap(Insets.lg),
          _landOwnerSection(caseData),
          const Gap(Insets.lg),
          _taskSection(caseData, openTask, submitted),
          const Gap(Insets.lg),
          _mapSection(caseData),
          const Gap(Insets.lg),
          _timelineSection(caseData),
          const Gap(Insets.lg),
          _documentsSection(caseData, documents),
          const Gap(Insets.lg),
          _evidenceSection(evidence),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.md),
            child: submitted
                ? OutlinedButton.icon(
                    onPressed: () => TasksScreen.open(context),
                    icon: const Icon(Icons.task_alt, size: 18),
                    label: const Text('VIEW ASSIGNED TASKS'),
                  )
                : FilledButton.icon(
                    onPressed: _startVerification,
                    icon: const Icon(Icons.edit_note),
                    label: Text(
                      caseData.status == CaseStatus.inProgress
                          ? 'CONTINUE FIELD VERIFICATION'
                          : 'START FIELD VERIFICATION',
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _header(LandCase c) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: Insets.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.caseNo, style: theme.textTheme.headlineSmall),
            const Gap(2),
            Text(c.projectName, style: theme.textTheme.titleMedium),
            Text('Authority: ${c.projectAuthority}', style: theme.textTheme.bodySmall),
            const Gap(Insets.md),
            Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                CaseStatusChip(status: c.status),
                PriorityChip(priority: c.priority),
                AppChip(
                  label: c.stage,
                  color: AppColors.info,
                  icon: Icons.flag_outlined,
                ),
              ],
            ),
            const Gap(Insets.md),
            const Divider(height: 1),
            const Gap(Insets.sm),
            InfoRow(label: 'Current status', value: c.status.label, highlight: true),
            InfoRow(label: 'Priority', value: c.priority.label),
            InfoRow(label: 'Due date', value: _dateFmt.format(c.dueDate)),
            InfoRow(label: 'SLA', value: c.dueLabel),
            InfoRow(label: 'Pending action', value: c.pendingAction),
            InfoRow(label: 'Last updated', value: _dateFmt.format(c.lastUpdated)),
          ],
        ),
      ),
    );
  }

  Widget _submittedBanner(LandCase c) {
    final last = c.timeline.isNotEmpty ? c.timeline.last : null;

    return AppBanner(
      tone: AppBannerTone.success,
      icon: Icons.verified_outlined,
      title: 'Field verification completed',
      message: 'Next action: ${c.pendingAction}'
          '${last != null ? '\nSubmitted ${_dateTimeFmt.format(last.date)}' : ''}',
    );
  }

  Widget _parcelSection(LandCase c) => SectionCard(
        title: 'Parcel',
        icon: Icons.landscape_outlined,
        children: [
          InfoRow(label: 'Parcel ID', value: c.parcelId),
          InfoRow(label: 'Survey Number', value: c.surveyNo, highlight: true),
          InfoRow(label: 'Village', value: c.village),
          InfoRow(label: 'Taluk', value: c.taluk),
          InfoRow(label: 'District', value: c.district),
          InfoRow(label: 'Extent', value: c.extentLabel, highlight: true),
          InfoRow(label: 'Land type', value: c.landType),
        ],
      );

  Widget _acquisitionSection(LandCase c) => SectionCard(
        title: 'Acquisition',
        icon: Icons.account_balance_outlined,
        children: [
          InfoRow(label: 'Acquisition stage', value: c.stage, highlight: true),
          InfoRow(label: 'Purpose', value: c.purpose),
          InfoRow(label: 'Notification', value: c.notificationStatus),
          InfoRow(label: 'Award', value: c.awardStatus),
          InfoRow(label: 'Compensation', value: c.compensationStatus),
          InfoRow(label: 'Possession', value: c.possessionStatus),
          InfoRow(label: 'R&R', value: c.rrStatus),
          InfoRow(label: 'Verification', value: c.verificationStatus, highlight: true),
        ],
      );

  Widget _landOwnerSection(LandCase c) => SectionCard(
        title: 'Landowner',
        icon: Icons.person_outline,
        children: [
          InfoRow(label: 'Owner name', value: c.landOwner.name, highlight: true),
          InfoRow(label: 'Ownership type', value: c.landOwner.ownershipType),
          if (c.landOwner.phone != null)
            InfoRow(label: 'Contact number', value: c.landOwner.phone!),
          InfoRow(label: 'Contact status', value: c.landOwner.contactStatus),
          InfoRow(label: 'Verification', value: c.landOwner.verificationStatus),
        ],
      );

  Widget _taskSection(LandCase c, CaseTask? task, bool submitted) {
    final theme = Theme.of(context);

    return SectionCard(
      title: 'Assigned task',
      icon: Icons.assignment_outlined,
      trailing: TextButton(
        onPressed: () => TasksScreen.open(context),
        child: const Text('ALL TASKS'),
      ),
      children: [
        if (task == null)
          const EmptyState(
            icon: Icons.task_alt,
            title: 'No Pending Tasks',
            message: 'All assigned tasks for this case are completed.',
          )
        else ...[
          Text(task.id, style: theme.textTheme.labelSmall),
          const Gap(Insets.xs),
          Text(task.title, style: theme.textTheme.titleMedium),
          const Gap(Insets.md),
          Wrap(
            spacing: Insets.sm,
            runSpacing: Insets.xs,
            children: [
              AppChip(
                label: task.status.label,
                color: task.status.color,
                uppercase: false,
              ),
              AppChip(
                label: task.slaLabel,
                color: task.isOverdue ? AppColors.danger : AppColors.neutral,
              ),
              PriorityChip(priority: task.priority, dense: true),
            ],
          ),
          const Gap(Insets.md),
          InfoRow(label: 'Assigned', value: _dateFmt.format(task.assignedDate)),
          InfoRow(label: 'Due date', value: _dateFmt.format(task.dueDate)),
          if (task.instructions != null) ...[
            const Gap(Insets.sm),
            AppBanner(
              tone: AppBannerTone.neutral,
              title: 'Instructions',
              message: task.instructions!,
            ),
          ],
          if (!submitted) ...[
            const Gap(Insets.md),
            OutlinedButton.icon(
              onPressed: _startVerification,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: Text(task.status == TaskStatus.inProgress ? 'CONTINUE' : 'START'),
            ),
          ],
        ],
      ],
    );
  }

  Widget _mapSection(LandCase c) {
    return SectionCard(
      title: 'Parcel map',
      icon: Icons.map_outlined,
      children: [
        ClipRRect(
          borderRadius: Radii.mdAll,
          child: SizedBox(
            height: 220,
            // The map owns a controller and a GPS probe; isolating it in a
            // RepaintBoundary keeps it from repainting the whole dossier.
            child: RepaintBoundary(
              child: ParcelMapScreen(caseData: c, embedded: true),
            ),
          ),
        ),
        const Gap(Insets.md),
        InfoRow(label: 'Coordinates', value: c.coordinateLabel),
        InfoRow(label: 'Parcel ID', value: c.parcelId),
      ],
    );
  }

  Widget _timelineSection(LandCase c) {
    final events = c.timeline;

    if (events.isEmpty) {
      return const SectionCard(
        title: 'Case timeline',
        icon: Icons.timeline,
        children: [
          EmptyState(
            icon: Icons.timeline,
            title: 'No timeline yet',
            message: 'Workflow events will appear here as the case progresses.',
          ),
        ],
      );
    }

    return SectionCard(
      title: 'Case timeline',
      icon: Icons.timeline,
      children: [_TimelineRail(events: events)],
    );
  }

  Widget _documentsSection(LandCase c, List<CaseDocument> documents) {
    return SectionCard(
      title: 'Documents (${documents.length})',
      icon: Icons.folder_open_outlined,
      trailing: documents.length > 4
          ? TextButton(
              onPressed: () => DocumentsScreen.open(context, caseNo: c.caseNo),
              child: const Text('VIEW ALL'),
            )
          : null,
      children: [
        if (documents.isEmpty)
          const EmptyState(
            icon: Icons.folder_open,
            title: 'No Documents',
            message: 'No documents available for this case yet.',
          )
        else
          for (final d in documents.take(4))
            _DocumentRow(document: d),
      ],
    );
  }

  Widget _evidenceSection(List<EvidenceRecord> evidence) {
    return SectionCard(
      title: 'Field evidence (${evidence.length})',
      icon: Icons.photo_camera_outlined,
      children: [
        if (evidence.isEmpty)
          const EmptyState(
            icon: Icons.photo_camera_outlined,
            title: 'No Evidence',
            message: 'No field evidence captured yet. Start a verification to add photos.',
          )
        else
          // A `GridView.count` with `children:` inside a scrolling `ListView`.
          // The eager build meant every tile — each holding a decoded image —
          // was constructed on every dossier scroll.
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: evidence.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: Insets.sm,
              crossAxisSpacing: Insets.sm,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (_, i) => _EvidenceTile(record: evidence[i]),
          ),
      ],
    );
  }
}

/// Vertical timeline rail.
///
/// The previous implementation wrapped every row in `IntrinsicHeight`, which
/// forces a second layout pass of each row — the single most common source of
/// scroll jank in a long list. Painting the rail instead means one pass.
class _TimelineRail extends StatelessWidget {
  const _TimelineRail({required this.events});

  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = events.length - 1;

    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 18,
                  child: CustomPaint(
                    painter: _TimelineRailPainter(
                      state: events[i].state,
                      drawConnector: i < last,
                      connectorDone: events[i].state != TimelineStepState.pending,
                    ),
                  ),
                ),
                const Gap(Insets.sm, horizontal: true),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i == last ? 0 : Insets.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('d MMM yyyy').format(events[i].date),
                          style: theme.textTheme.bodySmall!.copyWith(fontSize: 12),
                        ),
                        const Gap(2),
                        Text(
                          events[i].title,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: events[i].state == TimelineStepState.current
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: events[i].state == TimelineStepState.pending
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (events[i].state == TimelineStepState.current) ...[
                          const Gap(Insets.sm),
                          const AppChip(
                            label: 'Current',
                            color: AppColors.warning,
                            dense: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TimelineRailPainter extends CustomPainter {
  const _TimelineRailPainter({
    required this.state,
    required this.drawConnector,
    required this.connectorDone,
  });

  final TimelineStepState state;
  final bool drawConnector;
  final bool connectorDone;

  static const double _dotRadius = 6;
  static const double _dotCenterY = 8;
  static const double _railWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final ringColor = switch (state) {
      TimelineStepState.completed => AppColors.success,
      TimelineStepState.current => AppColors.warning,
      TimelineStepState.pending => AppColors.textTertiary,
    };

    if (drawConnector) {
      final top = _dotCenterY + _dotRadius;
      canvas.drawRect(
        Rect.fromLTWH(
          (size.width - _railWidth) / 2,
          top,
          _railWidth,
          size.height - top,
        ),
        Paint()
          ..color = connectorDone
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.border,
      );
    }

    final centre = Offset(size.width / 2, _dotCenterY);
    final filled = state == TimelineStepState.completed;

    canvas.drawCircle(
      centre,
      _dotRadius,
      Paint()..color = filled ? AppColors.success : Colors.white,
    );
    canvas.drawCircle(
      centre,
      _dotRadius - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = state == TimelineStepState.current ? 3 : 2
        ..color = ringColor,
    );
  }

  @override
  bool shouldRepaint(covariant _TimelineRailPainter old) =>
      old.state != state ||
      old.drawConnector != drawConnector ||
      old.connectorDone != connectorDone;
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.document});

  final CaseDocument document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.xs),
      child: TappableCard(
        onTap: () => DocumentPreviewScreen.open(context, document: document),
        padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.md),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.neutralSoft,
                borderRadius: Radii.smAll,
              ),
              child: const Icon(Icons.description_outlined, size: 18, color: AppColors.textSecondary),
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
                  Text(
                    '${document.type} · ${document.receivedOn == null ? 'Not received' : DateFormat('d MMM yyyy').format(document.receivedOn!)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.copyWith(fontSize: 12.5),
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
      ),
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({required this.record});

  final EvidenceRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PressScale(
      onTap: () => EvidenceViewerScreen.open(context, record: record),
      child: Material(
        color: AppColors.surface,
        borderRadius: Radii.mdAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => EvidenceViewerScreen.open(context, record: record),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: Radii.mdAll,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: EvidenceThumb(record: record, cacheWidth: 200),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Insets.sm, Insets.xs, Insets.sm, Insets.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evidence ${record.number}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall!.copyWith(fontSize: 10.5),
                      ),
                      Text(
                        record.type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall!.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
