import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../../widgets/screen_header.dart';
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
    final theme = Theme.of(context);
    final initials = user.name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join();

    return Column(
      children: [
        const ScreenHeader(title: 'More'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, Insets.xxl),
            children: [
              TappableCard(
                onTap: () => ProfileScreen.open(context),
                padding: const EdgeInsets.all(Insets.lg),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.brandBright, AppColors.brand],
                        ),
                        borderRadius: Radii.mdAll,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials.isEmpty ? '?' : initials,
                        style: theme.textTheme.titleMedium!.copyWith(color: Colors.white),
                      ),
                    ),
                    const Gap(Insets.md, horizontal: true),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          const Gap(2),
                          Text(
                            '${user.designation} · ${user.role}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                  ],
                ),
              ),
              const Gap(Insets.lg),
              SectionCard(
                title: 'Account',
                icon: Icons.person_outline,
                children: [
                  _SettingsRow(
                    icon: Icons.badge_outlined,
                    label: 'My profile',
                    detail: 'Posting, jurisdiction, contact and device status',
                    onTap: () => ProfileScreen.open(context),
                  ),
                ],
              ),
              const Gap(Insets.lg),
              SectionCard(
                title: 'Backend',
                icon: Icons.dns_outlined,
                children: [
                  TextField(
                    controller: _urlCtrl,
                    enabled: !ApiConfig.mockMode,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'Backend base URL',
                      hintText: ApiConfig.mockMode
                          ? 'Mock mode — URL ignored'
                          : 'http://10.0.2.2:3002/api',
                      helperText: ApiConfig.mockMode
                          ? 'Demo data mode — rebuild with '
                              '--dart-define=MOCK_API=false to use a real server.'
                          : null,
                      helperMaxLines: 3,
                    ),
                  ),
                  const Gap(Insets.md),
                  OutlinedButton.icon(
                    onPressed: ApiConfig.mockMode
                        ? null
                        : () async {
                            await ApiConfig.setBaseUrl(_urlCtrl.text);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(content: Text('Base URL saved')),
                              );
                          },
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save URL'),
                  ),
                ],
              ),
              if (kDebugMode) ...[
                const Gap(Insets.lg),
                SectionCard(
                  title: 'Development',
                  icon: Icons.developer_mode,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: ApiConfig.devForceOffline,
                      title: const Text('Simulate offline'),
                      subtitle: const Text(
                        'Forces connection OFFLINE only. Sync architecture unchanged.',
                      ),
                      onChanged: (v) async {
                        await ApiConfig.setDevForceOffline(v);
                        await ref.read(connectivityServiceProvider).refresh();
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ],
              const Gap(Insets.xxl),
              Center(
                child: Text(
                  'Terranex Field Officer · v1.0.0',
                  style: theme.textTheme.bodySmall!.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PressScale(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.neutralSoft,
              borderRadius: Radii.smAll,
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const Gap(Insets.md, horizontal: true),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleMedium!.copyWith(fontSize: 14)),
                const Gap(1),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall!.copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
