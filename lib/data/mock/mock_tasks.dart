import '../models/case_task.dart';
import '../models/enums.dart';
import 'mock_dates.dart';

/// Field tasks assigned to the officer, each linked to a mock case.
List<CaseTask> buildMockTasks() {
  final seeds = <_TaskSeed>[
    _TaskSeed(
      id: 'TASK-0142',
      caseNo: 'LA-TN-CBE-2026-0142',
      title: 'Parcel Boundary Verification',
      priority: CasePriority.high,
      status: TaskStatus.pending,
      due: 1,
      assigned: -2,
      instructions:
          'Walk the full boundary with the landowner, photograph every survey '
          'stone and confirm the extent against the Patta extract.',
    ),
    _TaskSeed(
      id: 'TASK-0142B',
      caseNo: 'LA-TN-CBE-2026-0142',
      title: 'Land Record Collection',
      priority: CasePriority.medium,
      status: TaskStatus.pending,
      due: 2,
      assigned: -2,
      instructions: 'Collect the latest Patta and Chitta extract from the village office.',
    ),
    _TaskSeed(
      id: 'TASK-0142C',
      caseNo: 'LA-TN-CBE-2026-0142',
      title: 'GPS Coordinate Recheck',
      priority: CasePriority.medium,
      status: TaskStatus.pending,
      due: 1,
      assigned: -1,
      instructions: 'Re-capture the four parcel corners with sub-10 m accuracy.',
    ),
    _TaskSeed(
      id: 'TASK-0138',
      caseNo: 'LA-TN-CBE-2026-0138',
      title: 'Landowner Verification',
      priority: CasePriority.high,
      status: TaskStatus.pending,
      due: 0,
      assigned: -1,
      instructions:
          'Verify photo identity of the owner and record the relationship of any occupant met on site.',
    ),
    _TaskSeed(
      id: 'TASK-0127',
      caseNo: 'LA-TN-CBE-2026-0127',
      title: 'Possession Site Inspection',
      priority: CasePriority.medium,
      status: TaskStatus.inProgress,
      due: 1,
      assigned: -2,
      instructions:
          'Confirm current possession status and note any structures inside the alignment.',
    ),
    _TaskSeed(
      id: 'TASK-0127B',
      caseNo: 'LA-TN-CBE-2026-0127',
      title: 'Irrigation Channel Check',
      priority: CasePriority.low,
      status: TaskStatus.pending,
      due: 2,
      assigned: -2,
      instructions: 'Record the irrigation channel crossing inside the parcel.',
    ),
    _TaskSeed(
      id: 'TASK-0119',
      caseNo: 'LA-TN-CBE-2026-0119',
      title: 'Evidence Upload',
      priority: CasePriority.medium,
      status: TaskStatus.pending,
      due: -3,
      assigned: -5,
      pendingFiles: 2,
      instructions: 'Two field photographs are still pending upload from the last visit.',
    ),
    _TaskSeed(
      id: 'TASK-0115',
      caseNo: 'LA-TN-CBE-2026-0115',
      title: 'Boundary Dispute Follow-up',
      priority: CasePriority.low,
      status: TaskStatus.pending,
      due: -5,
      assigned: -7,
      instructions: 'Re-visit with the village revenue officer to settle the boundary dispute.',
    ),
    _TaskSeed(
      id: 'TASK-0112',
      caseNo: 'LA-TN-CBE-2026-0112',
      title: 'Compensation Record Check',
      priority: CasePriority.medium,
      status: TaskStatus.pending,
      due: 6,
      assigned: -1,
      instructions: 'Verify the compensation calculation sheet against the notified extent.',
    ),
    _TaskSeed(
      id: 'TASK-0112B',
      caseNo: 'LA-TN-CBE-2026-0112',
      title: 'R&R Eligibility Verify',
      priority: CasePriority.low,
      status: TaskStatus.pending,
      due: 6,
      assigned: -1,
      instructions: 'Check R&R eligibility of the displaced tenants, if any.',
    ),
    _TaskSeed(
      id: 'TASK-0131',
      caseNo: 'LA-TN-CBE-2026-0131',
      title: 'Survey Stone Photograph',
      priority: CasePriority.medium,
      status: TaskStatus.pending,
      due: 3,
      assigned: 0,
      instructions: 'Photograph every survey stone along the canal bed with GPS tags.',
    ),
    _TaskSeed(
      id: 'TASK-0121',
      caseNo: 'LA-TN-CBE-2026-0121',
      title: 'Crop Damage Assessment',
      priority: CasePriority.low,
      status: TaskStatus.pending,
      due: 4,
      assigned: -1,
      instructions: 'Estimate standing crop and record the crop type before handover.',
    ),
    _TaskSeed(
      id: 'TASK-0121B',
      caseNo: 'LA-TN-CBE-2026-0121',
      title: 'Structure Inventory',
      priority: CasePriority.low,
      status: TaskStatus.inProgress,
      due: 4,
      assigned: -1,
      instructions: 'Inventory any farm structures inside the solar block.',
    ),
    _TaskSeed(
      id: 'TASK-0108',
      caseNo: 'LA-TN-CBE-2026-0108',
      title: 'Final Inspection Report',
      priority: CasePriority.low,
      status: TaskStatus.completed,
      due: -9,
      assigned: -11,
      instructions: 'Submit the final inspection report before case closure.',
    ),
    _TaskSeed(
      id: 'TASK-0103',
      caseNo: 'LA-TN-CBE-2026-0103',
      title: 'Possession Handover',
      priority: CasePriority.medium,
      status: TaskStatus.completed,
      due: -11,
      assigned: -13,
      instructions: 'Witness possession handover and collect the receipt.',
    ),
    _TaskSeed(
      id: 'TASK-0135',
      caseNo: 'LA-TN-CBE-2026-0135',
      title: 'Award Document Follow-up',
      priority: CasePriority.high,
      status: TaskStatus.pending,
      due: 2,
      assigned: -3,
      instructions:
          'The award document is still missing from the district office. Collect '
          'the signed copy before verification can be closed.',
    ),
    _TaskSeed(
      id: 'TASK-0130',
      caseNo: 'LA-TN-CBE-2026-0130',
      title: 'R&R Entitlement Verification',
      priority: CasePriority.medium,
      status: TaskStatus.pending,
      due: 5,
      assigned: -1,
      instructions:
          'Meet both tenant families and record their entitlement claims with '
          'photographic proof of residence.',
    ),
    _TaskSeed(
      id: 'TASK-0133',
      caseNo: 'LA-TN-CBE-2026-0133',
      title: 'Possession Handover Witness',
      priority: CasePriority.high,
      status: TaskStatus.pending,
      due: 0,
      assigned: -2,
      instructions:
          'Attend the handover, witness the boundary demarcation and collect the '
          'signed acknowledgement from the landowner.',
    ),
  ];

  return [
    for (final s in seeds)
      CaseTask(
        id: s.id,
        caseNo: s.caseNo,
        title: s.title,
        priority: s.priority,
        assignedDate: day(s.assigned),
        dueDate: day(s.due),
        status: s.status,
        instructions: s.instructions,
        pendingFiles: s.pendingFiles,
      ),
  ];
}

class _TaskSeed {
  const _TaskSeed({
    required this.id,
    required this.caseNo,
    required this.title,
    required this.priority,
    required this.status,
    required this.due,
    required this.assigned,
    this.instructions,
    this.pendingFiles = 0,
  });

  final String id;
  final String caseNo;
  final String title;
  final CasePriority priority;
  final TaskStatus status;
  final int due;
  final int assigned;
  final String? instructions;
  final int pendingFiles;
}
