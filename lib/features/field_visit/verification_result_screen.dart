import 'package:flutter/material.dart';

import '../../widgets/common.dart';
import '../cases/case_detail_screen.dart';

/// Confirmation after the officer submits a field verification: what was
/// captured, where it went (local queue) and what happens next.
class VerificationResultScreen extends StatelessWidget {
  const VerificationResultScreen({
    super.key,
    required this.caseNo,
    required this.evidenceCount,
    required this.gpsCaptured,
    required this.gpsIsMock,
    required this.queuedOffline,
    required this.visitId,
  });

  final String caseNo;
  final int evidenceCount;
  final bool gpsCaptured;
  final bool gpsIsMock;
  final bool queuedOffline;
  final String visitId;

  void _openCase(BuildContext context) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    CaseDetailScreen.open(context, caseNo: caseNo);
  }

  void _toDashboard(BuildContext context) {
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Submitted')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          const Center(
            child: Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 76),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'FIELD VERIFICATION SUBMITTED',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              caseNo,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: 'SUBMISSION SUMMARY',
            icon: Icons.summarize_outlined,
            children: [
              InfoRow(label: 'Case', value: caseNo, highlight: true),
              InfoRow(label: 'Visit ID', value: visitId),
              InfoRow(label: 'Evidence files', value: '$evidenceCount'),
              InfoRow(
                label: 'GPS',
                value: gpsCaptured ? (gpsIsMock ? 'Tagged (demo fix)' : 'Locked') : 'Unavailable',
              ),
              InfoRow(label: 'Storage', value: queuedOffline ? 'On device (offline)' : 'Queued for sync'),
              InfoRow(label: 'Status', value: 'Awaiting Officer Review', highlight: true),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'WHAT HAPPENS NEXT',
            icon: Icons.route_outlined,
            children: [
              _step('1', 'Your record is saved on this device — no internet was required.'),
              _step('2', queuedOffline
                  ? 'It uploads automatically as soon as connectivity returns.'
                  : 'It syncs with the district server on the next queue run.'),
              _step('3', 'The District Authority reviews the verification and updates the case status.'),
              _step('4', 'Track progress from the case dossier timeline.'),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openCase(context),
            icon: const Icon(Icons.folder_open),
            label: const Text('VIEW CASE'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _toDashboard(context),
            icon: const Icon(Icons.home_outlined),
            label: const Text('BACK TO DASHBOARD'),
          ),
        ],
      ),
    );
  }

  Widget _step(String n, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: const Color(0xFF1B5E20),
            child: Text(n, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4, fontSize: 13.5))),
        ],
      ),
    );
  }
}
