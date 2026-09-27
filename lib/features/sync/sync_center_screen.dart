import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import '../../widgets/status_widgets.dart';
import '../auth/auth_providers.dart';
import '../field_visit/field_visit_controller.dart';

final _syncTick = StateProvider<int>((_) => 0);

class SyncCenterScreen extends ConsumerWidget {
  const SyncCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_syncTick);
    final status = ref.watch(connectionProvider).valueOrNull ?? ConnectionStatus.offline;
    final db = ref.watch(dbProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SYNC CENTER')),
      body: FutureBuilder(
        future: () async {
          final visits = await db.select(db.fieldVisits).get();
          final queue = await db.select(db.syncQueues).get();
          return (visits, queue);
        }(),
        builder: (context, snap) {
          final visits = snap.data?.$1 ?? [];
          final queue = snap.data?.$2 ?? [];
          final pending = queue.where((q) => q.status == 'PENDING' || q.status == 'FAILED').length;
          final failed = queue.where((q) => q.status == 'FAILED').length;
          final syncedVisits = visits.where((v) => v.status == 'SYNCED').length;
          final waiting = visits.where((v) => v.status == 'PENDING_SYNC' || v.status == 'SYNCING').length;
          final failedVisits = visits.where((v) => v.status == 'SYNC_FAILED').length;

          final (color, label) = switch (status) {
            ConnectionStatus.online => (Colors.green.shade700, '🟢 Online'),
            ConnectionStatus.offline => (Colors.red.shade700, '🔴 Offline'),
            ConnectionStatus.syncing => (Colors.orange.shade800, '🟡 Syncing'),
            ConnectionStatus.serverUnavailable => (Colors.deepOrange.shade800, '🟠 Server unavailable'),
          };

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Connection', style: TextStyle(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          StatusChip(label: label, color: color),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          _stat('$waiting', 'Pending', Colors.orange),
                          _stat('$syncedVisits', 'Synced', Colors.green),
                          _stat('$failedVisits', 'Failed', Colors.red),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Queue items: $pending pending · $failed failed',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: status == ConnectionStatus.online
                    ? () async {
                        ref.read(connectivityServiceProvider).markSyncing();
                        await ref.read(syncEngineProvider).runNow();
                        ref.read(_syncTick.notifier).state++;
                      }
                    : null,
                icon: const Icon(Icons.sync),
                label: const Text('SYNC NOW'),
              ),
              const SizedBox(height: 16),
              const Text('VISITS', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
              const SizedBox(height: 8),
              if (visits.isEmpty) const Text('No field visits yet.'),
              ...visits.map((v) {
                final st = v.status;
                final chip = switch (st) {
                  'SYNCED' => StatusChip(label: '✓ Synced', color: Colors.green, icon: Icons.check),
                  'PENDING_SYNC' => StatusChip(label: '⏳ Waiting', color: Colors.orange, icon: Icons.schedule),
                  'SYNCING' => StatusChip(label: '↑ Uploading', color: Colors.blue, icon: Icons.upload),
                  'SYNC_FAILED' => StatusChip(label: '✗ Failed', color: Colors.red, icon: Icons.error),
                  _ => StatusChip(label: st, color: Colors.grey),
                };
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    title: Text(v.caseId.isEmpty ? v.id : v.caseId,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text(st, style: const TextStyle(fontSize: 12)),
                    trailing: chip,
                    children: [
                      if (st == 'SYNC_FAILED' || v.lastError != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SYNC FAILED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text('Reason:\n${v.lastError ?? 'Server unavailable'}'),
                              const SizedBox(height: 6),
                              Text('Retry count: ${v.retryCount}'),
                              const SizedBox(height: 6),
                              const Text('Local data: ✓ Safe',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                              const SizedBox(height: 10),
                              FilledButton(
                                onPressed: () async {
                                  await ref.read(syncEngineProvider).runNow();
                                  ref.read(_syncTick.notifier).state++;
                                },
                                child: const Text('RETRY NOW'),
                              ),
                            ],
                          ),
                        ),
                      if (st == 'SYNC_FAILED' && (v.lastError ?? '').contains('SERVER DATA CHANGED'))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('SERVER DATA CHANGED',
                                  style: TextStyle(fontWeight: FontWeight.w800, color: Colors.deepOrange)),
                              SizedBox(height: 6),
                              Text('Your field data is safely stored on this device.'),
                              Text('This case requires review before submission.'),
                              SizedBox(height: 8),
                              // REVIEW action opens case detail offline — placeholder button
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
