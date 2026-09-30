import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/models/evidence_record.dart';

/// Thumbnail for an evidence record.
///
/// Real camera captures render the file; prototype evidence (no file yet)
/// renders a painted placeholder so the grid never shows a broken image.
class EvidenceThumb extends StatelessWidget {
  const EvidenceThumb({
    super.key,
    required this.record,
    this.fit = BoxFit.cover,
    this.cacheWidth = 320,
  });

  final EvidenceRecord record;
  final BoxFit fit;

  /// Decode target. A three-column evidence grid renders ~120 logical px per
  /// cell but was decoding the full-resolution camera capture behind it.
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    final path = record.filePath;
    // The old build called `File(path).existsSync()` here — a synchronous
    // filesystem stat on the build path, once per grid cell, per rebuild.
    // `record.hasPhoto` already reflects that a file was recorded; if the file
    // has since been deleted, `errorBuilder` covers it.
    if (record.hasPhoto && path != null && path.isNotEmpty) {
      return Image.file(
        File(path),
        fit: fit,
        cacheWidth: cacheWidth,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
        frameBuilder: (context, child, frame, wasSyncLoaded) {
          if (wasSyncLoaded || frame != null) return child;
          return const _EvidencePlaceholder(seed: '');
        },
        errorBuilder: (_, _, _) => _EvidencePlaceholder(seed: record.id),
      );
    }
    return _EvidencePlaceholder(seed: record.id);
  }
}

/// Deterministic "field photo" illustration used for mock evidence.
class _EvidencePlaceholder extends StatelessWidget {
  const _EvidencePlaceholder({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _FieldPhotoPainter(seed: seed),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _FieldPhotoPainter extends CustomPainter {
  _FieldPhotoPainter({required String seed}) : hue = _hueFor(seed);

  final double hue;

  static double _hueFor(String seed) {
    if (seed.isEmpty) return 96;
    var h = 0;
    for (final code in seed.codeUnits) {
      h = (h * 31 + code) & 0xFFFF;
    }
    return (h % 360).toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Rect.fromLTWH(0, 0, size.width, size.height * 0.62);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HSLColor.fromAHSL(1, hue, 0.35, 0.78).toColor(),
            HSLColor.fromAHSL(1, hue, 0.30, 0.66).toColor(),
          ],
        ).createShader(sky),
    );

    final ground = Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38);
    canvas.drawRect(
      ground,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HSLColor.fromAHSL(1, 90, 0.28, 0.38).toColor(),
            HSLColor.fromAHSL(1, 85, 0.32, 0.28).toColor(),
          ],
        ).createShader(ground),
    );

    // Sun
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.2),
      math.min(size.width, size.height) * 0.09,
      Paint()..color = HSLColor.fromAHSL(1, 45, 0.9, 0.75).toColor(),
    );

    // Tree line / hedge
    final hedge = Path()
      ..moveTo(0, size.height * 0.62)
      ..lineTo(0, size.height * 0.55)
      ..lineTo(size.width * 0.25, size.height * 0.48)
      ..lineTo(size.width * 0.5, size.height * 0.56)
      ..lineTo(size.width * 0.75, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.57)
      ..lineTo(size.width, size.height * 0.62)
      ..close();
    canvas.drawPath(hedge, Paint()..color = AppColors.placeholderFoliage);
  }

  @override
  bool shouldRepaint(covariant _FieldPhotoPainter oldDelegate) =>
      oldDelegate.hue != hue;
}
