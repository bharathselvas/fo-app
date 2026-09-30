import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../features/auth/auth_providers.dart';
import '../../widgets/status_widgets.dart';

/// The app's screen chrome, in one place.
///
/// There were three nested `Scaffolds` (one outer shell plus one per tab), so
/// safe-area insets were being applied twice and the connection banner was
/// rendered inside the body where it overlapped the first card of every screen.
/// Now there is exactly one `Scaffold` (owned by the shell) and every screen
/// uses this header.
class ScreenHeader extends ConsumerWidget implements PreferredSizeWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.actions = const [],
    this.subtitle,
    this.showConnectionBanner = true,
    this.leading,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showConnectionBanner;
  final Widget? leading;
  final Widget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (showConnectionBanner ? 34 : 0) + (bottom != null ? 4 : 0));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pending = ref.watch(pendingSyncCountProvider);

    return Material(
      color: AppColors.brand,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: kToolbarHeight,
              // Without an explicit IconTheme the back arrow inherits the
              // ambient default and reads dark-on-dark against the green bar.
              child: IconTheme.merge(
                data: const IconThemeData(
                  color: AppColors.textOnBrand,
                  size: 22,
                ),
                child: Row(
                children: [
                  if (leading != null)
                    leading!
                  else
                    const SizedBox(width: Insets.lg),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge!
                              .copyWith(color: AppColors.textOnBrand),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall!.copyWith(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ...actions,
                  const SizedBox(width: Insets.sm),
                ],
              ),
              ),
            ),
            ?bottom,
            if (showConnectionBanner) ConnectionBanner(pendingCount: pending),
          ],
        ),
      ),
    );
  }
}

/// Header for a screen whose title is a brand wordmark rather than a page name.
class BrandHeader extends ConsumerWidget implements PreferredSizeWidget {
  const BrandHeader({super.key, required this.actions, this.trailing});

  final List<Widget> actions;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.brand,
      child: SafeArea(
        bottom: false,
        child: IconTheme.merge(
          data: const IconThemeData(color: AppColors.textOnBrand, size: 22),
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                const SizedBox(width: Insets.lg),
                Text(
                  'TERRANEX',
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: AppColors.textOnBrand,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                ...actions,
                ?trailing,
                const SizedBox(width: Insets.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
