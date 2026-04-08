// service_checks.dart

import 'package:location/location.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Added import

/// Checks for an active network interface (Wi‑Fi / mobile, not [none] only).
/// Uses [Connectivity.checkConnectivity] list API (connectivity_plus 6+).
Future<bool> checkInternetConnection() async {
  final results = await Connectivity().checkConnectivity();
  if (results.isEmpty) return false;
  return results.any((r) => r != ConnectivityResult.none);
}

/// Checks the status of the location service.
/// Returns true if the location service is enabled and permissions are granted.
/// Returns false if the location service is disabled or permission is denied.
Future<bool> checkLocationService() async {
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  try {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false; // Permission denied after re-prompting
      }
    }

    _locationData = await location.getLocation();
    // You may use _locationData if needed.
    return true; // Location service check succeeded.
  } catch (e) {
    print("Error checking location service: $e");
    return false; // Location service check failed due to an error.
  }
}


