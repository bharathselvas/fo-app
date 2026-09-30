import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import '../../data/mock/mock_officer.dart';
import '../../services/fo_providers.dart';
import 'auth_providers.dart';

/// Prototype sign-in.
///
/// Runs entirely offline: the credentials are pre-filled with the demo officer
/// and SIGN IN simply opens the app, so a judge can always get past this screen.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _idCtrl = TextEditingController(text: kMockFieldOfficer.officerId);
  late final _passwordCtrl = TextEditingController(text: 'demo123');
  bool _loading = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    // Brief pause so the button state reads as a real sign-in on device.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    ref.read(signedInProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final status =
        ref.watch(connectionProvider).valueOrNull ?? ConnectionStatus.offline;
    final officer = ref.read(foStateProvider).officer;

    final (statusLabel, statusColor) = switch (status) {
      ConnectionStatus.online => ('Online', Colors.green),
      ConnectionStatus.offline => ('Offline — data saves on device', Colors.red),
      ConnectionStatus.syncing => ('Syncing', Colors.orange),
      ConnectionStatus.serverUnavailable => ('Server unavailable', Colors.deepOrange),
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.agriculture, size: 64, color: Color(0xFF1B5E20)),
                    const SizedBox(height: 12),
                    Text(
                      'BHOOMI SETU',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: const Color(0xFF1B5E20),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Field Operations',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              officer.name.toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, letterSpacing: 0.6),
                            ),
                            const SizedBox(height: 4),
                            Text('${officer.designation} · ${officer.department}',
                                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                            Text('${officer.district} District, ${officer.state}',
                                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _idCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Officer ID',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter Officer ID' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      onFieldSubmitted: (_) => _signIn(),
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _loading ? null : _signIn,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('SIGN IN'),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blueGrey.shade100),
                      ),
                      child: const Text(
                        'Prototype build — works without a server. All case data, '
                        'GPS and evidence are demonstration data.',
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF37474F)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration:
                              BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(statusLabel,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
