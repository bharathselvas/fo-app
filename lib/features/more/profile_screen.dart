import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/status_widgets.dart';
import '../auth/auth_providers.dart';

/// Officer profile: identity, jurisdiction, device/offline status.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officer = ref.watch(currentUserProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final pending = ref.watch(pendingSyncCountProvider);
    final conn = ref.watch(connectionProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF1B5E20),
                    child: Text(
                      officer.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          officer.name,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${officer.designation} · ${officer.role}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 6),
                        StatusChip(label: officer.officerId, color: Colors.indigo),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'POSTING & JURISDICTION',
            icon: Icons.apartment_outlined,
            children: [
              InfoRow(label: 'Department', value: officer.department),
              InfoRow(label: 'Office', value: officer.office),
              InfoRow(label: 'District', value: officer.district, highlight: true),
              InfoRow(label: 'State', value: officer.state),
              InfoRow(label: 'Assigned area', value: officer.assignedArea),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'CONTACT',
            icon: Icons.contact_phone_outlined,
            children: [
              InfoRow(label: 'Phone', value: officer.phone),
              InfoRow(label: 'Email', value: officer.email),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'DEVICE & OFFLINE',
            icon: Icons.smartphone_outlined,
            children: [
              InfoRow(label: 'Records pending sync', value: '$pending', highlight: true),
              InfoRow(
                label: 'Connection',
                value: conn == null
                    ? 'Checking…'
                    : conn.name.toUpperCase(),
              ),
              InfoRow(
                label: 'Data source',
                value: ApiConfig.mockMode ? 'Prototype demo data' : 'Server API',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'MY WORK',
            icon: Icons.work_outline,
            children: [
              InfoRow(label: 'Assigned cases', value: '${stats.assignedCases}'),
              InfoRow(label: 'Pending verification', value: '${stats.pendingVerification}'),
              InfoRow(label: 'Completed', value: '${stats.completed}'),
              InfoRow(label: 'Open tasks', value: '${stats.openTasks}'),
            ],
          ),
          const SizedBox(height: 16),
          const Center(
            child: StatusChip(label: 'BHOOMI SETU · FIELD OFFICER', color: Colors.indigo),
          ),
        ],
      ),
    );
  }
}
