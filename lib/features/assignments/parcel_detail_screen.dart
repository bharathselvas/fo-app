import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/status_widgets.dart';
import '../field_visit/wizard_screen.dart';
import '../map/parcel_map_screen.dart';
import 'assignments_repository.dart';

class ParcelDetailScreen extends ConsumerWidget {
  const ParcelDetailScreen({super.key, required this.task});

  final AssignedTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(task.caseNo)),
      body: ListView(
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
                      Expanded(
                        child: Text(
                          task.caseNo,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ),
                      StatusChip(
                        label: task.stage.replaceAll('_', ' ').toUpperCase(),
                        color: Colors.indigo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Survey No. ${task.surveyNo}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Divider(height: 24),
                  _row('Village', task.village),
                  _row('Taluk / Tehsil', task.tehsil),
                  _row('District', task.district),
                  _row('State', task.state),
                  _row('Area', '${task.areaHa} ha'),
                  _row('Case', task.caseNo),
                  if (task.ownerName != null) _row('Owner', task.ownerName!),
                  if (task.landType != null) _row('Land type', task.landType!),
                  _row('Status', task.status),
                  const SizedBox(height: 8),
                  const Text(
                    'Parcel geometry is authoritative from upstream ingestion. '
                    'Acquisition boundaries cannot be edited in this app.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ParcelMapScreen(task: task, embedded: true),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FieldVisitWizardScreen(task: task)),
              );
            },
            icon: const Icon(Icons.edit_note),
            label: const Text('START FIELD VISIT'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
