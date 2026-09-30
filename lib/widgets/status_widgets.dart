import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/connectivity_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/tokens.dart';
import '../features/auth/auth_providers.dart';
import 'common.dart';

/// Connection state strip.
///
/// Designed to live in `AppBar.bottom` rather than in the body. In the body it
/// overlapped the first card of every screen and added a second SafeArea inset
/// inside an already-inset column. Height is fixed so a status change can never
/// shift the page underneath.
class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key, this.pendingCount = 0});

  final int pendingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionProvider).valueOrNull ?? ConnectionStatus.offline;
    final theme = Theme.of(context);

    final (color, icon, label, pulse) = switch (status) {
      ConnectionStatus.online => pendingCount > 0
          ? (
              AppColors.warning,
              Icons.cloud_upload_outlined,
              'ONLINE — $pendingCount ITEM${pendingCount == 1 ? '' : 'S'} PENDING',
              false
            )
          : (AppColors.brand, Icons.cloud_done_outlined, 'ONLINE — SYNCED', true),
      ConnectionStatus.offline => (
          AppColors.danger,
          Icons.cloud_off_outlined,
          pendingCount > 0
              ? 'OFFLINE — $pendingCount ITEM${pendingCount == 1 ? '' : 'S'} PENDING'
              : 'OFFLINE — CHANGES SAVE ON THIS DEVICE',
          false
        ),
      ConnectionStatus.syncing => (
          AppColors.warning,
          Icons.cloud_sync_outlined,
          'SYNCING…',
          true
        ),
      ConnectionStatus.serverUnavailable => (
          AppColors.serverDown,
          Icons.cloud_off_outlined,
          'SERVER UNAVAILABLE — OFFLINE MODE',
          false
        ),
    };

    return Material(
      color: color,
      child: SizedBox(
        height: 34,
        child: Row(
          children: [
            const SizedBox(width: Insets.lg),
            Icon(icon, size: 15, color: Colors.white),
            const Gap(Insets.sm, horizontal: true),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall!.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            if (pulse)
              Padding(
                padding: const EdgeInsets.only(right: Insets.lg),
                child: StatusDot(color: Colors.white.withValues(alpha: 0.9), size: 6),
              ),
          ],
        ),
      ),
    );
  }
}

/// Generic status chip. Delegates to [AppChip] so there is one chip in the app.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => AppChip(
        label: label,
        color: color,
        icon: icon,
        uppercase: false,
      );
}
