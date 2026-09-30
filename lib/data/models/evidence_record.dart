import 'enums.dart';

/// A piece of field evidence attached to a case.
///
/// [filePath] is only set when a real photo was taken with the device camera;
/// prototype evidence captured through the mock flow keeps it null and is
/// rendered by the placeholder thumbnail painter.
class EvidenceRecord {
  const EvidenceRecord({
    required this.id,
    required this.caseNo,
    required this.type,
    required this.caption,
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
    required this.gpsTagged,
    required this.uploadStatus,
    this.accuracyMetres,
    this.filePath,
    this.officerId,
  });

  /// Display number, e.g. `Evidence #001`.
  final String id;
  final String caseNo;
  final String type;
  final String caption;
  final DateTime capturedAt;
  final double? latitude;
  final double? longitude;
  final double? accuracyMetres;
  final bool gpsTagged;
  final UploadStatus uploadStatus;
  final String? filePath;
  final String? officerId;

  bool get hasPhoto => filePath != null && filePath!.isNotEmpty;

  /// Display number, e.g. `#001` from an id of `EV-001`.
  String get number => id.startsWith('EV-') ? '#${id.substring(3)}' : id;

  EvidenceRecord copyWith({UploadStatus? uploadStatus, String? filePath}) =>
      EvidenceRecord(
        id: id,
        caseNo: caseNo,
        type: type,
        caption: caption,
        capturedAt: capturedAt,
        latitude: latitude,
        longitude: longitude,
        accuracyMetres: accuracyMetres,
        gpsTagged: gpsTagged,
        uploadStatus: uploadStatus ?? this.uploadStatus,
        filePath: filePath ?? this.filePath,
        officerId: officerId,
      );
}
