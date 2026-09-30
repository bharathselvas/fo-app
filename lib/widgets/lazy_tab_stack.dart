import 'package:flutter/material.dart';

/// Lazily-built, permanently-alive tab host.
///
/// A plain `IndexedStack` builds every child on the first frame, which meant the
/// Map tab — and the GPS probe and map controller it owns — initialised on every
/// app cold start whether or not the officer ever opened it. Building all five
/// tabs up front also blew away scroll position and list state on every switch.
///
/// This builds a tab the first time it is visited and keeps it alive
/// afterwards, so:
///   * untouched tabs cost nothing,
///   * a visited tab keeps its scroll position, filters and map camera,
///   * switching back is a repaint, not a rebuild.
class LazyTabStack extends StatefulWidget {
  const LazyTabStack({
    super.key,
    required this.index,
    required this.builder,
    this.initialCount = 1,
  });

  final int index;

  /// Called once per tab, the first time that tab becomes visible.
  final IndexedWidgetBuilder builder;

  /// How many tabs to build eagerly on first frame.
  final int initialCount;

  @override
  State<LazyTabStack> createState() => _LazyTabStackState();
}

class _LazyTabStackState extends State<LazyTabStack> {
  late int _built = widget.initialCount.clamp(1, 1 << 30);

  @override
  void didUpdateWidget(LazyTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index + 1 > _built) {
      setState(() => _built = widget.index + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only the first `_built` children are constructed; the rest are an inert
    // zero-size box that keeps the stack the right arity for `index`.
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < _built; i++)
          RepaintBoundary(child: widget.builder(context, i)),
      ],
    );
  }
}
