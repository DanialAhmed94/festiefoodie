import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utilities/getUserLocation.dart';
import '../foodieStall/mapViews/LocationMap.dart';
import 'widgets/modalBottomSheet.dart';

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
      final Position position = await getUserLocation();
      userLocation = LatLng(position.latitude, position.longitude);
      final LatLng latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('userLocation'),
            position: latLng,
            infoWindow: InfoWindow(title: 'Your Current Location'),
            icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          ),
        );
      });
// **Add Predefined UK Markers**
      for (var i = 0; i < _ukLocations.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('UK_Location_$i'),
            position: _ukLocations[i],
            infoWindow: InfoWindow(title: 'Location ${i + 1}'),
            icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
            onTap: ()=>showMarkerInfo(context),
          ),
        );
      }

      _controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 10));
    } catch (e) {
      print("Error setting up map: $e");
    }
  }

  // Asynchronous operation to fetch custom marker icon
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "This feature is in development.",
                        style: TextStyle(color: Colors.white),
                      ),
                      duration: Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.black,
                      action: SnackBarAction(
                        label: "OK",
                        textColor: Colors.orange,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
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
