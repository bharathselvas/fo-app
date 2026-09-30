import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/enums.dart';
import '../../data/models/land_case.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/evidence_thumb.dart';
import '../../widgets/status_widgets.dart';
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
      MaterialPageRoute(
        builder: (_) =>
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
      MaterialPageRoute(builder: (_) => FieldVisitWizardScreen(caseData: caseData)),
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
      orElse: () => tasks.isNotEmpty
          ? tasks.first
          : state.tasks.first,
    );
    final documents = state.documentsFor(caseData.caseNo);
    final evidence = state.evidenceFor(caseData.caseNo);
    final submitted = caseData.verificationStatus.toLowerCase() == 'completed';

    return Scaffold(
      appBar: AppBar(title: Text(caseData.caseNo)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _header(caseData),
          if (submitted) ...[
            const SizedBox(height: 12),
            _submittedBanner(caseData),
          ],
          const SizedBox(height: 16),
          _parcelSection(caseData),
          const SizedBox(height: 16),
          _acquisitionSection(caseData),
          const SizedBox(height: 16),
          _landOwnerSection(caseData),
          const SizedBox(height: 16),
          _taskSection(caseData, openTask, submitted),
          const SizedBox(height: 16),
          SectionCard(
            title: 'SECTION 5 — MAP',
            icon: Icons.map_outlined,
            children: [
              SizedBox(
                height: 240,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ParcelMapScreen(caseData: caseData, embedded: true),
                ),
              ),
              const SizedBox(height: 10),
              InfoRow(label: 'Coordinates', value: caseData.coordinateLabel),
              InfoRow(label: 'Parcel ID', value: caseData.parcelId),
            ],
          ),
          const SizedBox(height: 16),
          _timelineSection(caseData),
          const SizedBox(height: 16),
          _documentsSection(caseData, documents),
          const SizedBox(height: 16),
          _evidenceSection(caseData, evidence),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: submitted
              ? FilledButton.tonalIcon(
                  onPressed: () => TasksScreen.open(context),
                  icon: const Icon(Icons.task_alt),
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
    );
  }

  Widget _header(LandCase c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.caseNo,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: 0.3),
            ),
            const SizedBox(height: 4),
            Text(c.projectName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text('Authority: ${c.projectAuthority}',
                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CaseStatusChip(status: c.status),
                PriorityChip(priority: c.priority),
                StatusChip(
                  label: c.stage.toUpperCase(),
                  color: Colors.indigo,
                  icon: Icons.flag_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
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
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('FIELD VERIFICATION COMPLETED',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1B5E20))),
                  const SizedBox(height: 4),
                  Text(
                    'Next action: ${c.pendingAction}'
                    '${last != null ? '\nSubmitted ${_dateTimeFmt.format(last.date)}' : ''}',
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _parcelSection(LandCase c) => SectionCard(
        title: 'SECTION 1 — PARCEL',
        icon: Icons.landscape_outlined,
        children: [
          InfoRow(label: 'Parcel ID', value: c.parcelId),
          InfoRow(label: 'Survey Number', value: c.surveyNo, highlight: true),
          InfoRow(label: 'Village', value: c.village),
          InfoRow(label: 'Taluk', value: c.taluk),
          InfoRow(label: 'District', value: c.district),
          InfoRow(label: 'Extent', value: c.extentLabel, highlight: true),
          InfoRow(label: 'Land type', value: c.landType),
          InfoRow(label: 'Coordinates', value: c.coordinateLabel),
        ],
      );

  Widget _acquisitionSection(LandCase c) => SectionCard(
        title: 'SECTION 2 — ACQUISITION',
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
        title: 'SECTION 3 — LANDOWNER',
        icon: Icons.person_outline,
        children: [
          InfoRow(label: 'Owner name', value: c.landOwner.name, highlight: true),
          InfoRow(label: 'Ownership type', value: c.landOwner.ownershipType),
          if (c.landOwner.phone != null) InfoRow(label: 'Contact number', value: c.landOwner.phone!),
          InfoRow(label: 'Contact status', value: c.landOwner.contactStatus),
          InfoRow(label: 'Verification', value: c.landOwner.verificationStatus),
        ],
      );

  Widget _taskSection(LandCase c, dynamic task, bool submitted) {
    return SectionCard(
      title: 'SECTION 4 — ASSIGNED TASK',
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
            message: 'Great — all assigned tasks for this case are completed.',
          )
        else ...[
          Text(task.id as String, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(task.title as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusChip(label: task.status.label as String, color: task.status.color),
              StatusChip(label: task.slaLabel as String, color: Colors.blueGrey),
              PriorityChip(priority: task.priority, dense: true),
            ],
          ),
          const SizedBox(height: 10),
          InfoRow(label: 'Assigned', value: _dateFmt.format(task.assignedDate as DateTime)),
          InfoRow(label: 'Due date', value: _dateFmt.format(task.dueDate as DateTime)),
          if (task.instructions != null) ...[
            const SizedBox(height: 4),
            Text('INSTRUCTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text(task.instructions as String, style: const TextStyle(height: 1.4)),
          ],
          if (!submitted) ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _startVerification,
              icon: const Icon(Icons.play_arrow),
              label: Text(task.status == TaskStatus.inProgress ? 'CONTINUE' : 'START'),
            ),
          ],
        ],
      ],
    );
  }

  Widget _timelineSection(LandCase c) {
    final events = c.timeline;
    if (events.isEmpty) {
      return const SectionCard(
        title: 'CASE TIMELINE',
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
      title: 'CASE TIMELINE',
      icon: Icons.timeline,
      children: [
        for (var i = 0; i < events.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: switch (events[i].state) {
                          TimelineStepState.completed => const Color(0xFF2E7D32),
                          _ => Colors.white,
                        },
                        border: Border.all(
                          color: switch (events[i].state) {
                            TimelineStepState.completed => const Color(0xFF2E7D32),
                            TimelineStepState.current => const Color(0xFFF57F17),
                            TimelineStepState.pending => Colors.grey.shade400,
                          },
                          width: events[i].state == TimelineStepState.current ? 4 : 2,
                        ),
                      ),
                    ),
                    if (i < events.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: events[i].state == TimelineStepState.pending
                              ? Colors.grey.shade300
                              : const Color(0xFF2E7D32).withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i == events.length - 1 ? 0 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dateFmt.format(events[i].date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          events[i].title,
                          style: TextStyle(
                            fontWeight: events[i].state == TimelineStepState.current
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: events[i].state == TimelineStepState.pending
                                ? Colors.grey[600]
                                : Colors.black87,
                          ),
                        ),
                        if (events[i].state == TimelineStepState.current)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: StatusChip(label: 'CURRENT', color: const Color(0xFFF57F17)),
                          ),
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

  Widget _documentsSection(LandCase c, List<dynamic> documents) {
    final shown = documents.take(4).toList();
    return SectionCard(
      title: 'DOCUMENTS (${documents.length})',
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
          ...shown.map((d) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_outlined),
                title: Text(d.name as String,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text(
                  '${d.type} · ${d.receivedOn == null ? 'Not received' : _dateFmt.format(d.receivedOn!)}',
                  style: const TextStyle(fontSize: 12.5),
                ),
                trailing: StatusChip(label: (d.status as dynamic).label as String, color: (d.status as dynamic).color as Color),
                onTap: () => DocumentPreviewScreen.open(context, document: d),
              )),
      ],
    );
  }

  Widget _evidenceSection(LandCase c, List<dynamic> evidence) {
    return SectionCard(
      title: 'FIELD EVIDENCE (${evidence.length})',
      icon: Icons.photo_camera_outlined,
      children: [
        if (evidence.isEmpty)
          const EmptyState(
            icon: Icons.photo_camera_outlined,
            title: 'No Evidence',
            message: 'No field evidence captured yet. Start a verification to add photos.',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: evidence.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (_, i) {
              final e = evidence[i];
              return InkWell(
                onTap: () => EvidenceViewerScreen.open(context, record: e),
                borderRadius: BorderRadius.circular(10),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: EvidenceThumb(record: e)),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Evidence ${e.number}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                            ),
                            Text(
                              e.type,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10.5, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
