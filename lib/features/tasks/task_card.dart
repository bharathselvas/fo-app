import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/case_task.dart';
import '../../data/models/enums.dart';
import '../../widgets/common.dart';
import '../../widgets/status_widgets.dart';
import '../cases/case_detail_screen.dart';

/// One actionable task card (dashboard + tasks screen).
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onOpenCase});

  final CaseTask task;
  final void Function(CaseTask task)? onOpenCase;

  static final _dateFmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final done = task.status == TaskStatus.completed;
    final overdue = !done && task.isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openCase(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.id,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Colors.grey[700],
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  PriorityChip(priority: task.priority, dense: true),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                task.title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Case ${task.caseNo}',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusChip(
                    label: task.status.label,
                    color: task.status.color,
                    icon: done
                        ? Icons.check_circle
                        : task.status == TaskStatus.inProgress
                            ? Icons.play_circle
                            : Icons.schedule,
                  ),
                  StatusChip(
                    label: task.slaLabel,
                    color: done
                        ? Colors.green.shade700
                        : overdue
                            ? Colors.red.shade700
                            : Colors.blueGrey,
                    icon: done
                        ? Icons.verified
                        : overdue
                            ? Icons.warning_amber
                            : Icons.timer_outlined,
                  ),
                  if (task.pendingFiles > 0)
                    StatusChip(
                      label: '${task.pendingFiles} FILES PENDING',
                      color: Colors.deepOrange,
                      icon: Icons.attach_file,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Assigned ${_dateFmt.format(task.assignedDate)} · '
                'Due ${_dateFmt.format(task.dueDate)}',
                style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _openCase(context),
                      child: const Text('VIEW CASE'),
                    ),
                  ),
                  if (!done) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _openCase(context, verify: true),
                        child: const Text('START'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCase(BuildContext context, {bool verify = false}) {
    if (onOpenCase != null) {
      onOpenCase!(task);
      return;
    }
    // Default: open the case detail (the verification entry point).
    CaseDetailScreen.open(context, caseNo: task.caseNo, startVerification: verify);
  }
}
