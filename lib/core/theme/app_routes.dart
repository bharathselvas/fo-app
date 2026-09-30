import 'package:flutter/material.dart';

/// Route transitions.
///
/// Screens swap instantly. The build used to fade/slide/zoom every push, and
/// overscrolled while it did it; there is no motion left in navigation. These
/// factories stay so call sites read the same, and so a transition can be
/// reintroduced in one place if that decision is ever reversed.
abstract final class AppRoutes {
  /// Forward navigation into a detail screen.
  static Route<T> fadeUp<T>(Widget page, {RouteSettings? settings}) {
    return _instant<T>(page, settings);
  }

  /// Lateral push for a stack of peer screens.
  static Route<T> sharedAxis<T>(
    Widget page, {
    bool forward = true,
    RouteSettings? settings,
  }) {
    return _instant<T>(page, settings);
  }

  /// Full-bleed media (camera, evidence viewer).
  static Route<T> zoom<T>(Widget page, {RouteSettings? settings}) {
    return _instant<T>(page, settings);
  }

  static Route<T> _instant<T>(Widget page, RouteSettings? settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, _, _, child) => child,
    );
  }
}
