import 'dart:ui' show Color;

import '../../core/theme/app_colors.dart';

/// Central vocabulary for case / task / document state.
///
/// Every label and colour used by the UI lives here so screens never hardcode
/// status strings, and a future API can map onto the same enums.
enum CaseStatus {
  verificationPending('Verification Pending'),
  inProgress('In Progress'),
  awaitingDocuments('Awaiting Documents'),
  compensationPending('Compensation Pending'),
  rrVerification('R&R Verification'),
  possessionPending('Possession Pending'),
  officerReview('Awaiting Officer Review'),
  completed('Completed'),
  overdue('Overdue');

  const CaseStatus(this.label);
  final String label;

  Color get color => switch (this) {
        verificationPending => AppColors.warning,
        inProgress => AppColors.info,
        awaitingDocuments => AppColors.violet,
        compensationPending => AppColors.serverDown,
        rrVerification => const Color(0xFF00695C),
        possessionPending => const Color(0xFF283593),
        officerReview => AppColors.success,
        completed => AppColors.success,
        overdue => AppColors.danger,
      };

  bool get isTerminal => this == completed;
}

enum CasePriority {
  high('HIGH'),
  medium('MEDIUM'),
  low('LOW');

  const CasePriority(this.label);
  final String label;

  Color get color => switch (this) {
        high => AppColors.danger,
        medium => AppColors.warning,
        low => AppColors.neutral,
      };

  int get rank => switch (this) {
        high => 0,
        medium => 1,
        low => 2,
      };
}

enum TaskStatus {
  pending('PENDING'),
  inProgress('IN PROGRESS'),
  completed('COMPLETED');

  const TaskStatus(this.label);
  final String label;

  Color get color => switch (this) {
        pending => AppColors.warning,
        inProgress => AppColors.info,
        completed => AppColors.success,
      };
}

enum DocumentStatus {
  verified('Verified'),
  pendingReview('Pending Review'),
  pending('Pending'),
  notAvailable('Not Available');

  const DocumentStatus(this.label);
  final String label;

  Color get color => switch (this) {
        verified => AppColors.success,
        pendingReview => AppColors.warning,
        pending => AppColors.info,
        notAvailable => AppColors.danger,
      };
}

enum TimelineStepState { completed, current, pending }

enum NotificationKind {
  priority('HIGH PRIORITY'),
  taskAssigned('TASK ASSIGNED'),
  syncComplete('SYNC COMPLETE'),
  slaAlert('SLA ALERT'),
  documentUpdate('DOCUMENT UPDATE'),
  verification('VERIFICATION');

  const NotificationKind(this.label);
  final String label;

  Color get color => switch (this) {
        priority => AppColors.danger,
        taskAssigned => AppColors.info,
        syncComplete => AppColors.success,
        slaAlert => AppColors.serverDown,
        documentUpdate => AppColors.violet,
        verification => const Color(0xFF00695C),
      };
}

enum UploadStatus { pending, synced }

extension UploadStatusX on UploadStatus {
  String get label => switch (this) {
        UploadStatus.pending => 'PENDING',
        UploadStatus.synced => 'SYNCED',
      };

  Color get color => switch (this) {
        UploadStatus.pending => AppColors.warning,
        UploadStatus.synced => AppColors.success,
      };
}

/// Land-use categories used by the verification wizard and the case dossier.
const kLandUses = [
  'Agricultural',
  'Residential',
  'Commercial',
  'Industrial',
  'Vacant',
  'Other',
];

const kIrrigationTypes = ['Irrigated', 'Rain-fed', 'Not Applicable'];

const kEvidenceTypes = [
  'Boundary Photograph',
  'Land Use Photograph',
  'Survey Stone',
  'Structure Photograph',
  'Crop Photograph',
  'Owner Interaction',
];
