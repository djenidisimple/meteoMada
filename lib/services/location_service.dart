import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> demanderPermission() async {
    if (kIsWeb) return false;
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return false;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, double>?> obtenirPosition() async {
    if (kIsWeb) return null;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );
      return {'lat': position.latitude, 'lon': position.longitude};
    } catch (_) {
      return null;
    }
  }
}
