import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'tokens.dart';

/// The app's type scale.
///
/// The previous build had **no** `textTheme` at all — 161 hand-rolled
/// `TextStyle`s and 21 competing font sizes, including half-pixels like 13.5.
/// Everything now resolves through these fifteen roles.
abstract final class AppTextTheme {
  static const String fontFamily = 'Inter';

  /// Numerals in cases, dates and SLAs are compared at a glance — tabular
  /// figures keep columns from shifting as digits change.
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static TextTheme build(ColorScheme scheme) {
    TextStyle s(
      double size,
      FontWeight weight, {
      double? height,
      double? spacing,
      Color? color,
      List<FontFeature>? features,
    }) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: spacing,
          color: color ?? AppColors.textPrimary,
          fontFeatures: features,
        );

    return TextTheme(
      // Display — login wordmark only.
      displayLarge: s(40, FontWeight.w800, height: 1.1, spacing: -1.0),
      displayMedium: s(32, FontWeight.w800, height: 1.15, spacing: -0.6),
      displaySmall: s(28, FontWeight.w700, height: 1.2, spacing: -0.4),

      // Headline — screen-level statements.
      headlineLarge: s(26, FontWeight.w700, height: 1.25, spacing: -0.3),
      headlineMedium: s(22, FontWeight.w700, height: 1.3, spacing: -0.2),
      headlineSmall: s(20, FontWeight.w700, height: 1.3, spacing: -0.2),

      // Title — card headers, list item heads.
      titleLarge: s(18, FontWeight.w700, height: 1.35, spacing: -0.1),
      titleMedium: s(16, FontWeight.w700, height: 1.35, spacing: -0.1),
      titleSmall: s(14, FontWeight.w600, height: 1.4, color: AppColors.textSecondary),

      // Body — the workhorse.
      bodyLarge: s(15, FontWeight.w400, height: 1.5),
      bodyMedium: s(14, FontWeight.w400, height: 1.5),
      bodySmall: s(13, FontWeight.w400, height: 1.45, color: AppColors.textSecondary),

      // Label — buttons, chips, field labels.
      labelLarge: s(15, FontWeight.w700, height: 1.2, spacing: 0.1),
      labelMedium: s(13, FontWeight.w600, height: 1.2, spacing: 0.1),
      labelSmall: s(11, FontWeight.w600, height: 1.2, spacing: 0.3),
    );
  }

  /// Uppercase micro-label used for every section header and chip.
  static TextStyle sectionLabel(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
        height: 1.2,
        color: AppColors.textTertiary,
      );

  /// Numeric readouts — SLA counters, stat values, dates.
  static TextStyle numeric(
    BuildContext context, {
    required double size,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? spacing,
  }) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        color: color ?? AppColors.textPrimary,
        fontFeatures: _tabular,
      );
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.brand,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.brand,
    onPrimary: AppColors.textOnBrand,
    secondary: AppColors.info,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.danger,
    onError: Colors.white,
  );

  final textTheme = AppTextTheme.build(scheme);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: AppTextTheme.fontFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.canvas,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,

    // ---- Motion --------------------------------------------------------
    // Pages replace each other outright — no slide, no fade, no predictive-back
    // scrub. `InkSparkle` above is kept: a tap is feedback, not decoration.
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: _InstantPageTransitionsBuilder(),
      TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
    }),

    // ---- App bar --------------------------------------------------------
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.brand,
      foregroundColor: AppColors.textOnBrand,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 56,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      titleTextStyle: textTheme.titleLarge!.copyWith(color: AppColors.textOnBrand),
      iconTheme: const IconThemeData(color: AppColors.textOnBrand, size: 22),
    ),

    // ---- Surfaces -------------------------------------------------------
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.lgAll,
        side: BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.textTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: Radii.lgAll),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),

    // ---- Buttons --------------------------------------------------------
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
        textStyle: textTheme.labelLarge,
        elevation: 0,
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.neutralSoft,
        disabledForegroundColor: AppColors.textTertiary,
        shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
        textStyle: textTheme.labelLarge,
        foregroundColor: AppColors.brand,
        side: BorderSide(color: AppColors.borderStrong),
        shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: textTheme.labelLarge,
        foregroundColor: AppColors.brand,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.brand,
      foregroundColor: Colors.white,
      elevation: 3,
      highlightElevation: 6,
      shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
    ),

    // ---- Inputs ---------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.lg),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: textTheme.labelMedium!.copyWith(color: AppColors.textSecondary),
      floatingLabelStyle:
          textTheme.labelMedium!.copyWith(color: AppColors.brand, fontWeight: FontWeight.w700),
      hintStyle: textTheme.bodyMedium!.copyWith(color: AppColors.textTertiary),
      helperStyle: textTheme.bodySmall!.copyWith(fontSize: 12, color: AppColors.textTertiary),
      errorStyle: textTheme.bodySmall!.copyWith(fontSize: 12, color: AppColors.danger),
      border: _inputBorder(AppColors.borderStrong),
      enabledBorder: _inputBorder(AppColors.borderStrong),
      focusedBorder: _inputBorder(AppColors.brand, width: 2),
      errorBorder: _inputBorder(AppColors.danger),
      focusedErrorBorder: _inputBorder(AppColors.danger, width: 2),
    ),

    // ---- Selection controls ---------------------------------------------
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.successSoft,
      side: BorderSide(color: AppColors.borderStrong),
      shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
      labelStyle: textTheme.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: Insets.sm, vertical: Insets.xs),
      showCheckmark: false,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.brand : AppColors.neutralSoft,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.brand : Colors.transparent,
      ),
      shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
      side: const BorderSide(color: AppColors.textTertiary, width: 1.5),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.brand : null,
      ),
    ),

    // ---- Navigation -----------------------------------------------------
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.successSoft,
      elevation: 0,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      indicatorShape: const RoundedRectangleBorder(borderRadius: Radii.pillAll),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => textTheme.labelSmall!.copyWith(
          fontSize: 11.5,
          fontWeight:
              s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w600,
          color: s.contains(WidgetState.selected) ? AppColors.brand : AppColors.textTertiary,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          size: 23,
          color: s.contains(WidgetState.selected) ? AppColors.brand : AppColors.textTertiary,
        ),
      ),
    ),

    // ---- Feedback -------------------------------------------------------
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: textTheme.bodyMedium!.copyWith(color: Colors.white),
      shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
      insetPadding: const EdgeInsets.all(Insets.lg),
      elevation: 6,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.brand,
      linearTrackColor: AppColors.neutralSoft,
      circularTrackColor: AppColors.neutralSoft,
      linearMinHeight: 6,
    ),

    // ---- Lists & tiles ---------------------------------------------------
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.xs),
      titleTextStyle: textTheme.titleMedium,
      subtitleTextStyle: textTheme.bodySmall,
      iconColor: AppColors.textSecondary,
      shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: AppColors.textSecondary,
      collapsedIconColor: AppColors.textSecondary,
      textColor: AppColors.textPrimary,
      shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
      collapsedShape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: Radii.smAll,
      ),
      textStyle: textTheme.bodySmall!.copyWith(color: Colors.white, fontSize: 12),
    ),
    badgeTheme: const BadgeThemeData(
      backgroundColor: AppColors.danger,
      textColor: Colors.white,
      textStyle: TextStyle(fontFamily: AppTextTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}

OutlineInputBorder _inputBorder(Color color, {double width = 1}) => OutlineInputBorder(
      borderRadius: Radii.mdAll,
      borderSide: BorderSide(color: color, width: width),
    );

/// Swaps pages with no transition.
///
/// The SDK ships no "no animation" page-transition builder, so the build was
/// using `FadeForwardsPageTransitionsBuilder` on every push. This is the
/// no-motion counterpart: the outgoing page is gone the instant the push
/// starts.
class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}
