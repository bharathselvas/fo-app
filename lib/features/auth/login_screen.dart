import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../data/mock/mock_officer.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
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
  bool _obscure = true;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    // Brief pause so the button state reads as a real sign-in on device.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    ref.read(signedInProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(connectionProvider).valueOrNull ?? ConnectionStatus.offline;
    final officer = ref.read(foStateProvider).officer;
    final theme = Theme.of(context);

    final (statusLabel, statusColor) = switch (status) {
      ConnectionStatus.online => ('Online', AppColors.success),
      ConnectionStatus.offline => ('Offline — data saves on device', AppColors.danger),
      ConnectionStatus.syncing => ('Syncing', AppColors.warning),
      ConnectionStatus.serverUnavailable => ('Server unavailable', AppColors.serverDown),
    };

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.brand.withValues(alpha: 0.10),
              AppColors.canvas,
              AppColors.canvas,
            ],
            stops: const [0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(Insets.xl, Insets.xxl, Insets.xl, Insets.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _wordmark(context),
                      const Gap(Insets.xxl),
                      _officerCard(context, officer.name, officer.designation,
                          officer.department, '${officer.district} District, ${officer.state}'),
                      const Gap(Insets.xxl),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _idCtrl,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Officer ID',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Enter Officer ID' : null,
                          ),
                          const Gap(Insets.lg),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscure ? 'Show password' : 'Hide password',
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            onFieldSubmitted: (_) => _signIn(),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Enter password' : null,
                          ),
                          const Gap(Insets.lg),
                          PressScale(
                            onTap: _loading ? null : _signIn,
                            child: FilledButton(
                              onPressed: _loading ? null : _signIn,
                              child: _loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('SIGN IN'),
                            ),
                          ),
                        ],
                      ),
                      const Gap(Insets.xl),
                      const AppBanner(
                        message: 'Prototype build — works without a server. All case '
                            'data, GPS and evidence are demonstration data.',
                        icon: Icons.info_outline,
                        tone: AppBannerTone.neutral,
                      ),
                      const Gap(Insets.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StatusDot(color: statusColor, size: 8, ring: true),
                          const Gap(Insets.sm, horizontal: true),
                          Text(
                            statusLabel,
                            style: theme.textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wordmark(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.brandBright, AppColors.brandDeep],
            ),
            borderRadius: Radii.xlAll,
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.28),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.agriculture, size: 38, color: Colors.white),
        ),
        const Gap(Insets.lg),
        Text(
          'TERRANEX',
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall!.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
            color: AppColors.brand,
          ),
        ),
        const Gap(Insets.sm),
        Container(height: 3, width: 40, color: AppColors.brandBright),
        const Gap(Insets.md),
        Text(
          'National Land Acquisition\n& Management System',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _officerCard(
    BuildContext context,
    String name,
    String designation,
    String department,
    String location,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: Radii.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: AppColors.brand, size: 22),
          ),
          const Gap(Insets.md, horizontal: true),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.toUpperCase(), style: theme.textTheme.titleMedium),
                const Gap(2),
                Text(
                  '$designation · $department',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall!.copyWith(fontSize: 12.5),
                ),
                Text(location, style: theme.textTheme.bodySmall!.copyWith(fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
