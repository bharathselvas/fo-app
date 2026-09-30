import 'package:geolocator/geolocator.dart';

/// A captured device position (real hardware or prototype mock).
class FieldLocation {
  const FieldLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    required this.source,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final LocationSource source;

  bool get isMock => source == LocationSource.mock;

  String get latitudeLabel => latitude.toStringAsFixed(4);
  String get longitudeLabel => longitude.toStringAsFixed(4);
  String get accuracyLabel => '±${accuracy.toStringAsFixed(1)} m';
}

enum LocationSource { device, mock }

/// GPS access point for the whole app.
///
/// Tries the device GPS first; if permission is missing, the sensor is slow or
/// the demo device has no fix, it falls back to a realistic mock position near
/// the parcel so the verification flow can always be demonstrated.
class FieldLocationService {
  const FieldLocationService();

  static const _fallbackLat = 11.0456;
  static const _fallbackLng = 77.1234;

  Future<FieldLocation> acquire({double? nearLat, double? nearLng}) async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _mock(nearLat, nearLng);
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 6));
      return FieldLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        timestamp: pos.timestamp,
        source: LocationSource.device,
      );
    } catch (_) {
      return _mock(nearLat, nearLng);
    }
  }

  FieldLocation _mock(double? nearLat, double? nearLng) {
    final now = DateTime.now();
    // Deterministic wobble so repeated captures in one session look plausible.
    final seed = now.millisecondsSinceEpoch ~/ 1000;
    final jitterLat = ((seed % 9) - 4) * 0.0001;
    final jitterLng = ((seed % 7) - 3) * 0.0001;
    return FieldLocation(
      latitude: (nearLat ?? _fallbackLat) + jitterLat,
      longitude: (nearLng ?? _fallbackLng) + jitterLng,
      accuracy: 6.0 + (seed % 4) * 0.4,
      timestamp: now,
      source: LocationSource.mock,
    );
  }
}

const fieldLocationService = FieldLocationService();
