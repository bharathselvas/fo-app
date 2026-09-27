import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../assignments/assignments_repository.dart';
import 'wkt_parser.dart';

/// Parcel map: authoritative WKT boundary + real GPS. No drawing tools.
class ParcelMapScreen extends ConsumerStatefulWidget {
  const ParcelMapScreen({super.key, required this.task, this.embedded = false});

  final AssignedTask task;
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
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _gpsError = 'Location permission denied');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() => _gps = LatLng(pos.latitude, pos.longitude));
      if (mounted) {
        _controller.move(_gps!, 16);
      }
    } catch (e) {
      setState(() => _gpsError = 'GPS unavailable');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wkt = widget.task.geometryWkt;
    final polygons = wkt != null && wkt.isNotEmpty ? WktParser.parsePolygons(wkt) : <List<LatLng>>[];

    LatLng center;
    if (_gps != null) {
      center = _gps!;
    } else if (polygons.isNotEmpty) {
      center = WktParser.centroid(wkt!) ?? const LatLng(11.0168, 76.9558);
    } else if (widget.task.centroidLat != null && widget.task.centroidLng != null) {
      center = LatLng(
        double.tryParse(widget.task.centroidLat!) ?? 11.0168,
        double.tryParse(widget.task.centroidLng!) ?? 76.9558,
      );
    } else {
      center = const LatLng(11.0168, 76.9558);
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
            right: 8,
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
                  'No cached boundary polygon. Centroid shown. '
                  '${wkt == null ? 'Geometry not available offline.' : 'WKT parse failed.'}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 12,
          right: 12,
          child: FloatingActionButton.small(
            heroTag: 'loc_${widget.task.id}',
            onPressed: _locate,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
