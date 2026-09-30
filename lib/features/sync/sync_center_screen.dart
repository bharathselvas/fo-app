import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/sync/retry_policy.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../../widgets/screen_header.dart';
import '../auth/auth_providers.dart';
import '../cases/case_detail_screen.dart';
import '../field_visit/field_visit_controller.dart';

final _syncTick = StateProvider<int>((_) => 0);

class _SyncData {
  const _SyncData(this.visits, this.queue);
  final List<FieldVisit> visits;
  final List<SyncQueue> queue;
}

/// Live visits + queue rows, so the screen reflects a sync run the moment the
/// engine writes rather than only when the tick is bumped.
final _syncDataProvider = StreamProvider.autoDispose<_SyncData>((ref) async* {
  final db = ref.watch(dbProvider);
  ref.watch(_syncTick);
  final visits = db.select(db.fieldVisits).watch();
  final queue = db.select(db.syncQueues).watch();
  await for (final v in visits) {
    yield _SyncData(v, await queue.first);
  }
});

class SyncCenterScreen extends ConsumerWidget {
  const SyncCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_syncTick);
    final status = ref.watch(connectionProvider).valueOrNull ?? ConnectionStatus.offline;
    final data = ref.watch(_syncDataProvider);

    return Column(
      children: [
        ScreenHeader(
          title: 'Sync Center',
          subtitle: data.valueOrNull == null
              ? 'Reading local queue…'
              : '${data.valueOrNull!.visits.length} visit'
                  '${data.valueOrNull!.visits.length == 1 ? '' : 's'} on device',
        ),
        Expanded(
          child: data.when(
            loading: () => const LoadingState(label: 'Reading local queue…'),
            error: (e, _) => EmptyState(
              icon: Icons.error_outline,
              tone: EmptyTone.danger,
              title: 'Sync Data Unavailable',
              message: 'The local queue could not be read: $e',
            ),
            data: (d) => _SyncBody(status: status, visits: d.visits, queue: d.queue),
          ),
        ),
      ],
    );
  }
}

class _SyncBody extends ConsumerWidget {
  const _SyncBody({
    required this.status,
    required this.visits,
    required this.queue,
  });

  final ConnectionStatus status;
  final List<FieldVisit> visits;
  final List<SyncQueue> queue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = queue.where((q) => q.status != 'DONE').length;
    final failedRows = queue.where((q) => q.status == 'FAILED').toList();
    final syncedVisits = visits.where((v) => v.status == 'SYNCED').length;
    final waiting = visits
        .where((v) => v.status == 'PENDING_SYNC' || v.status == 'SYNCING')
        .length;
    final failedVisits = visits.where((v) => v.status == 'SYNC_FAILED').length;
    final theme = Theme.of(context);

    final (color, label, icon) = switch (status) {
      ConnectionStatus.online => (AppColors.success, 'Online', Icons.cloud_done_outlined),
      ConnectionStatus.offline => (AppColors.danger, 'Offline', Icons.cloud_off_outlined),
      ConnectionStatus.syncing => (AppColors.warning, 'Syncing', Icons.cloud_sync_outlined),
      ConnectionStatus.serverUnavailable => (
          AppColors.serverDown,
          'Server unavailable',
          Icons.cloud_off_outlined
        ),
    };

    return RefreshIndicator(
      onRefresh: () async => ref.read(connectivityServiceProvider).refresh(),
      child: ListView.builder(
        key: const PageStorageKey('sync-list'),
        padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, Insets.xxl),
        // The visit list grows without bound over a field officer's career and
        // used to be built eagerly with `...visits.map(...)` inside a
        // `ListView(children:)`, so every expansion tile — each holding a Card
        // with nested buttons — was constructed on each scroll.
        itemCount: 1 + 1 + 1 + (visits.isEmpty ? 1 : visits.length) +
            (failedRows.isEmpty ? 0 : 2),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _connectionCard(
              context: context,
              color: color,
              label: label,
              icon: icon,
              waiting: waiting,
              synced: syncedVisits,
              failed: failedVisits,
              pendingQueue: pending,
              parked: failedRows.length,
            );
          }
          if (index == 1) {
            return Padding(
              padding: const EdgeInsets.only(top: Insets.md, bottom: Insets.md),
              child: _SyncNowButton(
                enabled: status == ConnectionStatus.online,
                onPressed: () => _runSync(context, ref),
              ),
            );
          }
          if (index == 2) {
            if (status == ConnectionStatus.online) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: Insets.lg),
              child: AppBanner(
                tone: status == ConnectionStatus.serverUnavailable
                    ? AppBannerTone.warning
                    : AppBannerTone.danger,
                icon: Icons.cloud_off_outlined,
                message: status == ConnectionStatus.serverUnavailable
                    ? 'The server is not responding. Field data is safe on this '
                        'device and will upload automatically once it recovers.'
                    : 'You are offline. Field data is safe on this device and will '
                        'upload automatically once you reconnect.',
              ),
            );
          }

          final visitIndex = index - 3;
          if (visits.isEmpty) {
            return const EmptyState(
              icon: Icons.assignment_turned_in_outlined,
              title: 'No Field Visits Yet',
              message: 'Submit a field verification and it will appear here with its '
                  'sync status and upload queue.',
            );
          }
          if (visitIndex < visits.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Insets.sm),
              child: _visitCard(context, ref, visits[visitIndex]),
            );
          }

          // Remaining rows are the parked-queue card.
          return Padding(
            padding: const EdgeInsets.only(top: Insets.lg),
            child: SectionCard(
              title: 'Retry schedule',
              icon: Icons.history,
              children: [
                for (final q in failedRows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Insets.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${q.operation} · ${q.entityId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          _retryHint(q),
                          style: theme.textTheme.labelSmall!
                              .copyWith(color: AppColors.serverDown),
                        ),
                      ],
                    ),
                  ),
                const Gap(Insets.sm),
                Text(
                  'Backoff schedule: ${kRetryBackoffSeconds.join('s, ')}s · parked '
                  'permanently after $kMaxRetries attempts. Data stays on this device.',
                  style: theme.textTheme.bodySmall!.copyWith(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _connectionCard({
    required BuildContext context,
    required Color color,
    required String label,
    required IconData icon,
    required int waiting,
    required int synced,
    required int failed,
    required int pendingQueue,
    required int parked,
  }) {
    return SectionCard(
      title: 'Connection',
      icon: icon,
      trailing: AppChip(label: label, color: color, uppercase: false),
      children: [
        Row(
          children: [
            // Reuses the shared StatTile rather than a second, slightly
            // different copy of the same widget.
            StatTile(value: '$waiting', label: 'Pending', color: AppColors.warning),
            const Gap(Insets.sm, horizontal: true),
            StatTile(value: '$synced', label: 'Synced', color: AppColors.success),
            const Gap(Insets.sm, horizontal: true),
            StatTile(
              value: '$failed',
              label: 'Failed',
              color: AppColors.danger,
              emphasise: failed > 0,
            ),
          ],
        ),
        const Gap(Insets.md),
        Text(
          'Queue items: $pendingQueue waiting · $parked parked',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _visitCard(BuildContext context, WidgetRef ref, FieldVisit v) {
    final st = v.status;
    final theme = Theme.of(context);
    final (chipLabel, chipColor, chipIcon) = switch (st) {
      'SYNCED' => ('Synced', AppColors.success, Icons.check_circle),
      'PENDING_SYNC' => ('Waiting', AppColors.warning, Icons.schedule),
      'SYNCING' => ('Uploading', AppColors.info, Icons.upload),
      'SYNC_FAILED' => ('Failed', AppColors.danger, Icons.error_outline),
      _ => (st, AppColors.neutral, Icons.help_outline),
    };
    final serverChanged = (v.lastError ?? '').contains('SERVER_DATA_CHANGED');

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.xs),
        childrenPadding: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.lg),
        title: Text(
          v.caseId.isEmpty ? v.id : v.caseId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium!.copyWith(fontSize: 14),
        ),
        subtitle: Text(st, style: theme.textTheme.bodySmall!.copyWith(fontSize: 12)),
        trailing: AppChip(
          label: chipLabel,
          color: chipColor,
          icon: chipIcon,
          dense: true,
          uppercase: false,
        ),
        children: [
          if (st == 'SYNC_FAILED' || v.lastError != null) ...[
            AppBanner(
              tone: AppBannerTone.danger,
              title: 'Sync failed',
              message: 'Reason: ${v.lastError ?? 'Server unavailable'}\n'
                  'Retry count: ${v.retryCount} of $kMaxRetries\n'
                  'Local data: safe on this device.',
            ),
            const Gap(Insets.md),
            OutlinedButton.icon(
              onPressed: status == ConnectionStatus.online
                  ? () => _runSync(context, ref)
                  : null,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('RETRY NOW'),
            ),
          ],
          if (serverChanged) ...[
            const Gap(Insets.md),
            AppBanner(
              tone: AppBannerTone.warning,
              title: 'Server data changed',
              message: 'Your field data is safely stored on this device. '
                  'This case requires review before submission.',
            ),
            const Gap(Insets.md),
            OutlinedButton.icon(
              onPressed: v.caseId.isEmpty
                  ? null
                  : () => CaseDetailScreen.open(context, caseNo: v.caseId),
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('REVIEW CASE'),
            ),
          ] else if (st != 'SYNC_FAILED' && v.caseId.isNotEmpty) ...[
            const Gap(Insets.md),
            OutlinedButton.icon(
              onPressed: () => CaseDetailScreen.open(context, caseNo: v.caseId),
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('OPEN CASE'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _runSync(BuildContext context, WidgetRef ref) async {
    ref.read(connectivityServiceProvider).markSyncing();
    final result = await ref.read(syncEngineProvider).runNow();
    // Anything the engine uploaded is now also synced from the dossier's view.
    ref.read(foStateProvider.notifier).markUploadsComplete();
    ref.read(_syncTick.notifier).state++;
    if (!context.mounted) return;

    final message = switch (result) {
      SyncResult(synced: 0, failed: 0) when !result.success =>
        'Offline — your field data is safe on this device and will upload '
            'automatically when you reconnect.',
      SyncResult(synced: 0, failed: 0) =>
        'Nothing to sync — every record is already on the server.',
      SyncResult(failed: final f) when f > 0 =>
        '${result.synced} synced, $f still pending. They stay on this device and '
            'retry automatically.',
      _ => '${result.synced} field record${result.synced == 1 ? '' : 's'} '
          'uploaded successfully.',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String _retryHint(SyncQueue q) {
    final wait = retryWait(
      retryCount: q.retryCount,
      lastAttemptAt: q.updatedAt,
      now: DateTime.now().toUtc(),
    );
    if (wait == null) return 'RETRY DUE';
    if (wait.inSeconds < 60) return 'RETRY IN ${wait.inSeconds}s';
    return 'RETRY IN ${(wait.inSeconds / 60).ceil()}m';
  }
}

/// SYNC NOW with an in-button progress state, so a long upload does not look
/// like a dead button.
class _SyncNowButton extends StatefulWidget {
  const _SyncNowButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_SyncNowButton> createState() => _SyncNowButtonState();
}

class _SyncNowButtonState extends State<_SyncNowButton> {
  bool _busy = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: widget.enabled && !_busy ? widget.onPressed : null,
      child: FilledButton.icon(
        onPressed: widget.enabled && !_busy
            ? () {
                setState(() => _busy = true);
                widget.onPressed();
                _reset?.cancel();
                _reset = Timer(const Duration(milliseconds: 1200), () {
                  if (mounted) setState(() => _busy = false);
                });
              }
            : null,
        icon: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.sync, size: 18),
        label: Text(_busy ? 'SYNCING…' : 'SYNC NOW'),
      ),
    );
  }
}
