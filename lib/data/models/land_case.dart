import 'enums.dart';

/// A single workflow milestone on a case (Case Timeline section).
class TimelineEvent {
  const TimelineEvent({
    required this.date,
    required this.title,
    required this.state,
  });

  final DateTime date;
  final String title;
  final TimelineStepState state;

  TimelineEvent copyWith({DateTime? date, String? title, TimelineStepState? state}) =>
      TimelineEvent(
        date: date ?? this.date,
        title: title ?? this.title,
        state: state ?? this.state,
      );
}

/// Landowner / occupant attached to a case (Landowner section).
class LandOwner {
  const LandOwner({
    required this.name,
    required this.ownershipType,
    required this.contactStatus,
    required this.verificationStatus,
    this.phone,
  });

  final String name;
  final String ownershipType;
  final String contactStatus;
  final String verificationStatus;
  final String? phone;

  LandOwner copyWith({
    String? name,
    String? ownershipType,
    String? contactStatus,
    String? verificationStatus,
    String? phone,
  }) =>
      LandOwner(
        name: name ?? this.name,
        ownershipType: ownershipType ?? this.ownershipType,
        contactStatus: contactStatus ?? this.contactStatus,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        phone: phone ?? this.phone,
      );
}

/// One land-acquisition case assigned to the field officer.
class LandCase {
  const LandCase({
    required this.caseNo,
    required this.projectName,
    required this.projectAuthority,
    required this.district,
    required this.taluk,
    required this.village,
    required this.surveyNo,
    required this.parcelId,
    required this.projectId,
    required this.extentAcres,
    required this.landType,
    required this.purpose,
    required this.stage,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.assignedOfficerId,
    required this.landOwner,
    required this.compensationStatus,
    required this.rrStatus,
    required this.notificationStatus,
    required this.awardStatus,
    required this.possessionStatus,
    required this.verificationStatus,
    required this.pendingAction,
    required this.lastUpdated,
    required this.latitude,
    required this.longitude,
    required this.geometryWkt,
    required this.timeline,
  });

  /// Case ID, e.g. `LA-TN-CBE-2026-0142`.
  final String caseNo;
  final String projectName;
  final String projectAuthority;
  final String district;
  final String taluk;
  final String village;
  final String surveyNo;
  final String parcelId;
  final String projectId;
  final double extentAcres;
  final String landType;
  final String purpose;
  final String stage;
  final CaseStatus status;
  final CasePriority priority;
  final DateTime dueDate;
  final String assignedOfficerId;
  final LandOwner landOwner;
  final String compensationStatus;
  final String rrStatus;
  final String notificationStatus;
  final String awardStatus;
  final String possessionStatus;

  /// Field verification outcome: Pending / In Progress / Completed.
  final String verificationStatus;
  final String pendingAction;
  final DateTime lastUpdated;
  final double latitude;
  final double longitude;
  final String geometryWkt;
  final List<TimelineEvent> timeline;

  String get id => caseNo;

  String get extentLabel => '${extentAcres.toStringAsFixed(2)} Acres';

  String get coordinateLabel =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  /// Overdue = the due date has passed and the case is still open. A case due
  /// *today* is due today, not overdue.
  bool get isOverdue =>
      status != CaseStatus.completed && _dateOnly(dueDate).isBefore(_dateOnly(DateTime.now()));

  /// Days until the due date (negative = overdue).
  int get daysUntilDue => _dateOnly(dueDate).difference(_dateOnly(DateTime.now())).inDays;

  String get dueLabel {
    if (status == CaseStatus.completed) return 'Completed';
    final d = daysUntilDue;
    if (d < 0) return 'Overdue by ${-d} day${-d == 1 ? '' : 's'}';
    if (d == 0) return 'Due today';
    if (d == 1) return 'Due tomorrow';
    return 'Due in $d days';
  }

  LandCase copyWith({
    String? stage,
    CaseStatus? status,
    CasePriority? priority,
    LandOwner? landOwner,
    String? verificationStatus,
    String? pendingAction,
    DateTime? lastUpdated,
    String? compensationStatus,
    String? rrStatus,
    String? possessionStatus,
    List<TimelineEvent>? timeline,
  }) =>
      LandCase(
        caseNo: caseNo,
        projectName: projectName,
        projectAuthority: projectAuthority,
        district: district,
        taluk: taluk,
        village: village,
        surveyNo: surveyNo,
        parcelId: parcelId,
        projectId: projectId,
        extentAcres: extentAcres,
        landType: landType,
        purpose: purpose,
        stage: stage ?? this.stage,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        dueDate: dueDate,
        assignedOfficerId: assignedOfficerId,
        landOwner: landOwner ?? this.landOwner,
        compensationStatus: compensationStatus ?? this.compensationStatus,
        rrStatus: rrStatus ?? this.rrStatus,
        notificationStatus: notificationStatus,
        awardStatus: awardStatus,
        possessionStatus: possessionStatus ?? this.possessionStatus,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        pendingAction: pendingAction ?? this.pendingAction,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        latitude: latitude,
        longitude: longitude,
        geometryWkt: geometryWkt,
        timeline: timeline ?? this.timeline,
      );

  /// Marks the timeline up to [index] as done and the following step current.
  List<TimelineEvent> timelineWithAppended(String title) {
    final now = DateTime.now();
    final updated = [
      for (final e in timeline)
        e.state == TimelineStepState.current
            ? e.copyWith(state: TimelineStepState.completed)
            : e,
      TimelineEvent(date: now, title: title, state: TimelineStepState.current),
    ];
    return updated;
  }
}

/// Calendar-day truncation so due-date maths ignores time of day.
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
