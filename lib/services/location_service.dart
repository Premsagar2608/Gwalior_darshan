import 'package:geolocator/geolocator.dart';

class LocationService {
  // Check & request location permission
  static Future<bool> _handlePermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return false; // Permission still denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // User permanently denied permission
    }

    return true; // Permission granted
  }

  // Get Current Location
  static Future<Position?> getCurrentLocation() async {
    bool permissionGranted = await _handlePermission();

    if (!permissionGranted) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
