import 'package:flutter/material.dart';

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
        verificationPending => const Color(0xFFF57F17),
        inProgress => const Color(0xFF1565C0),
        awaitingDocuments => const Color(0xFF6A1B9A),
        compensationPending => const Color(0xFFE65100),
        rrVerification => const Color(0xFF00695C),
        possessionPending => const Color(0xFF283593),
        officerReview => const Color(0xFF2E7D32),
        completed => const Color(0xFF2E7D32),
        overdue => const Color(0xFFB71C1C),
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
        high => const Color(0xFFB71C1C),
        medium => const Color(0xFFF57F17),
        low => const Color(0xFF37474F),
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
        pending => const Color(0xFFF57F17),
        inProgress => const Color(0xFF1565C0),
        completed => const Color(0xFF2E7D32),
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
        verified => const Color(0xFF2E7D32),
        pendingReview => const Color(0xFFF57F17),
        pending => const Color(0xFF1565C0),
        notAvailable => const Color(0xFFB71C1C),
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
        priority => const Color(0xFFB71C1C),
        taskAssigned => const Color(0xFF1565C0),
        syncComplete => const Color(0xFF2E7D32),
        slaAlert => const Color(0xFFE65100),
        documentUpdate => const Color(0xFF6A1B9A),
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
        UploadStatus.pending => const Color(0xFFF57F17),
        UploadStatus.synced => const Color(0xFF2E7D32),
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
