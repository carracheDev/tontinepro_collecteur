import 'package:geolocator/geolocator.dart';

class PositionGps {
  final double latitude;
  final double longitude;
  const PositionGps({required this.latitude, required this.longitude});
}

class LocationService {
  static Future<PositionGps?> obtenirPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 12),
    );
    return PositionGps(latitude: pos.latitude, longitude: pos.longitude);
  }
}
