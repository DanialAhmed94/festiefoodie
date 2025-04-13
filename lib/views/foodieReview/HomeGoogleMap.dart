import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/festivalModel.dart';
import '../../providers/festivalProvider.dart';
import '../../utilities/getUserLocation.dart';
import '../foodieStall/mapViews/LocationMap.dart';
import 'widgets/modalBottomSheet.dart';
import 'package:provider/provider.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({Key? key}) : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  late GoogleMapController _controller;
  List<Marker> _markers = [];
// **List of Predefined UK Locations**
  final List<LatLng> _ukLocations = [
    LatLng(51.5074, -0.1278), // London
    LatLng(53.4808, -2.2426), // Manchester
    LatLng(55.9533, -3.1883), // Edinburgh
    LatLng(52.4862, -1.8904), // Birmingham
    LatLng(54.9784, -1.6174), // Newcastle
    LatLng(51.4545, -2.5879), // Bristol
  ];

  BitmapDescriptor? _customMarkerIcon; // Variable to store custom marker icon
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    _setupMap();
    _fetchCustomMarker();

    // Fetch custom marker icon
  }
  Future<void> _setupMap() async {
    try {
      final festivalProvider = Provider.of<FestivalProvider>(context, listen: false);
      await festivalProvider.fetchFestivals(context);

      final Position position = await getUserLocation();
      userLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('userLocation'),
            position: userLocation!,
            infoWindow: InfoWindow(title: 'Your Current Location'),
            icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          ),
        );
      });

      // Add Festival Markers
      for (var festival in festivalProvider.festivals) {
        _markers.add(
          Marker(
            markerId: MarkerId(festival.id.toString()),
            infoWindow: InfoWindow(title: festival.nameOrganizer ?? festival.description,),
            position: LatLng(double.parse(festival.latitude), double.parse(festival.longitude)),
            icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
            onTap: () => showMarkerInfo(context, festival),
          ),
        );
      }

      _controller.animateCamera(CameraUpdate.newLatLngZoom(userLocation!, 10));
    } catch (e) {
      print("Error setting up map: $e");
    }
  }
  double _calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
        start.latitude, start.longitude, end.latitude, end.longitude);
  }
  FestivalResource? _findNearestFestival() {
    final festivalProvider = Provider.of<FestivalProvider>(context, listen: false);

    if (userLocation == null || festivalProvider.festivals.isEmpty) return null;

    FestivalResource? nearestFestival;
    double minDistance = double.infinity;

    for (final festival in festivalProvider.festivals) {
      // Attempt to parse latitude and longitude safely
      final double? latitude = double.tryParse(festival.latitude);
      final double? longitude = double.tryParse(festival.longitude);

      // Skip if either latitude or longitude is invalid
      if (latitude != null && longitude != null) {
        double distance = _calculateDistance(
          userLocation!,
          LatLng(latitude, longitude),
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestFestival = festival;
        }
      }
    }
    return nearestFestival;
  }


  Future<void> _fetchCustomMarker() async {
    try {
      _customMarkerIcon = await getCustomMarker();
    } catch (e) {
      print("Error fetching custom marker icon: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(0, 0),
            // Initial value doesn't matter since we update it later
            zoom: 10,
          ),
          markers: Set<Marker>.of(_markers),
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.11,
          right: 0,
          left: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async {
                  FestivalResource? nearestFestival = _findNearestFestival();
                  if (nearestFestival != null) {
                    LatLng festivalLatLng = LatLng(
                        double.parse(nearestFestival.latitude),
                        double.parse(nearestFestival.longitude));
                    _controller.animateCamera(
                        CameraUpdate.newLatLngZoom(festivalLatLng, 13));
                    setState(() {
                      _markers.add(
                        Marker(
                          icon: _customMarkerIcon ??
                              BitmapDescriptor.defaultMarker,
                          markerId: MarkerId("nearestFestival"),
                          position: festivalLatLng,
                          infoWindow: InfoWindow(
                              title: nearestFestival.nameOrganizer ??nearestFestival.description ),
                        ),
                      );
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.redAccent,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Find Nearest Festival",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.09,
          right: MediaQuery.of(context).size.width * 0.05,
          child: ElevatedButton(
            onPressed: () async {
              getUserLocation().then((locationData) async {
                if (locationData != null) {
                  print("my location");
                  print("${locationData.latitude}, ${locationData.longitude}");
                  _markers.add(Marker(
                    icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
                    markerId: MarkerId("currentLocation"),
                    position: LatLng(locationData.latitude ?? 0,
                        locationData.longitude ?? 0),
                    infoWindow: InfoWindow(title: "Your current location"),
                  ));
                  CameraPosition newCameraPosition = CameraPosition(
                    target: LatLng(locationData.latitude ?? 0,
                        locationData.longitude ?? 0),
                    zoom: 14,
                  );
                  GoogleMapController googleMapController = await _controller;
                  googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(newCameraPosition),
                  );
                  setState(() {}); // Update UI with new marker
                }
              }).catchError((error) {
                print("Error getting location: $error");
              });
            },
            child: Icon(Icons.my_location_outlined),
          ),
        ),
      ],
    );
  }
}
