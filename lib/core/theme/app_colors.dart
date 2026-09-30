import 'package:flutter/material.dart';

/// Semantic palette.
///
/// Feature code referenced 35+ hardcoded hex literals before this existed —
/// the brand green was copy-pasted into 6 files. Status-specific colours live in
/// `data/models/enums.dart`; these are the *interface* colours.
abstract final class AppColors {
  // ---- Brand -------------------------------------------------------------
  static const Color brand = Color(0xFF1B5E20);
  static const Color brandBright = Color(0xFF2E7D32);
  static const Color brandDeep = Color(0xFF0D3D13);
  /// Darker than [brand], used as the first stop of header gradients.
  static const Color brandShadow = Color(0xFF14521B);

  // ---- Status ------------------------------------------------------------
  static const Color success = Color(0xFF2E7D32);
  static const Color successSoft = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningSoft = Color(0xFFFFF4E0);
  /// Readable warning text/icon colour on a light surface — the raw amber is
  /// too light to pass contrast at body sizes.
  static const Color warningInk = Color(0xFF9A5B00);
  static const Color danger = Color(0xFFB71C1C);
  static const Color dangerSoft = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoSoft = Color(0xFFE3F2FD);
  /// Server-unreachable. Distinct from `danger`: the data is safe, the backend
  /// is not answering.
  static const Color serverDown = Color(0xFFE65100);
  static const Color violet = Color(0xFF6A1B9A);
  static const Color teal = Color(0xFF00838F);
  static const Color neutral = Color(0xFF37474F);
  static const Color neutralSoft = Color(0xFFECEFF1);

  // ---- Surfaces ----------------------------------------------------------
  /// Page background — a touch cooler than pure grey so cards read as raised.
  static const Color canvas = Color(0xFFF4F6F5);
  static const Color surface = Colors.white;
  static const Color surfaceSunken = Color(0xFFFAFBFA);

  /// Hairline used by every card and divider.
  static Color get border => const Color(0xFF1B2B1D).withValues(alpha: 0.08);
  static Color get borderStrong =>
      const Color(0xFF1B2B1D).withValues(alpha: 0.16);

  // ---- Text --------------------------------------------------------------
  static const Color textPrimary = Color(0xFF14201A);
  static const Color textSecondary = Color(0xFF5A6B60);
  static const Color textTertiary = Color(0xFF8A9A91);
  static const Color textOnBrand = Colors.white;

  // ---- Media / chrome ----------------------------------------------------
  static const Color viewerBackground = Color(0xFF0E0E0E);
  static const Color viewerFooter = Color(0xFF171717);
  /// Hairline above a full-bleed media footer.
  static const Color viewerDivider = Color(0x1FFFFFFF);
  /// Outline for a secondary button sitting on the media footer.
  static const Color viewerOutline = Color(0x55FFFFFF);
  /// Positive accent inside a dark media footer.
  static const Color viewerPositive = Color(0xFF81C784);
  static const Color schematicSky = Color(0xFFECEFF1);
  static const Color schematicLine = Color(0xFFCFD8DC);
  static const Color schematicMarker = Color(0xFFB0BEC5);
  static const Color placeholderFoliage = Color(0xFF2E5E2E);
}
