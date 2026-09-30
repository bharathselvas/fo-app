import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../core/network/connectivity_service.dart';
import '../../widgets/status_widgets.dart';
import '../auth/auth_providers.dart';
import 'profile_screen.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  late final _urlCtrl = TextEditingController(text: ApiConfig.baseUrl);

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.badge)),
              title: Text(user.name),
              subtitle: Text('${user.email}\n${user.designation} · ${user.role}'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ProfileScreen.open(context),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              subtitle: const Text('Posting, jurisdiction, contact and device status'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ProfileScreen.open(context),
            ),
          ),
          const SizedBox(height: 16),
          const Text('API', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _urlCtrl,
                    enabled: !ApiConfig.mockMode,
                    decoration: InputDecoration(
                      labelText: 'Backend base URL',
                      hintText: ApiConfig.mockMode
                          ? 'Mock mode — URL ignored'
                          : 'http://10.0.2.2:3002/api',
                      helperText: ApiConfig.mockMode
                          ? 'Demo data mode — rebuild with --dart-define=MOCK_API=false to use a real server.'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: ApiConfig.mockMode
                        ? null
                        : () async {
                            await ApiConfig.setBaseUrl(_urlCtrl.text);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Base URL saved')),
                              );
                            }
                          },
                    child: const Text('Save URL'),
                  ),
                ],
              ),
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 16),
            const Text('DEVELOPMENT', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                title: const Text('Simulate OFFLINE'),
                subtitle: const Text('Forces connection OFFLINE only. Sync architecture unchanged.'),
                value: ApiConfig.devForceOffline,
                onChanged: (v) async {
                  await ApiConfig.setDevForceOffline(v);
                  await ref.read(connectivityServiceProvider).refresh();
                  setState(() {});
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          const StatusChip(label: 'Bhoomi Setu Field Officer', color: Colors.indigo),
        ],
      ),
    );
  }
}
