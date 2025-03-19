import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'getUserLocation.dart';

Future<String> getUserAddress() async {
  try {
    final Position locationData = await getUserLocation();


    // Check if locationData is null or if latitude and longitude are null
    if (locationData == null ||
        locationData.latitude == null ||
        locationData.longitude == null) {
      return "Location data is not available";
    }
    print(
        'Fetching address for: ${locationData.latitude}, ${locationData.longitude}');

    List<Placemark> placemarks = await placemarkFromCoordinates(
      locationData.latitude!,
      locationData.longitude!,
    );

    if (placemarks.isEmpty) {
      return 'placemarks are empty';
    }
    String street = placemarks.reversed.last.street.toString();
    String locality = placemarks.reversed.last.locality.toString();
    String administrativeArea = placemarks.reversed.last.administrativeArea.toString();
    String country = placemarks.reversed.last.country.toString();

    String address = "$street, $locality, $administrativeArea, $country";
    return address;
  } catch (e) {
    print('Error getting user location or converting to an address: $e');
    return "Something went wrong";
  }
}