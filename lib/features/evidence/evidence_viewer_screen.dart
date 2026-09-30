import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/enums.dart';
import '../../data/models/evidence_record.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/evidence_thumb.dart';
import '../../widgets/status_widgets.dart';

/// Full-screen viewer for one piece of captured field evidence.
class EvidenceViewerScreen extends ConsumerWidget {
  const EvidenceViewerScreen({super.key, required this.recordId});

  final String recordId;

  static void open(BuildContext context, {required EvidenceRecord record}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EvidenceViewerScreen(recordId: record.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(foStateProvider).evidence.where((e) => e.id == recordId);
    final record = matches.isEmpty ? null : matches.first;

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Evidence')),
        body: const EmptyState(
          icon: Icons.photo_outlined,
          title: 'Evidence not found',
          message: 'This record is no longer attached to a case.',
        ),
      );
    }

    final captured = DateFormat('d MMM yyyy, h:mm a').format(record.capturedAt);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Evidence ${record.number}'),
        actions: [
          StatusChip(
            label: record.uploadStatus.label,
            color: record.uploadStatus.color,
            icon: record.uploadStatus.label == 'SYNCED' ? Icons.cloud_done : Icons.cloud_upload,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Hero(
              tag: 'evidence_${record.id}',
              child: record.hasPhoto
                  ? Image.file(
                      File(record.filePath!),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => EvidenceThumb(record: record),
                    )
                  : EvidenceThumb(record: record, fit: BoxFit.contain),
            ),
          ),
          Container(
            width: double.infinity,
            color: const Color(0xFF121212),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.type.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF81C784),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  record.caption,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 14),
                _meta(Icons.schedule, captured),
                if (record.latitude != null && record.longitude != null)
                  _meta(
                    Icons.location_on_outlined,
                    '${record.latitude!.toStringAsFixed(5)}, '
                    '${record.longitude!.toStringAsFixed(5)}'
                    '${record.accuracyMetres != null ? ' (±${record.accuracyMetres!.toStringAsFixed(0)} m)' : ''}',
                    highlight: record.gpsTagged,
                  ),
                _meta(Icons.folder_outlined, 'Case ${record.caseNo}'),
                if (record.officerId != null) _meta(Icons.badge_outlined, 'Officer ${record.officerId}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: highlight ? Colors.lightGreenAccent : Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: highlight ? Colors.lightGreenAccent : Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
