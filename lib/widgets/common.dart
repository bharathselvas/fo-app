import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/tokens.dart';
import '../data/models/enums.dart';
import 'motion.dart';

/// A sized gap. Replaces the 41 bare `SizedBox(height: 16)` calls so vertical
/// rhythm comes from the scale rather than from whichever file it landed in.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key, this.horizontal = false});

  const Gap.xs({super.key, this.horizontal = false}) : size = Insets.xs;
  const Gap.sm({super.key, this.horizontal = false}) : size = Insets.sm;
  const Gap.md({super.key, this.horizontal = false}) : size = Insets.md;
  const Gap.lg({super.key, this.horizontal = false}) : size = Insets.lg;
  const Gap.xl({super.key, this.horizontal = false}) : size = Insets.xl;
  const Gap.xxl({super.key, this.horizontal = false}) : size = Insets.xxl;

  final double size;
  final bool horizontal;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: horizontal ? size : null,
        height: horizontal ? null : size,
      );
}

/// Card with a bold section header — used by every dossier section.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.icon,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: Insets.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: Radii.smAll,
                    ),
                    child: Icon(icon, size: 16, color: AppColors.brand),
                  ),
                  const Gap(Insets.md, horizontal: true),
                ],
                Expanded(
                  child: Text(title.toUpperCase(), style: theme.textTheme.labelSmall),
                ),
                ?trailing,
              ],
            ),
            const Gap(Insets.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Label / value row used across case, task and profile screens.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Layout.infoLabelWidth,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: DefaultTextStyle(
              style: (highlight
                      ? theme.textTheme.titleMedium!
                      : theme.textTheme.bodyLarge!)
                  .copyWith(
                color: highlight ? AppColors.brand : AppColors.textPrimary,
              ),
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }
}

/// Friendly replacement for "No data".
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.tone = EmptyTone.neutral,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final EmptyTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (tone) {
      EmptyTone.neutral => AppColors.textTertiary,
      EmptyTone.danger => AppColors.danger,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.xxl, horizontal: Insets.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const Gap(Insets.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const Gap(Insets.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          if (action != null) ...[const Gap(Insets.lg), action!],
        ],
      ),
    );
  }
}

/// Visual weight of an [EmptyState].
enum EmptyTone { neutral, danger }

/// Loading placeholder. Deliberately distinct from [EmptyState] — the wizard
/// previously rendered "No Structures Recorded" while its query was still in
/// flight, which reads as a data-integrity claim the app cannot support.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label, this.compact = false});

  final String? label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Insets.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            if (label != null) ...[
              const Gap(Insets.md, horizontal: true),
              Text(label!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.xxl, horizontal: Insets.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          if (label != null) ...[
            const Gap(Insets.lg),
            Text(label!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Placeholder block used while a list is loading. Gives the layout a shape to
/// hold so content does not jump when it lands. Static — the shimmer loop that
/// used to run here never stopped and drained battery behind the data.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.radius = Radii.sm,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Small labelled statistic used on the dashboard.
///
/// Note it no longer hardcodes its own `Expanded` — the previous version made
/// it unusable outside a `Row`.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
    this.flex = 1,
    this.emphasise = false,
  });

  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final int flex;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      flex: flex,
      child: PressScale(
        onTap: onTap,
        child: Material(
          color: emphasise ? color.withValues(alpha: 0.10) : AppColors.surface,
          borderRadius: Radii.mdAll,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: Radii.mdAll,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: Radii.mdAll,
                border: Border.all(
                  color: emphasise
                      ? color.withValues(alpha: 0.22)
                      : AppColors.border,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: Insets.md, horizontal: Insets.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall!.copyWith(
                      color: color,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Gap(2),
                  Text(
                    label.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall!.copyWith(
                      fontSize: 10.5,
                      letterSpacing: 0.4,
                      color: emphasise
                          ? color.withValues(alpha: 0.9)
                          : AppColors.textTertiary,
                    ),
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

/// The app's single chip.
///
/// Replaces three near-duplicates that had drifted apart: `CaseStatusChip`
/// (12% fill / 45% border), `PriorityChip` (solid fill, radius 6) and
/// `StatusChip` (12% fill / 40% border).
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dense = false,
    this.filled = false,
    this.uppercase = true,
    this.leading,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;
  final bool filled;
  final bool uppercase;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = uppercase ? label.toUpperCase() : label;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? Insets.sm : Insets.md,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.10),
        borderRadius: Radii.smAll,
        border: Border.all(
          color: filled ? color : color.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const Gap(Insets.xs, horizontal: true)],
          if (icon != null) ...[
            Icon(icon, size: dense ? 11 : 13, color: filled ? Colors.white : color),
            const Gap(Insets.xs, horizontal: true),
          ],
          Text(
            text,
            style: (dense ? theme.textTheme.labelSmall! : theme.textTheme.labelMedium!).copyWith(
              fontSize: dense ? 10 : 11.5,
              letterSpacing: 0.4,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip bound to a [CaseStatus].
class CaseStatusChip extends StatelessWidget {
  const CaseStatusChip({super.key, required this.status, this.dense = false});

  final CaseStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) => AppChip(
        label: status.label,
        color: status.color,
        dense: dense,
      );
}

/// Chip bound to a [CasePriority].
class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority, this.dense = false});

  final CasePriority priority;
  final bool dense;

  @override
  Widget build(BuildContext context) => AppChip(
        label: priority.label,
        color: priority.color,
        dense: dense,
        filled: true,
      );
}

/// Small filled dot used for unread markers and connection state.
///
/// Was hand-drawn three separate times at three different sizes.
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color, this.size = 8, this.ring = false});

  final Color color;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: ring ? Border.all(color: color.withValues(alpha: 0.28), width: 4) : null,
        ),
      );
}

/// Inline notice strip.
///
/// The same `Container` + `BoxDecoration` + `Border.all` shape was inlined at
/// seven call sites (login, parcel map x4, case detail x2, wizard x2) with
/// slightly different padding and colours each time.
class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
    required this.message,
    this.icon,
    this.tone = AppBannerTone.info,
    this.title,
    this.action,
    this.solid = false,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final AppBannerTone tone;
  final Widget? action;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (fg, bg) = switch (tone) {
      AppBannerTone.info => (AppColors.info, AppColors.infoSoft),
      AppBannerTone.warning => (AppColors.warningInk, AppColors.warningSoft),
      AppBannerTone.danger => (AppColors.danger, AppColors.dangerSoft),
      AppBannerTone.success => (AppColors.success, AppColors.successSoft),
      AppBannerTone.neutral => (AppColors.textSecondary, AppColors.neutralSoft),
    };

    return Container(
      padding: const EdgeInsets.all(Insets.md),
      decoration: BoxDecoration(
        color: solid ? fg : bg,
        borderRadius: Radii.mdAll,
        border: Border.all(
          color: solid ? fg : fg.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: solid ? Colors.white : fg),
            const Gap(Insets.md, horizontal: true),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!.toUpperCase(),
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: solid ? Colors.white : fg,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Gap(2),
                ],
                Text(
                  message,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: solid ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[const Gap(Insets.sm, horizontal: true), action!],
        ],
      ),
    );
  }
}

enum AppBannerTone { info, warning, danger, success, neutral }
