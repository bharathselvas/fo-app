import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/case_task.dart';
import '../../data/models/enums.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/screen_header.dart';
import 'task_card.dart';

enum _TaskFilter { all, pending, inProgress, overdue, completed }

/// All assigned tasks with status filters (reachable from the dashboard and
/// from every case dossier).
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(AppRoutes.fadeUp(const TasksScreen()));
  }

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  _TaskFilter _filter = _TaskFilter.all;

  static const _filters = <_TaskFilter, ({String label, Color color, IconData icon})>{
    _TaskFilter.all: (label: 'ALL', color: AppColors.neutral, icon: Icons.list_alt),
    _TaskFilter.pending: (
      label: 'PENDING',
      color: AppColors.warning,
      icon: Icons.schedule
    ),
    _TaskFilter.inProgress: (
      label: 'IN PROGRESS',
      color: AppColors.info,
      icon: Icons.play_circle
    ),
    _TaskFilter.overdue: (
      label: 'OVERDUE',
      color: AppColors.danger,
      icon: Icons.warning_amber
    ),
    _TaskFilter.completed: (
      label: 'COMPLETED',
      color: AppColors.success,
      icon: Icons.check_circle
    ),
  };

  List<CaseTask> _apply(List<CaseTask> tasks) {
    final list = switch (_filter) {
      _TaskFilter.all => [...tasks],
      _TaskFilter.pending => tasks.where((t) => t.status == TaskStatus.pending).toList(),
      _TaskFilter.inProgress =>
        tasks.where((t) => t.status == TaskStatus.inProgress).toList(),
      _TaskFilter.overdue =>
        tasks.where((t) => t.status != TaskStatus.completed && t.isOverdue).toList(),
      _TaskFilter.completed =>
        tasks.where((t) => t.status == TaskStatus.completed).toList(),
    };
    list.sort((a, b) {
      final aDone = a.status == TaskStatus.completed;
      final bDone = b.status == TaskStatus.completed;
      if (aDone != bDone) return aDone ? 1 : -1;
      final byDue = a.dueDate.compareTo(b.dueDate);
      return byDue != 0 ? byDue : a.priority.rank.compareTo(b.priority.rank);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(foStateProvider).tasks;
    final visible = _apply(tasks);
    final openCount = tasks.where((t) => t.status != TaskStatus.completed).length;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 34),
        child: ScreenHeader(
          title: 'Tasks',
          subtitle: '$openCount open · ${tasks.length} total',
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.sm),
              children: [
                for (final f in _TaskFilter.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_filters[f]!.label),
                      selected: _filter == f,
                      avatar: Icon(
                        _filters[f]!.icon,
                        size: 15,
                        color: _filter == f
                            ? _filters[f]!.color
                            : _filters[f]!.color.withValues(alpha: 0.45),
                      ),
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? EmptyState(
                    icon: Icons.task_alt,
                    title: _filter == _TaskFilter.all
                        ? 'No Tasks Assigned'
                        : 'No ${_filters[_filter]!.label} Tasks',
                    message: _filter == _TaskFilter.all
                        ? 'No tasks are assigned to you right now.'
                        : 'Nothing matches the ${_filters[_filter]!.label.toLowerCase()} '
                            'filter. Try another.',
                  )
                : ListView.builder(
                    key: const PageStorageKey('tasks-list'),
                    padding: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.xxl),
                    itemCount: visible.length,
                    itemBuilder: (_, i) => Padding(
                      key: ValueKey(visible[i].id),
                      padding: const EdgeInsets.only(bottom: Insets.md),
                      child: TaskCard(task: visible[i]),
                    ),
                  ),
          ),
          // Counts read at a glance without stealing a full card.
          Material(
            color: AppColors.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Insets.lg,
                  vertical: Insets.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SHOWING ${visible.length} OF ${tasks.length}',
                      style: theme.textTheme.labelSmall,
                    ),
                    Text(
                      _filters[_filter]!.label,
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: _filters[_filter]!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
