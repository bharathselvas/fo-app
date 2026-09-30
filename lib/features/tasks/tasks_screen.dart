import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/case_task.dart';
import '../../data/models/enums.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import 'task_card.dart';

enum _TaskFilter { all, pending, inProgress, overdue, completed }

/// All assigned tasks with status filters (reachable from the dashboard and
/// from every case dossier).
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasksScreen()));
  }

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  _TaskFilter _filter = _TaskFilter.all;

  static const _filters = <_TaskFilter, String>{
    _TaskFilter.all: 'ALL',
    _TaskFilter.pending: 'PENDING',
    _TaskFilter.inProgress: 'IN PROGRESS',
    _TaskFilter.overdue: 'OVERDUE',
    _TaskFilter.completed: 'COMPLETED',
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

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$openCount OPEN · ${tasks.length} TOTAL',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[700],
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final f in _TaskFilter.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: ChoiceChip(
                      label: Text(_filters[f]!),
                      selected: _filter == f,
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
                    title: 'No Tasks Here',
                    message: _filter == _TaskFilter.all
                        ? 'No tasks are assigned to you right now.'
                        : 'No tasks match the ${_filters[_filter]!.toLowerCase()} filter.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: visible.length,
                    itemBuilder: (_, i) => TaskCard(task: visible[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
