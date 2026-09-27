import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/connectivity_service.dart';
import '../features/auth/auth_providers.dart';

class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key, this.pendingCount = 0});

  final int pendingCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionProvider).valueOrNull ?? ConnectionStatus.offline;
    if (status == ConnectionStatus.online && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    final (color, label) = switch (status) {
      ConnectionStatus.online => (Colors.green.shade700, 'ONLINE'),
      ConnectionStatus.offline => (Colors.red.shade700, 'OFFLINE'),
      ConnectionStatus.syncing => (Colors.orange.shade800, 'SYNCING'),
      ConnectionStatus.serverUnavailable => (Colors.deepOrange.shade800, 'SERVER UNAVAILABLE'),
    };

    return Material(
      color: color,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                status == ConnectionStatus.online ? Icons.cloud_done : Icons.cloud_off,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status == ConnectionStatus.offline && pendingCount > 0
                      ? 'OFFLINE — $pendingCount visit${pendingCount == 1 ? '' : 's'} waiting for synchronization'
                      : label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
