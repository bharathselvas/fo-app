import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  ConnectionStatus _status = ConnectionStatus.offline;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final service = ref.read(connectivityServiceProvider);
    await service.refresh();
    if (mounted) setState(() => _status = service.status);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = ref.read(sessionServiceProvider);
      final result = await session.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      ref.read(currentUserProvider.notifier).state = result.user;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome, ${result.user.name}')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _statusLabel => switch (_status) {
        ConnectionStatus.online => 'Online',
        ConnectionStatus.offline => 'Offline',
        ConnectionStatus.syncing => 'Syncing',
        ConnectionStatus.serverUnavailable => 'Server unavailable',
      };

  Color get _statusColor => switch (_status) {
        ConnectionStatus.online => Colors.green,
        ConnectionStatus.offline => Colors.red,
        ConnectionStatus.syncing => Colors.orange,
        ConnectionStatus.serverUnavailable => Colors.deepOrange,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
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
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(
                            labelText: 'Officer ID',
                            hintText: 'fo.perur@tn.gov.in',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Enter Officer ID' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          onFieldSubmitted: (_) => _signIn(),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Enter password' : null,
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _signIn,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('SIGN IN'),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(_statusLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Demo: fo.perur@tn.gov.in / demo123',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
