import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/case_document.dart';
import '../../data/models/enums.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/status_widgets.dart';

/// Document preview + review action (prototype renders a styled mock page —
/// no binary store yet).
class DocumentPreviewScreen extends ConsumerWidget {
  const DocumentPreviewScreen({super.key, required this.documentId});

  final String documentId;

  static void open(BuildContext context, {required CaseDocument document}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentPreviewScreen(documentId: document.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(foStateProvider).documents.where((d) => d.id == documentId);
    final doc = matches.isEmpty ? null : matches.first;

    if (doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Document')),
        body: const EmptyState(
          icon: Icons.description_outlined,
          title: 'Document not found',
          message: 'This document is no longer part of the case file.',
        ),
      );
    }

    final dateFmt = DateFormat('d MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Document')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      StatusChip(label: doc.status.label, color: doc.status.color),
                      StatusChip(label: doc.type.toUpperCase(), color: Colors.indigo),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  InfoRow(label: 'Case', value: doc.caseNo),
                  InfoRow(label: 'Document type', value: doc.type),
                  InfoRow(
                    label: 'Received on',
                    value: doc.receivedOn == null ? 'Not received' : dateFmt.format(doc.receivedOn!),
                  ),
                  InfoRow(label: 'Size', value: doc.sizeLabel),
                  if (doc.pages != null) InfoRow(label: 'Pages', value: '${doc.pages}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'PREVIEW',
            icon: Icons.menu_book_outlined,
            children: [
              AspectRatio(
                aspectRatio: 0.72,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: doc.status == DocumentStatus.notAvailable
                      ? const Center(
                          child: Text(
                            'This document has not been received yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.type.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(doc.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(doc.caseNo,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                            const Divider(height: 24),
                            for (var i = 0; i < 14; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  width: i.isEven ? 1 : 0.72,
                                ),
                              ),
                            const Spacer(),
                            const Text(
                              'Simulated preview — prototype has no binary document store.',
                              style: TextStyle(fontSize: 11, color: Colors.black45),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (doc.status != DocumentStatus.verified)
            FilledButton.icon(
              onPressed: () {
                ref.read(foStateProvider.notifier).setDocumentStatus(
                      doc.id,
                      DocumentStatus.verified,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${doc.name} marked as verified')),
                );
              },
              icon: const Icon(Icons.verified_outlined),
              label: const Text('MARK AS VERIFIED'),
            )
          else
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(foStateProvider.notifier)
                    .setDocumentStatus(doc.id, DocumentStatus.pendingReview);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${doc.name} moved back to review')),
                );
              },
              icon: const Icon(Icons.undo),
              label: const Text('MOVE BACK TO REVIEW'),
            ),
        ],
      ),
    );
  }
}
