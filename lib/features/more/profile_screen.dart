import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_routes.dart';
import '../../core/theme/tokens.dart';
import '../../services/fo_providers.dart';
import '../../widgets/common.dart';
import '../../widgets/screen_header.dart';
import '../auth/auth_providers.dart';

/// Officer profile: identity, jurisdiction, device/offline status.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(AppRoutes.fadeUp(const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officer = ref.watch(currentUserProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final pending = ref.watch(pendingSyncCountProvider);
    final conn = ref.watch(connectionProvider).valueOrNull;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 34),
        child: ScreenHeader(
          title: 'Profile',
          subtitle: officer.officerId,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, Insets.xxl),
        children: [
          _identityCard(context, officer.initials, officer.name,
              '${officer.designation} · ${officer.role}'),
          const Gap(Insets.lg),
          SectionCard(
            title: 'Posting & jurisdiction',
            icon: Icons.apartment_outlined,
            children: [
              InfoRow(label: 'Department', value: officer.department),
              InfoRow(label: 'Office', value: officer.office),
              InfoRow(label: 'District', value: officer.district, highlight: true),
              InfoRow(label: 'State', value: officer.state),
              InfoRow(label: 'Assigned area', value: officer.assignedArea),
            ],
          ),
          const Gap(Insets.lg),
          SectionCard(
            title: 'Contact',
            icon: Icons.contact_phone_outlined,
            children: [
              InfoRow(label: 'Phone', value: officer.phone),
              InfoRow(label: 'Email', value: officer.email),
            ],
          ),
          const Gap(Insets.lg),
          SectionCard(
            title: 'Device & offline',
            icon: Icons.smartphone_outlined,
            children: [
              InfoRow(label: 'Records pending sync', value: '$pending', highlight: true),
              InfoRow(
                label: 'Connection',
                value: conn == null ? 'Checking…' : conn.name.toUpperCase(),
              ),
              InfoRow(
                label: 'Data source',
                value: ApiConfig.mockMode ? 'Prototype demo data' : 'Server API',
              ),
            ],
          ),
          const Gap(Insets.lg),
          SectionCard(
            title: 'My work',
            icon: Icons.work_outline,
            children: [
              Row(
                children: [
                  StatTile(
                    value: '${stats.assignedCases}',
                    label: 'Cases',
                    color: AppColors.info,
                  ),
                  const Gap(Insets.sm, horizontal: true),
                  StatTile(
                    value: '${stats.completed}',
                    label: 'Completed',
                    color: AppColors.success,
                  ),
                  const Gap(Insets.sm, horizontal: true),
                  StatTile(
                    value: '${stats.openTasks}',
                    label: 'Open tasks',
                    color: AppColors.warning,
                  ),
                ],
              ),
              const Gap(Insets.sm),
              InfoRow(
                label: 'Pending verification',
                value: '${stats.pendingVerification}',
              ),
            ],
          ),
          const Gap(Insets.xxl),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () => _confirmSignOut(context, ref),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('SIGN OUT'),
          ),
          const Gap(Insets.md),
          Center(
            child: Text(
              'Terranex · Field Officer',
              style: theme.textTheme.bodySmall!.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _identityCard(
    BuildContext context,
    String initials,
    String name,
    String role,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Insets.lg),
      decoration: BoxDecoration(
        borderRadius: Radii.lgAll,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandShadow, AppColors.brand, AppColors.brandBright],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: theme.textTheme.headlineSmall!.copyWith(color: Colors.white),
            ),
          ),
          const Gap(Insets.lg, horizontal: true),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
                ),
                const Gap(2),
                Text(
                  role,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sign-out only clears the session gate. Field data and the offline upload
  /// queue are deliberately kept on the device — they belong to the case file,
  /// not to the session, and must survive a sign-out.
  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final pending = ref.read(pendingSyncCountProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Sign out?'),
        content: Text(
          pending > 0
              ? '$pending field record${pending == 1 ? '' : 's'} are still waiting to '
                  'upload. They stay safe on this device and will upload the next '
                  'time you sign in.'
              : 'All field data has been uploaded. You can sign back in at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    // Drop the pushed routes first, otherwise the shell would still sit on the
    // stack behind the login screen.
    Navigator.of(context).popUntil((route) => route.isFirst);
    ref.read(signedInProvider.notifier).state = false;
  }
}
