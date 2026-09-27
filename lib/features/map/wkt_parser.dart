import 'package:latlong2/latlong.dart';

/// Minimal WKT parser for POLYGON / MULTIPOLYGON (lon lat order).
class WktParser {
  /// Returns list of polygon rings (outer first). Empty if unparseable.
  static List<List<LatLng>> parsePolygons(String wkt) {
    final trimmed = wkt.trim();
    if (trimmed.toUpperCase().startsWith('POLYGON')) {
      final rings = _parseRings(trimmed.substring(_afterType(trimmed)));
      return rings.isEmpty ? [] : [rings.first];
    }
    if (trimmed.toUpperCase().startsWith('MULTIPOLYGON')) {
      final result = <List<LatLng>>[];
      final inner = trimmed.substring(_afterType(trimmed)).trim();
      // Strip outer parens of multipolygon: ((...),(...))
      final body = _stripOuter(inner);
      for (final poly in _splitTopLevel(body, ',')) {
        final rings = _parseRings('($poly)');
        if (rings.isNotEmpty) result.add(rings.first);
      }
      return result;
    }
    return [];
  }

  static int _afterType(String s) {
    final i = s.indexOf('(');
    return i < 0 ? 0 : i;
  }

  static String _stripOuter(String s) {
    var t = s.trim();
    while (t.startsWith('(') && t.endsWith(')')) {
      t = t.substring(1, t.length - 1).trim();
    }
    return t;
  }

  static List<String> _splitTopLevel(String s, String sep) {
    final out = <String>[];
    var depth = 0;
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      if (ch == '(') depth++;
      if (ch == ')') depth--;
      if (ch == sep && depth == 0) {
        out.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    if (buf.isNotEmpty) out.add(buf.toString());
    return out.where((x) => x.trim().isNotEmpty).toList();
  }

  static List<List<LatLng>> _parseRings(String parenthesized) {
    final rings = <List<LatLng>>[];
    final inner = _stripOuter(parenthesized);
    // Rings separated at top level by comma when multipolygon-style nested;
    // for POLYGON((..),(..)) after strip we get (..),(..)
    for (final ringRaw in _splitTopLevel(inner, ',')) {
      final ring = _stripOuter(ringRaw);
      final pts = <LatLng>[];
      for (final pair in ring.split(',')) {
        final parts = pair.trim().split(RegExp(r'\s+'));
        if (parts.length < 2) continue;
        final lon = double.tryParse(parts[0]);
        final lat = double.tryParse(parts[1]);
        if (lon == null || lat == null) continue;
        pts.add(LatLng(lat, lon)); // WKT is lon lat
      }
      if (pts.length >= 3) rings.add(pts);
    }
    // If single ring without nested structure
    if (rings.isEmpty) {
      final pts = <LatLng>[];
      for (final pair in _stripOuter(parenthesized).split(',')) {
        final parts = pair.trim().split(RegExp(r'\s+'));
        if (parts.length < 2) continue;
        final lon = double.tryParse(parts[0]);
        final lat = double.tryParse(parts[1]);
        if (lon == null || lat == null) continue;
        pts.add(LatLng(lat, lon));
      }
      if (pts.length >= 3) rings.add(pts);
    }
    return rings;
  }

  static LatLng? centroid(String wkt) {
    final polys = parsePolygons(wkt);
    if (polys.isEmpty) return null;
    var ring = polys.first;
    // Closed rings repeat the first point — average unique vertices only.
    if (ring.length > 1 && ring.first.latitude == ring.last.latitude && ring.first.longitude == ring.last.longitude) {
      ring = ring.sublist(0, ring.length - 1);
    }
    if (ring.isEmpty) return null;
    var lat = 0.0, lng = 0.0;
    for (final p in ring) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / ring.length, lng / ring.length);
  }
}
