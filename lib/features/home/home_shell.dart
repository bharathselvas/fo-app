import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import '../assignments/assignments_repository.dart';
import '../auth/auth_providers.dart';
import '../sync/sync_center_screen.dart';
import '../../widgets/status_widgets.dart';

import '../assignments/parcel_detail_screen.dart';
import '../map/parcel_map_screen.dart';
import '../more/more_screen.dart';

final _tabIndexProvider = StateProvider<int>((_) => 0);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(_tabIndexProvider);
    final user = ref.watch(currentUserProvider);

    final screens = [
      HomeDashboard(onOpenTab: (i) => ref.read(_tabIndexProvider.notifier).state = i),
      const TasksTab(),
      const MapTab(),
      const SyncCenterScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          ConnectionBanner(pendingCount: 0),
          Expanded(child: screens[tab]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (i) => ref.read(_tabIndexProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.sync_outlined), label: 'Sync'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
      floatingActionButton: tab == 0 && user != null
          ? null
          : null,
    );
  }
}

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key, required this.onOpenTab});

  final void Function(int) onOpenTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(assignmentsProvider);
    final conn = ref.watch(connectionProvider).valueOrNull ?? ConnectionStatus.offline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BHOOMI SETU'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: StatusChip(
                label: _connLabel(conn),
                color: _connColor(conn),
                icon: Icons.circle,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(assignmentsProvider);
          await ref.read(connectivityServiceProvider).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Field Operations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Officer: ${user?.email ?? '—'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (user?.jurisdictionDistrict != null)
                      Text(
                        'Jurisdiction: ${user!.jurisdictionDistrict}'
                        '${user.jurisdictionTehsil != null ? ' / ${user.jurisdictionTehsil}' : ''}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    const SizedBox(height: 12),
                    tasksAsync.when(
                      data: (tasks) {
                        final total = tasks.length;
                        return Row(
                          children: [
                            _stat(context, '$total', 'Assigned', Colors.indigo),
                            _stat(context, '$total', 'Pending', Colors.orange),
                            _stat(context, '0', 'Attention', Colors.red),
                          ],
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) => const Text('Could not load assignments'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'MY ASSIGNMENTS',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Colors.grey[800],
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.invalidate(assignmentsProvider),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No field assignments at this time')),
                    ),
                  );
                }
                return Column(
                  children: tasks.map((t) => _TaskCard(task: t)).toList(),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  String _connLabel(ConnectionStatus s) => switch (s) {
        ConnectionStatus.online => 'ONLINE',
        ConnectionStatus.offline => 'OFFLINE',
        ConnectionStatus.syncing => 'SYNCING',
        ConnectionStatus.serverUnavailable => 'SERVER DOWN',
      };

  Color _connColor(ConnectionStatus s) => switch (s) {
        ConnectionStatus.online => Colors.green.shade700,
        ConnectionStatus.offline => Colors.red.shade700,
        ConnectionStatus.syncing => Colors.orange.shade800,
        ConnectionStatus.serverUnavailable => Colors.deepOrange.shade800,
      };
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});

  final AssignedTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ParcelDetailScreen(task: task)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.caseNo,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text('Survey No. ${task.surveyNo}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${task.village}, ${task.district}',
                  style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 10),
              StatusChip(
                label: task.stage.replaceAll('_', ' ').toUpperCase(),
                color: Colors.indigo,
                icon: Icons.verified_outlined,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ParcelDetailScreen(task: task)),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('OPEN PARCEL'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TasksTab extends ConsumerWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(assignmentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: tasksAsync.when(
        data: (tasks) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (_, i) {
            final t = tasks[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(t.caseNo, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('Survey ${t.surveyNo} · ${t.village}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ParcelDetailScreen(task: t)),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class MapTab extends ConsumerWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(assignmentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('No parcels to display'));
          }
          return ParcelMapScreen(task: tasks.first, embedded: true);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
