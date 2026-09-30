import '../models/enums.dart';
import '../models/evidence_record.dart';
import 'mock_dates.dart';

/// Field evidence already captured for the assigned cases.
List<EvidenceRecord> buildMockEvidence() {
  final seeds = <_EvSeed>[
    _EvSeed('EV-001', 'LA-TN-CBE-2026-0142', 'Boundary Photograph', 'North-west corner stone', -6, 10, 46, true, UploadStatus.synced, 11.0461, 77.1230, 5.2),
    _EvSeed('EV-002', 'LA-TN-CBE-2026-0142', 'Land Use Photograph', 'Paddy field inside alignment', -6, 10, 48, true, UploadStatus.synced, 11.0458, 77.1241, 6.0),
    _EvSeed('EV-003', 'LA-TN-CBE-2026-0142', 'Survey Stone', 'Survey stone 142/3A marked', -6, 10, 51, true, UploadStatus.pending, 11.0453, 77.1236, 7.4),
    _EvSeed('EV-004', 'LA-TN-CBE-2026-0142', 'Structure Photograph', 'Farm shed on eastern edge', -2, 11, 12, true, UploadStatus.pending, 11.0459, 77.1244, 8.1),
    _EvSeed('EV-005', 'LA-TN-CBE-2026-0138', 'Boundary Photograph', 'Southern boundary wall', -4, 9, 30, true, UploadStatus.synced, 11.1015, 77.0184, 5.8),
    _EvSeed('EV-006', 'LA-TN-CBE-2026-0138', 'Owner Interaction', 'Owner identity verified on site', -4, 9, 41, true, UploadStatus.synced, 11.1009, 77.0193, 6.3),
    _EvSeed('EV-007', 'LA-TN-CBE-2026-0127', 'Crop Photograph', 'Banana crop inside alignment', -3, 15, 5, true, UploadStatus.synced, 10.8715, 76.9900, 4.9),
    _EvSeed('EV-008', 'LA-TN-CBE-2026-0127', 'Boundary Photograph', 'Eastern bund reference stone', -3, 15, 11, true, UploadStatus.pending, 10.8709, 76.9910, 9.2),
    _EvSeed('EV-009', 'LA-TN-CBE-2026-0127', 'Structure Photograph', 'Farm pump room', -1, 16, 22, true, UploadStatus.pending, 10.8718, 76.9897, 7.7),
    _EvSeed('EV-010', 'LA-TN-CBE-2026-0119', 'Land Use Photograph', 'Commercial frontage on drain line', -4, 11, 5, true, UploadStatus.pending, 10.6587, 76.9937, 6.6),
    _EvSeed('EV-011', 'LA-TN-CBE-2026-0119', 'Boundary Photograph', 'Drain alignment start point', -4, 11, 9, false, UploadStatus.pending, null, null, null),
    _EvSeed('EV-012', 'LA-TN-CBE-2026-0115', 'Survey Stone', 'Disputed corner stone', -7, 10, 18, true, UploadStatus.pending, 11.0065, 77.0419, 11.4),
    _EvSeed('EV-013', 'LA-TN-CBE-2026-0131', 'Crop Photograph', 'Standing ragi crop', -3, 9, 55, true, UploadStatus.synced, 10.6625, 76.9670, 5.5),
    _EvSeed('EV-014', 'LA-TN-CBE-2026-0131', 'Survey Stone', 'Canal bed stone 219/1B', -3, 10, 3, true, UploadStatus.pending, 10.6618, 76.9680, 6.9),
    _EvSeed('EV-015', 'LA-TN-CBE-2026-0121', 'Boundary Photograph', 'Solar block north boundary', -2, 14, 27, true, UploadStatus.synced, 10.8938, 76.9448, 8.8),
    _EvSeed('EV-016', 'LA-TN-CBE-2026-0121', 'Crop Photograph', 'Sparse shrub growth on plot', -2, 14, 33, true, UploadStatus.pending, 10.8930, 76.9456, 7.1),
    _EvSeed('EV-017', 'LA-TN-CBE-2026-0112', 'Structure Photograph', 'Warehouse inside industrial plot', -5, 12, 40, true, UploadStatus.synced, 11.0651, 76.9038, 6.2),
    _EvSeed('EV-018', 'LA-TN-CBE-2026-0135', 'Boundary Photograph', 'Intake well access road boundary', -9, 10, 20, true, UploadStatus.synced, 11.0238, 76.9982, 5.4),
    _EvSeed('EV-019', 'LA-TN-CBE-2026-0135', 'Land Use Photograph', 'Coconut plantation on the notified plot', -9, 10, 33, true, UploadStatus.synced, 11.0230, 76.9992, 6.7),
    _EvSeed('EV-020', 'LA-TN-CBE-2026-0130', 'Owner Interaction', 'Tenant family entitlement discussion', -2, 11, 45, true, UploadStatus.pending, 11.0656, 76.9441, 7.9),
    _EvSeed('EV-021', 'LA-TN-CBE-2026-0130', 'Structure Photograph', 'Rental house of the second tenant family', -2, 11, 58, true, UploadStatus.pending, 11.0648, 76.9451, 8.4),
    _EvSeed('EV-022', 'LA-TN-CBE-2026-0133', 'Boundary Photograph', 'Demarcated handover boundary', -1, 15, 20, true, UploadStatus.synced, 10.7222, 77.0177, 5.1),
    _EvSeed('EV-023', 'LA-TN-CBE-2026-0133', 'Structure Photograph', 'Farmer shed inside acquired portion', -1, 15, 27, true, UploadStatus.pending, 10.7214, 77.0187, 6.8),
  ];

  return [
    for (final s in seeds)
      EvidenceRecord(
        id: s.id,
        caseNo: s.caseNo,
        type: s.type,
        caption: s.caption,
        capturedAt: day(s.dayOffset).add(Duration(hours: s.hour, minutes: s.minute)),
        latitude: s.lat,
        longitude: s.lng,
        accuracyMetres: s.accuracy,
        gpsTagged: s.gpsTagged,
        uploadStatus: s.upload,
        officerId: 'FO-TN-CBE-0247',
      ),
  ];
}

class _EvSeed {
  const _EvSeed(
    this.id,
    this.caseNo,
    this.type,
    this.caption,
    this.dayOffset,
    this.hour,
    this.minute,
    this.gpsTagged,
    this.upload,
    this.lat,
    this.lng,
    this.accuracy,
  );

  final String id;
  final String caseNo;
  final String type;
  final String caption;
  final int dayOffset;
  final int hour;
  final int minute;
  final bool gpsTagged;
  final UploadStatus upload;
  final double? lat;
  final double? lng;
  final double? accuracy;
}
