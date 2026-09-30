import '../models/case_document.dart';
import '../models/enums.dart';
import 'mock_dates.dart';

/// Documents held on each case file.
List<CaseDocument> buildMockDocuments() {
  final seeds = <_DocSeed>[
    _DocSeed('DOC-0142-1', 'LA-TN-CBE-2026-0142', 'Land Record Extract (Patta)',
        DocumentStatus.verified, received: -12, pages: 2, size: '412 KB'),
    _DocSeed('DOC-0142-2', 'LA-TN-CBE-2026-0142', 'Survey Sketch',
        DocumentStatus.pendingReview, received: -8, pages: 1, size: '1.1 MB'),
    _DocSeed('DOC-0142-3', 'LA-TN-CBE-2026-0142', 'Preliminary Notification',
        DocumentStatus.verified, received: -15, pages: 6, size: '860 KB'),
    _DocSeed('DOC-0142-4', 'LA-TN-CBE-2026-0142', 'Award Document',
        DocumentStatus.notAvailable, pages: null, size: '—'),
    _DocSeed('DOC-0138-1', 'LA-TN-CBE-2026-0138', 'Field Measurement Chart',
        DocumentStatus.verified, received: -6, pages: 3, size: '740 KB'),
    _DocSeed('DOC-0138-2', 'LA-TN-CBE-2026-0138', 'Encumbrance Certificate',
        DocumentStatus.pendingReview, received: -3, pages: 4, size: '530 KB'),
    _DocSeed('DOC-0127-1', 'LA-TN-CBE-2026-0127', 'Ownership Declaration',
        DocumentStatus.verified, received: -5, pages: 1, size: '220 KB'),
    _DocSeed('DOC-0127-2', 'LA-TN-CBE-2026-0127', 'Possession Notice',
        DocumentStatus.pending, received: -1, pages: 2, size: '310 KB'),
    _DocSeed('DOC-0112-1', 'LA-TN-CBE-2026-0112', 'R&R Record',
        DocumentStatus.pending, received: -3, pages: 5, size: '980 KB'),
    _DocSeed('DOC-0119-1', 'LA-TN-CBE-2026-0119', 'Crop Loss Certificate',
        DocumentStatus.notAvailable, pages: null, size: '—'),
    _DocSeed('DOC-0119-2', 'LA-TN-CBE-2026-0119', 'Drainage Alignment Plan',
        DocumentStatus.pendingReview, received: -7, pages: 2, size: '1.4 MB'),
    _DocSeed('DOC-0115-1', 'LA-TN-CBE-2026-0115', 'Land Acquisition Award',
        DocumentStatus.verified, received: -10, pages: 8, size: '1.9 MB'),
    _DocSeed('DOC-0103-1', 'LA-TN-CBE-2026-0103', 'Project Notification Gazette',
        DocumentStatus.verified, received: -28, pages: 4, size: '670 KB'),
    _DocSeed('DOC-0131-1', 'LA-TN-CBE-2026-0131', 'Canal Alignment Drawing',
        DocumentStatus.pendingReview, received: -4, pages: 2, size: '820 KB'),
  ];

  return [
    for (final s in seeds)
      CaseDocument(
        id: s.id,
        caseNo: s.caseNo,
        name: s.name,
        type: 'PDF',
        status: s.status,
        receivedOn: s.received == null ? null : day(s.received!),
        sizeLabel: s.size,
        pages: s.pages,
      ),
  ];
}

class _DocSeed {
  const _DocSeed(
    this.id,
    this.caseNo,
    this.name,
    this.status, {
    this.received,
    this.pages,
    this.size = '—',
  });

  final String id;
  final String caseNo;
  final String name;
  final DocumentStatus status;
  final int? received;
  final int? pages;
  final String size;
}
