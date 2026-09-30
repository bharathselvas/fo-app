import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/tokens.dart';

/// Scales a child's width/height on press-down.
///
/// The app's one remaining animation. A tap confirms itself instantly, which is
/// feedback rather than decoration — without it, a dense government list feels
/// dead. Entrance fades, staggered lists and the shimmer loop are gone.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = Motion.pressScale,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final bool enabled;
  final HitTestBehavior behavior;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  @override
  Widget build(BuildContext context) {
    final child = widget.child;

    if (!_interactive) {
      return AnimatedScale(
        scale: 1,
        duration: Motion.fast,
        child: child,
      );
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: Motion.fast,
        curve: Motion.standard,
        child: child,
      ),
    );
  }
}

/// A [Material]-clipped, press-aware tappable surface.
///
/// Use this instead of `InkWell` + `Container`: the previous `StatTile` put the
/// `InkWell` *outside* the rounded container, so ink painted past the corners.
class TappableCard extends StatelessWidget {
  const TappableCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(Insets.lg),
    this.color = AppColors.surface,
    this.borderColor,
    this.radius = Radii.lg,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final radiusAll = BorderRadius.circular(radius);

    return PressScale(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Material(
        color: color,
        borderRadius: radiusAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radiusAll,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: radiusAll,
              border: Border.all(color: borderColor ?? AppColors.border),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
