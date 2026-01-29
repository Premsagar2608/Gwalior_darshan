import 'package:geolocator/geolocator.dart';

class DistanceService {
  static double calculateDistance(
      double userLat, double userLng, double placeLat, double placeLng) {
    double distanceInMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      placeLat,
      placeLng,
    );

    return distanceInMeters / 1000; // convert to kilometers
  }
}
