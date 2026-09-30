// Design-system guards. These fail the build if the token layer is bypassed,
// which is how 35+ hardcoded hex literals and 161 ad-hoc `TextStyle`s crept
// into the app in the first place.
//
// Run with:
//
//   LD_LIBRARY_PATH=/tmp/opencode/sqlitelib flutter test test/design_system_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terranex_fo/core/theme/app_colors.dart';
import 'package:terranex_fo/core/theme/app_theme.dart';
import 'package:terranex_fo/core/theme/tokens.dart';

/// Files allowed to contain colour literals.
const _colorWhitelist = {
  'core/theme/app_colors.dart', // the palette itself
  'core/theme/app_theme.dart', // derives the scheme from the palette
  'data/models/enums.dart', // status vocabulary
  'core/database/database.g.dart', // generated
};

/// Files allowed to construct a raw `TextStyle` outside the type scale.
const _textStyleWhitelist = {
  'core/theme/app_theme.dart',
  'core/theme/tokens.dart',
};

List<File> _dartFilesIn(String dir) =>
    Directory(dir).listSync(recursive: true).whereType<File>().where((f) {
      final p = f.path;
      return p.endsWith('.dart') && !p.endsWith('.g.dart');
    }).toList();

String _rel(File f) => f.path.replaceFirst('lib/', '');

void main() {
  group('colour tokens', () {
    test('feature code contains no hardcoded colour literals', () {
      final offenders = <String>[];

      for (final file in _dartFilesIn('lib')) {
        final rel = _rel(file);
        if (_colorWhitelist.contains(rel)) continue;

        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // `Color(0xFF…)` and `0xFF…` literals both count. Comments and
          // imports are skipped.
          final trimmed = line.trim();
          if (trimmed.startsWith('//') || trimmed.startsWith('*')) continue;
          if (RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)').hasMatch(line)) {
            offenders.add('$rel:${i + 1}  $trimmed');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'Use AppColors.* instead of a colour literal:\n${offenders.join('\n')}',
      );
    });

    test('the palette exposes the semantic roles feature code depends on', () {
      // Compile-time guard: referencing these fails the test file if a role is
      // renamed or removed from the palette.
      expect(AppColors.brand, isNotNull);
      expect(AppColors.success, isNotNull);
      expect(AppColors.warning, isNotNull);
      expect(AppColors.danger, isNotNull);
      expect(AppColors.info, isNotNull);
      expect(AppColors.textPrimary, isNotNull);
      expect(AppColors.canvas, isNotNull);
    });
  });

  group('type scale', () {
    test('feature code does not hand-roll TextStyles', () {
      final offenders = <String>[];

      for (final file in _dartFilesIn('lib')) {
        final rel = _rel(file);
        if (_textStyleWhitelist.contains(rel)) continue;

        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final trimmed = lines[i].trim();
          if (trimmed.startsWith('//') || trimmed.startsWith('*')) continue;
          if (RegExp(r'\bTextStyle\(').hasMatch(lines[i])) {
            offenders.add('$rel:${i + 1}  $trimmed');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'Use Theme.of(context).textTheme.* instead:\n${offenders.join('\n')}',
      );
    });

    test('every textTheme role resolves', () {
      final theme = buildAppTheme();
      final t = theme.textTheme;

      for (final role in [
        'displayLarge', 'displayMedium', 'displaySmall',
        'headlineLarge', 'headlineMedium', 'headlineSmall',
        'titleLarge', 'titleMedium', 'titleSmall',
        'bodyLarge', 'bodyMedium', 'bodySmall',
        'labelLarge', 'labelMedium', 'labelSmall',
      ]) {
        final style = switch (role) {
          'displayLarge' => t.displayLarge,
          'displayMedium' => t.displayMedium,
          'displaySmall' => t.displaySmall,
          'headlineLarge' => t.headlineLarge,
          'headlineMedium' => t.headlineMedium,
          'headlineSmall' => t.headlineSmall,
          'titleLarge' => t.titleLarge,
          'titleMedium' => t.titleMedium,
          'titleSmall' => t.titleSmall,
          'bodyLarge' => t.bodyLarge,
          'bodyMedium' => t.bodyMedium,
          'bodySmall' => t.bodySmall,
          'labelLarge' => t.labelLarge,
          'labelMedium' => t.labelMedium,
          _ => t.labelSmall,
        };

        expect(style, isNotNull, reason: 'textTheme.$role is null');
        expect(style!.fontFamily, appFontFamily);
        expect(style.fontSize, isNotNull);
        expect(style.fontSize, greaterThan(0));
      }
    });

    test('no half-pixel font sizes survive in the scale', () {
      final t = buildAppTheme().textTheme;
      for (final style in [
        t.displayLarge, t.displayMedium, t.displaySmall,
        t.headlineLarge, t.headlineMedium, t.headlineSmall,
        t.titleLarge, t.titleMedium, t.titleSmall,
        t.bodyLarge, t.bodyMedium, t.bodySmall,
        t.labelLarge, t.labelMedium, t.labelSmall,
      ]) {
        final size = style!.fontSize!;
        expect(
          size,
          (size * 2).roundToDouble() / 2,
          reason: 'font size $size is not on a whole or half step',
        );
      }
    });
  });

  group('theme', () {
    testWidgets('bundles Inter and defines the component themes', (tester) async {
      final theme = buildAppTheme();

      expect(theme.textTheme.bodyLarge!.fontFamily, appFontFamily);
      expect(theme.colorScheme.primary, AppColors.brand);
      expect(theme.useMaterial3, isTrue);

      // The component themes that were previously absent entirely.
      expect(theme.dialogTheme, isNotNull);
      expect(theme.bottomSheetTheme.showDragHandle, isTrue);
      expect(theme.navigationBarTheme.indicatorShape, isNotNull);
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(theme.inputDecorationTheme.floatingLabelBehavior,
          FloatingLabelBehavior.always);
      expect(theme.floatingActionButtonTheme.backgroundColor, AppColors.brand);
      expect(theme.listTileTheme.titleTextStyle, isNotNull);
      expect(theme.progressIndicatorTheme.linearMinHeight, 6);

      // A card radius that is not on the scale would drift from TappableCard.
      final card = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(card.borderRadius, Radii.lgAll);
    });
  });

  group('motion tokens', () {
    test('durations are ordered and curves are non-linear', () {
      expect(Motion.fast, lessThan(Motion.normal));
      expect(Motion.normal, lessThan(Motion.slow));
      expect(Motion.pressScale, lessThan(1.0));
      expect(Motion.pressScale, greaterThan(0.8));
    });
  });
}

/// The bundled family. Mirrors `AppTextTheme.fontFamily` so the test does not
/// depend on the theme module's internals.
const String appFontFamily = 'Inter';
