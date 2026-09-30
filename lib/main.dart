import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/api_config.dart';
import 'core/network/connectivity_service.dart';
import 'core/sync/wiring.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_providers.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load();
  runApp(const ProviderScope(child: BhoomiSetuApp()));
}

class BhoomiSetuApp extends ConsumerStatefulWidget {
  const BhoomiSetuApp({super.key});

  @override
  ConsumerState<BhoomiSetuApp> createState() => _BhoomiSetuAppState();
}

class _BhoomiSetuAppState extends ConsumerState<BhoomiSetuApp> {
  bool _wired = false;

  @override
  void initState() {
    super.initState();
    // Wire sync after first frame when providers available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_wired && mounted) {
        wireDependencies(ProviderScope.containerOf(context, listen: false));
        _wired = true;
        ref.read(connectivityServiceProvider).start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(signedInProvider);

    return MaterialApp(
      title: 'Bhoomi Setu FO',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: signedIn ? const HomeShell() : const LoginScreen(),
    );
  }
}
