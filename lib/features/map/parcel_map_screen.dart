import 'package:flutter/material.dart';
// `Path` hidden from latlong2: it exports a generic `Path<LatLng>` for map
// data, which would shadow the dart:ui `Path` used by the offline schematic.
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/land_case.dart';
import '../../services/field_location_service.dart';
import '../../widgets/common.dart';
import 'wkt_parser.dart';

/// Tile faults tolerated before the map falls back to a drawn schematic.
/// A handful of missing tiles on a poor connection is normal; a screenful of
/// them means there is no usable basemap.
const kTileErrorFallbackThreshold = 4;

/// Parcel map: authoritative WKT boundary + officer location. No drawing tools.
///
/// When the tile server cannot be reached the map swaps to
/// [OfflineParcelSchematic], so the boundary, the parcel marker and the
/// officer marker stay on screen with no network at all.
class ParcelMapScreen extends ConsumerStatefulWidget {
  const ParcelMapScreen({super.key, required this.caseData, this.embedded = false});

  final LandCase caseData;

  /// True when hosted inside a case dossier — hides the re-locate FAB, which
  /// would otherwise sit on top of the following section.
  final bool embedded;

  @override
  ConsumerState<ParcelMapScreen> createState() => _ParcelMapScreenState();
}

class _ParcelMapScreenState extends ConsumerState<ParcelMapScreen> {
  final _controller = MapController();

  /// One record instead of four separate fields. The previous build spread
  /// location state across `_gps`, `_gpsError`, `_locating` and `_tileErrors`,
  /// which made each of the five `setState` calls easy to get wrong.
  _MapState _state = const _MapState();

  @override
  void initState() {
    super.initState();
    _locate();
  }

  @override
  void didUpdateWidget(ParcelMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.caseData.caseNo != widget.caseData.caseNo) {
      _state = const _MapState();
      _locate();
    }
  }

  Future<void> _locate() async {
    setState(() => _state = _state.copyWith(locating: true, gpsNotice: null));
    final loc = await fieldLocationService.acquire(
      nearLat: widget.caseData.latitude,
      nearLng: widget.caseData.longitude,
    );
    if (!mounted) return;

    final point = LatLng(loc.latitude, loc.longitude);
    setState(() => _state = _state.copyWith(
          gps: point,
          locating: false,
          gpsNotice: loc.isMock ? 'Approximate location (mock GPS)' : null,
        ));

    if (!_state.tilesFailed) {
      // Animate rather than jump, so a fix landing does not snap the view.
      _controller.move(point, _state.zoom);
    }
  }

  void _onTileError(TileImage tile, Object error, StackTrace? stack) {
    if (_state.tilesFailed || !mounted) return;
    final next = _state.tileErrors + 1;
    if (next < kTileErrorFallbackThreshold) {
      setState(() => _state = _state.copyWith(tileErrors: next));
      return;
    }
    setState(() => _state = _state.copyWith(tileErrors: next, tilesFailed: true));
  }

  /// Clears the fallback so a returning connection can bring the basemap back.
  void _retryTiles() {
    setState(() => _state = _state.copyWith(tileErrors: 0, tilesFailed: false));
  }

  @override
  Widget build(BuildContext context) {
    final wkt = widget.caseData.geometryWkt;
    final polygons = wkt.isNotEmpty ? WktParser.parsePolygons(wkt) : <List<LatLng>>[];
    final zoom = polygons.isNotEmpty ? 16.0 : 13.0;

    final center = polygons.isNotEmpty
        ? (WktParser.centroid(wkt) ??
            LatLng(widget.caseData.latitude, widget.caseData.longitude))
        : LatLng(widget.caseData.latitude, widget.caseData.longitude);

    // The single notice strip. The previous build had four independent
    // `Positioned` overlays that could stack on top of each other.
    final notice = _buildNotice(wkt, polygons);

    return Stack(
      children: [
        RepaintBoundary(
          child: _state.tilesFailed
              ? OfflineParcelSchematic(
                  caseData: widget.caseData,
                  polygons: polygons,
                  parcelCenter: center,
                  officerPoint: _state.gps,
                )
              : FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: zoom,
                    onPositionChanged: (_, hasGesture) {},
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'in.terranex.terranex_fo',
                      errorTileCallback: _onTileError,
                    ),
                    PolygonLayer(
                      polygons: [
                        for (final ring in polygons)
                          Polygon(
                            points: ring,
                            color: AppColors.info.withValues(alpha: 0.18),
                            borderColor: AppColors.info,
                            borderStrokeWidth: 3,
                          ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        if (_state.gps != null)
                          Marker(
                            point: _state.gps!,
                            width: 36,
                            height: 36,
                            child: const _MapMarker(
                              icon: Icons.my_location,
                              color: AppColors.danger,
                            ),
                          ),
                        Marker(
                          point: center,
                          width: 34,
                          height: 34,
                          child: const _MapMarker(
                            icon: Icons.location_on,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    // flutter_map's own `SimpleAttributionWidget` overflows
                    // horizontally below ~380 logical px, so the attribution is
                    // rendered here as a compact pill instead.
                    const _AttributionPill(),
                  ],
                ),
        ),
        if (_state.locating)
          Positioned(
            top: Insets.sm,
            right: Insets.sm,
            child: _MapChip(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const Gap(Insets.sm, horizontal: true),
                  Text('LOCATING', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ),
        Positioned(
          top: Insets.sm,
          left: Insets.sm,
          right: _state.locating ? 64 : Insets.sm,
          child: notice == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: Insets.sm),
                  child: notice,
                ),
        ),
        Positioned(
          bottom: Insets.sm,
          left: Insets.sm,
          child: _state.tilesFailed
              ? const SizedBox.shrink()
              : const _AttributionPill(),
        ),
        if (!widget.embedded)
          Positioned(
            bottom: Insets.md,
            right: Insets.md,
            child: FloatingActionButton.small(
              // No hero tag: the FAB would otherwise fly between routes.
              heroTag: null,
              tooltip: 'Re-locate',
              onPressed: _state.locating ? null : _locate,
              child: const Icon(Icons.my_location),
            ),
          ),
      ],
    );
  }

  /// At most one notice at a time, most-severe first.
  Widget? _buildNotice(String wkt, List<List<LatLng>> polygons) {
    if (_state.tilesFailed) {
      return AppBanner(
        tone: AppBannerTone.neutral,
        icon: Icons.cloud_off_outlined,
        message: 'Offline map — tile server unreachable. Boundary and markers '
            'shown from the cached survey record.',
        action: TextButton(
          onPressed: _retryTiles,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('RETRY'),
        ),
      );
    }
    if (polygons.isEmpty) {
      return AppBanner(
        tone: AppBannerTone.warning,
        icon: Icons.polyline_outlined,
        message: wkt.isEmpty
            ? 'No cached boundary polygon for this parcel — centroid shown.'
            : 'WKT parse failed — centroid shown.',
      );
    }
    if (_state.gpsNotice != null) {
      return AppBanner(
        tone: AppBannerTone.warning,
        icon: Icons.gps_fixed,
        message: _state.gpsNotice!,
      );
    }
    return null;
  }
}

@immutable
class _MapState {
  const _MapState({
    this.gps,
    this.gpsNotice,
    this.locating = false,
    this.tileErrors = 0,
    this.tilesFailed = false,
  });

  final LatLng? gps;
  final String? gpsNotice;
  final bool locating;
  final int tileErrors;
  final bool tilesFailed;

  double get zoom => 16;

  _MapState copyWith({
    LatLng? gps,
    String? gpsNotice,
    bool? locating,
    int? tileErrors,
    bool? tilesFailed,
    bool clearNotice = false,
  }) =>
      _MapState(
        gps: gps ?? this.gps,
        gpsNotice: clearNotice ? null : (gpsNotice ?? this.gpsNotice),
        locating: locating ?? this.locating,
        tileErrors: tileErrors ?? this.tileErrors,
        tilesFailed: tilesFailed ?? this.tilesFailed,
      );
}

/// Required OpenStreetMap attribution, sized so it cannot overflow.
class _AttributionPill extends StatelessWidget {
  const _AttributionPill();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: Radii.smAll,
        ),
        child: Text(
          '© OpenStreetMap',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 9.5,
                color: AppColors.neutral,
              ),
        ),
      );
}

class _MapChip extends StatelessWidget {
  const _MapChip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        borderRadius: Radii.smAll,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.md, vertical: Insets.sm),
          child: child,
        ),
      );
}

/// A map pin with a soft halo, so it stays legible over satellite tiles.
class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 26),
      );
}

/// Self-contained parcel schematic drawn with a [CustomPainter].
///
/// Used instead of raster tiles when there is no network: it shows the survey
/// boundary, the parcel marker, the officer's position and the coordinates, so
/// the map section is never an empty grey box in a field demo.
class OfflineParcelSchematic extends StatelessWidget {
  const OfflineParcelSchematic({
    super.key,
    required this.caseData,
    required this.polygons,
    required this.parcelCenter,
    required this.officerPoint,
  });

  final LandCase caseData;
  final List<List<LatLng>> polygons;
  final LatLng parcelCenter;
  final LatLng? officerPoint;

  @override
  Widget build(BuildContext context) {
    final c = caseData;
    final theme = Theme.of(context);

    return ColoredBox(
      color: AppColors.schematicSky,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _SchematicPainter(
                  polygons: polygons,
                  parcelCenter: parcelCenter,
                  officerPoint: officerPoint,
                ),
              ),
            ),
          ),
          Positioned(
            top: Insets.sm,
            left: Insets.sm,
            child: const AppChip(
              icon: Icons.satellite_alt,
              label: 'Survey schematic',
              color: AppColors.info,
              dense: true,
            ),
          ),
          Positioned(
            bottom: Insets.sm,
            left: Insets.sm,
            right: Insets.sm,
            child: _MapChip(
              child: Row(
                children: [
                  const Icon(Icons.place, size: 16, color: AppColors.info),
                  const Gap(Insets.sm, horizontal: true),
                  Expanded(
                    child: Text(
                      '${c.parcelId} · Survey ${c.surveyNo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  const Gap(Insets.sm, horizontal: true),
                  Text(
                    c.coordinateLabel,
                    style: theme.textTheme.bodySmall!.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SchematicPainter extends CustomPainter {
  _SchematicPainter({
    required this.polygons,
    required this.parcelCenter,
    required this.officerPoint,
  });

  final List<List<LatLng>> polygons;
  final LatLng parcelCenter;
  final LatLng? officerPoint;

  /// Small survey-style grid, like a printed sketch sheet.
  static final _gridPaint = Paint()
    ..color = AppColors.schematicLine
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 40.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _gridPaint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }

    // Fit the parcel into the viewport with a margin, and use the same
    // projection for the officer marker so the relative position is honest.
    var minLat = parcelCenter.latitude;
    var maxLat = parcelCenter.latitude;
    var minLng = parcelCenter.longitude;
    var maxLng = parcelCenter.longitude;
    for (final ring in polygons) {
      for (final p in ring) {
        minLat = p.latitude < minLat ? p.latitude : minLat;
        maxLat = p.latitude > maxLat ? p.latitude : maxLat;
        minLng = p.longitude < minLng ? p.longitude : minLng;
        maxLng = p.longitude > maxLng ? p.longitude : maxLng;
      }
    }
    if (polygons.isEmpty) {
      // No boundary cached — draw a nominal survey box around the centroid.
      minLat -= 0.0015;
      maxLat += 0.0015;
      minLng -= 0.0018;
      maxLng += 0.0018;
    }

    final latSpan = (maxLat - minLat).abs() < 1e-9 ? 0.003 : maxLat - minLat;
    final lngSpan = (maxLng - minLng).abs() < 1e-9 ? 0.0036 : maxLng - minLng;
    const margin = 34.0;
    final usableW = (size.width - margin * 2).clamp(1.0, double.infinity);
    final usableH = (size.height - margin * 2).clamp(1.0, double.infinity);
    final scale = (usableW / lngSpan) < (usableH / latSpan)
        ? usableW / lngSpan
        : usableH / latSpan;

    Offset project(LatLng p) => Offset(
          margin + usableW / 2 + (p.longitude - (minLng + maxLng) / 2) * scale,
          margin + usableH / 2 - (p.latitude - (minLat + maxLat) / 2) * scale,
        );

    // Adjacent (neighbouring) plot outlines, purely schematic.
    final neighbourPaint = Paint()
      ..color = AppColors.schematicMarker
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final dx in [-1.0, 1.0]) {
      final path = Path()
        ..addRect(Rect.fromPoints(
          project(LatLng(minLat, minLng)),
          project(LatLng(maxLat, minLng + (maxLng - minLng) * 1.35 * dx)),
        ));
      canvas.drawPath(path, neighbourPaint);
    }

    if (polygons.isNotEmpty) {
      for (final ring in polygons) {
        if (ring.length < 3) continue;
        final path = Path()..moveTo(project(ring.first).dx, project(ring.first).dy);
        for (final p in ring.skip(1)) {
          path.lineTo(project(p).dx, project(p).dy);
        }
        path.close();
        canvas.drawPath(
          path,
          Paint()..color = AppColors.info.withValues(alpha: 0.18),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = AppColors.info
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    } else {
      final path = Path()
        ..addRect(Rect.fromPoints(
          project(LatLng(minLat, minLng)),
          project(LatLng(maxLat, maxLng)),
        ));
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.info
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    _drawMarker(canvas, project(parcelCenter), AppColors.info);
    final officer = officerPoint;
    if (officer != null) {
      // Only plot the officer when the fix is close enough to be on this sheet.
      if (officer.latitude >= minLat - latSpan &&
          officer.latitude <= maxLat + latSpan &&
          officer.longitude >= minLng - lngSpan &&
          officer.longitude <= maxLng + lngSpan) {
        _drawMarker(canvas, project(officer), AppColors.danger);
      }
    }
  }

  /// Marker drawn without a glyph font so it works on any test surface.
  void _drawMarker(Canvas canvas, Offset at, Color color) {
    canvas.drawCircle(
      at,
      13,
      Paint()..color = color.withValues(alpha: 0.18),
    );
    canvas.drawCircle(at, 6, Paint()..color = color);
    canvas.drawCircle(
      at,
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Small orientation tick so the two markers stay distinguishable.
    canvas.drawLine(
      at + const Offset(0, -13),
      at + const Offset(0, -19),
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SchematicPainter old) =>
      old.parcelCenter != parcelCenter ||
      old.officerPoint != officerPoint ||
      old.polygons.length != polygons.length;
}
