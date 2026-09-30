import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/land_case.dart';
import '../../widgets/common.dart';
import '../../widgets/status_widgets.dart';
import 'case_detail_screen.dart';

/// One row of the case list: everything the officer needs at a glance.
class CaseCard extends StatelessWidget {
  const CaseCard({super.key, required this.caseData});

  final LandCase caseData;

  static final _dueFmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => CaseDetailScreen.open(context, caseNo: caseData.caseNo),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      caseData.caseNo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  PriorityChip(priority: caseData.priority, dense: true),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                caseData.projectName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${caseData.village} · ${caseData.taluk} · ${caseData.district}',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  CaseStatusChip(status: caseData.status, dense: true),
                  StatusChip(
                    label: caseData.stage.toUpperCase(),
                    color: Colors.indigo,
                    icon: Icons.flag_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.event, size: 15, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Due ${_dueFmt.format(caseData.dueDate)} · ${caseData.dueLabel}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: caseData.isOverdue
                            ? Colors.red.shade700
                            : Colors.grey[700],
                        fontWeight: caseData.isOverdue ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[500]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
