import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/land_case.dart';
import '../../services/field_location_service.dart';
import 'wkt_parser.dart';

/// Parcel map: authoritative WKT boundary + officer location. No drawing tools.
class ParcelMapScreen extends ConsumerStatefulWidget {
  const ParcelMapScreen({super.key, required this.caseData, this.embedded = false});

  final LandCase caseData;
  final bool embedded;

  @override
  ConsumerState<ParcelMapScreen> createState() => _ParcelMapScreenState();
}

class _ParcelMapScreenState extends ConsumerState<ParcelMapScreen> {
  final _controller = MapController();
  LatLng? _gps;
  String? _gpsError;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _gpsError = null;
    });
    final loc = await fieldLocationService.acquire(
      nearLat: widget.caseData.latitude,
      nearLng: widget.caseData.longitude,
    );
    if (!mounted) return;
    setState(() {
      _gps = LatLng(loc.latitude, loc.longitude);
      _locating = false;
      if (loc.isMock) _gpsError = 'Approximate location (mock GPS)';
    });
    _controller.move(_gps!, 15);
  }

  @override
  Widget build(BuildContext context) {
    final wkt = widget.caseData.geometryWkt;
    final polygons = wkt.isNotEmpty ? WktParser.parsePolygons(wkt) : <List<LatLng>>[];

    LatLng center;
    if (polygons.isNotEmpty) {
      center = WktParser.centroid(wkt) ?? LatLng(widget.caseData.latitude, widget.caseData.longitude);
    } else {
      center = LatLng(widget.caseData.latitude, widget.caseData.longitude);
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: center,
            initialZoom: polygons.isNotEmpty ? 16 : 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'in.bhoomisetu.bhoomi_setu_fo',
            ),
            PolygonLayer(
              polygons: [
                for (final ring in polygons)
                  Polygon(
                    points: ring,
                    color: Colors.indigo.withValues(alpha: 0.15),
                    borderColor: Colors.indigo,
                    borderStrokeWidth: 3,
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                if (_gps != null)
                  Marker(
                    point: _gps!,
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.my_location, color: Colors.red, size: 32),
                  ),
                Marker(
                  point: center,
                  width: 30,
                  height: 30,
                  child: const Icon(Icons.location_on, color: Colors.indigo, size: 28),
                ),
              ],
            ),
            const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
          ],
        ),
        if (_locating)
          const Positioned(
            top: 8,
            right: 8,
            child: Card(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2))),
          ),
        if (_gpsError != null)
          Positioned(
            top: 8,
            left: 8,
            right: 60,
            child: Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(_gpsError!, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
        if (polygons.isEmpty)
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  wkt.isEmpty
                      ? 'No cached boundary polygon for this parcel — centroid shown.'
                      : 'WKT parse failed — centroid shown.',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 12,
          right: 12,
          child: FloatingActionButton.small(
            heroTag: 'loc_${widget.caseData.id}',
            onPressed: _locate,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
