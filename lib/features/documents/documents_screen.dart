import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/case_document.dart';
import '../../data/models/enums.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/status_widgets.dart';
import 'document_preview_screen.dart';

enum _DocFilter { all, verified, pending, notAvailable }

/// Documents belonging to one case (or to the officer's whole file).
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key, this.caseNo});

  final String? caseNo;

  static void open(BuildContext context, {String? caseNo}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DocumentsScreen(caseNo: caseNo)),
    );
  }

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  _DocFilter _filter = _DocFilter.all;

  static final _dateFmt = DateFormat('d MMM yyyy');

  List<CaseDocument> _apply(List<CaseDocument> docs) => switch (_filter) {
        _DocFilter.all => docs,
        _DocFilter.verified =>
          docs.where((d) => d.status == DocumentStatus.verified).toList(),
        _DocFilter.pending => docs
            .where((d) =>
                d.status == DocumentStatus.pending ||
                d.status == DocumentStatus.pendingReview)
            .toList(),
        _DocFilter.notAvailable =>
          docs.where((d) => d.status == DocumentStatus.notAvailable).toList(),
      };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foStateProvider);
    final all = widget.caseNo == null
        ? state.documents
        : state.documentsFor(widget.caseNo!);
    final docs = _apply(all);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.caseNo == null ? 'Documents' : 'Documents · ${widget.caseNo}'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final (f, label) in const [
                  (_DocFilter.all, 'ALL'),
                  (_DocFilter.verified, 'VERIFIED'),
                  (_DocFilter.pending, 'PENDING'),
                  (_DocFilter.notAvailable, 'MISSING'),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: docs.isEmpty
                ? EmptyState(
                    icon: Icons.folder_open,
                    title: 'No Documents',
                    message: 'No documents match this filter yet.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final d = docs[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(Icons.description_outlined, size: 30),
                          title: Text(d.name,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            '${d.type} · ${d.receivedOn == null ? 'Not received' : _dateFmt.format(d.receivedOn!)}'
                            '${widget.caseNo == null ? ' · ${d.caseNo}' : ''}',
                            style: const TextStyle(fontSize: 12.5),
                          ),
                          trailing: StatusChip(label: d.status.label, color: d.status.color),
                          onTap: () => DocumentPreviewScreen.open(context, document: d),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
