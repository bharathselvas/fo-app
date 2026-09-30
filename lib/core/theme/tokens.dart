import 'package:flutter/material.dart';

/// Spacing scale. Every gap in the app should come from here so rhythm is
/// consistent — the previous code had 105 ad-hoc `EdgeInsets` with no scale.
abstract final class Insets {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Standard screen gutter.
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets card = EdgeInsets.all(lg);
}

/// Corner radii. One scale, so a theme change moves every corner in the app.
abstract final class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Motion tokens.
///
/// The app is static: no route transitions, no entrance fades, no overscroll.
/// What is left is press feedback, and it runs on [fast] with [pressScale].
/// The other durations and curves are kept as the scale for that feedback, and
/// are still asserted by the design-system test.
abstract final class Motion {
  /// Press feedback, state toggles.
  static const Duration fast = Duration(milliseconds: 150);

  /// Content swaps, chip colour changes, expand/collapse.
  static const Duration normal = Duration(milliseconds: 250);

  /// Route pushes, large reveals.
  static const Duration slow = Duration(milliseconds: 400);

  /// Press-scale down. Feels instant but still acknowledges the tap.
  static const double pressScale = 0.97;

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standard = Curves.easeOutQuart;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
}

/// Layout constants that would otherwise be magic numbers in feature code.
abstract final class Layout {
  /// Keeps a reading column from stretching across a tablet.
  static const double maxContentWidth = 640;

  /// Label column width shared by every label/value row.
  static const double infoLabelWidth = 128;
}
