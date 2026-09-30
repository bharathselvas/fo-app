import 'enums.dart';

/// A document on the case file (Documents section).
class CaseDocument {
  const CaseDocument({
    required this.id,
    required this.caseNo,
    required this.name,
    required this.type,
    required this.status,
    this.receivedOn,
    this.sizeLabel = '—',
    this.pages,
  });

  final String id;
  final String caseNo;
  final String name;
  final String type;
  final DocumentStatus status;
  final DateTime? receivedOn;
  final String sizeLabel;
  final int? pages;

  bool get available => status != DocumentStatus.notAvailable;

  CaseDocument copyWith({DocumentStatus? status}) => CaseDocument(
        id: id,
        caseNo: caseNo,
        name: name,
        type: type,
        status: status ?? this.status,
        receivedOn: receivedOn,
        sizeLabel: sizeLabel,
        pages: pages,
      );
}
