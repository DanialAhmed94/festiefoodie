import 'dart:ui';
import 'dart:ui';
import 'dart:ui';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package
import '../../../constants/appConstants.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';

Future<BitmapDescriptor> getCustomMarker() async {
  String svgData = await rootBundle.loadString('assets/svgs/ic_dest.svg');
  int width = 100;
  int height = 100;
  final pictureInfo = await vg.loadPicture(SvgStringLoader(svgData), null);
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);

  canvas.scale(
      width / pictureInfo.size.width, height / pictureInfo.size.height);
  canvas.drawPicture(pictureInfo.picture);
  final ui.Picture scaledPicture = recorder.endRecording();
  final image = await scaledPicture.toImage(width, height);
  final ByteData? byteData =
  await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List byteList = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(byteList);
}
class GoogleMapView extends StatefulWidget {
  late bool isFromFestival;

  GoogleMapView({required this.isFromFestival});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView>
    with WidgetsBindingObserver {
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(0.0, 0.0); // Default location while loading
  Set<Marker> _markers = {};
  String? selectedLatitude;
  String? selectedLongitude;
  String? selectedAddress;
  BitmapDescriptor? customMarkerIcon;
  BitmapDescriptor? currentLocationMarker;
  bool _mapLoaded = false;
  bool _isFetchingAddress = false;
  bool _isInitialLoad = true;

  @override
  void initState() {
    // Register the observer
    WidgetsBinding.instance.addObserver(this);
    _checkAndRequestLocationPermission();
    _fetchCustomMarker();_loadCustomMarkerIcon();
    super.initState();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    // Unregister the observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Future<String> _getAddressFromLatLng(
  //     double latitude, double longitude) async {
  //   try {
  //     List<Placemark> placemarks =
  //     await placemarkFromCoordinates(latitude, longitude);
  //     if (placemarks.isNotEmpty) {
  //       Placemark place = placemarks.first;
  //       // Format the address according to UK standard
  //       return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  //     }
  //   } catch (e) {
  //     print(e);
  //     return "Address not found";
  //   }
  //   return "Unknown Address";
  // }
  Future<void> _getAddressAndUpdateUI(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
        setState(() {
          selectedAddress =
              address; // Update the state with the fetched address
        });
      } else {
        setState(() {
          selectedAddress = "Address not found";
        });
      }
    } catch (e) {
      setState(() {
        selectedAddress = "Address retrieval failed";
      });
    }
  }
  Future<void> _fetchCustomMarker() async {
    try {
      customMarkerIcon = await getCustomMarker();
    } catch (e) {
      print("Error fetching custom marker icon: $e");
    }
  }
  Future<BitmapDescriptor> getCustomMarker() async {
    String svgData = await rootBundle.loadString('assets/svgs/ic_dest.svg');
    int width = 100;
    int height = 100;
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgData), null);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    canvas.scale(
        width / pictureInfo.size.width, height / pictureInfo.size.height);
    canvas.drawPicture(pictureInfo.picture);
    final ui.Picture scaledPicture = recorder.endRecording();
    final image = await scaledPicture.toImage(width, height);
    final ByteData? byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List byteList = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(byteList);
  }

  Future<void> _loadCustomMarkerIcon() async {
    currentLocationMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      AppConstants.currentLocationMarker,
    );

    // customMarkerIcon = await BitmapDescriptor.fromAssetImage(
    //   ImageConfiguration(devicePixelRatio: 2.5),
    //   AppConstants.customMarker,
    // );
  }

  // App lifecycle changes handling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is back in the foreground, check the location permission again
      _checkAndRequestLocationPermission();
    }
  }

  // Method to check and request permission
  Future<void> _checkAndRequestLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDisabledDialog();
      return;
    }

    // Request location permission
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // If permission is granted, fetch the current location
      _getCurrentLocation();
    } else if (permission == LocationPermission.denied) {
      // Permission is denied, show a dialog or try again
      _showPermissionDeniedDialog();
    } else if (permission == LocationPermission.deniedForever) {
      // If permission is permanently denied, show a settings dialog
      _showPermissionPermanentlyDeniedDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (!mounted) return;

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _markers.removeWhere((marker) => marker.markerId == MarkerId('userLocation'));
      _markers.add(
        Marker(
          markerId: MarkerId('userLocation'),
          icon: currentLocationMarker ?? BitmapDescriptor.defaultMarker,
          position: _initialPosition,
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    });

    // Only animate the camera on first load
    if (_isInitialLoad) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_initialPosition),
      );
      _isInitialLoad = false;
    }
  }
  // Show dialog if location services are disabled
  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Services Disabled"),
          content: Text(
              "Location services are disabled. Please enable them in settings."),
          actions: <Widget>[
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                Geolocator.openLocationSettings();
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show dialog if permission is denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission Denied"),
          content: Text(
              "Location access is needed to show your location on the map."),
          actions: <Widget>[
            TextButton(
              child: Text("Ask Again"),
              onPressed: () {
                Navigator.of(context).pop();
                _checkAndRequestLocationPermission();
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show dialog if permission is permanently denied
  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission Permanently Denied"),
          content: Text(
              "You have permanently denied location access. Please go to settings to allow access."),
          actions: <Widget>[
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                openAppSettings();
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show dialog if permission is restricted (mostly iOS)
  void _showPermissionRestrictedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Permission Restricted"),
          content: Text("Location access is restricted and cannot be granted."),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                setState(() => _mapLoaded = true);
              },
              onTap: (LatLng tappedLocation) async {
                if (!_mapLoaded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Map is still loading, please wait.')),
                  );
                  return;
                }
                setState(() {
                  _markers.removeWhere((marker) =>
                      marker.markerId == MarkerId('tappedLocation'));
                  _markers.add(
                    Marker(
                      icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
                      markerId: MarkerId('tappedLocation'),
                      position: tappedLocation,
                      infoWindow: InfoWindow(title: 'Selected Location'),
                    ),
                  );
                  selectedLatitude = tappedLocation.latitude.toString();
                  selectedLongitude = tappedLocation.longitude.toString();
                  _isFetchingAddress = true;
                });

                await _getAddressAndUpdateUI(
                    tappedLocation.latitude, tappedLocation.longitude);

                if (!_isDisposed) {
                  setState(() => _isFetchingAddress = false);
                }
              },
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 15,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );
                LatLng currentLocation =
                    LatLng(position.latitude, position.longitude);
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(currentLocation, 14.0),
                );
              },
              child: Icon(Icons.my_location, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 29,
            left: 100,
            right: 100,
            child: AbsorbPointer(
              absorbing: _isFetchingAddress || selectedAddress == null,
              child: Opacity(
                opacity:
                    (_isFetchingAddress || selectedAddress == null) ? 0.5 : 1.0,
                child: GestureDetector(
                  onTap: () {
                    if (selectedLatitude != null &&
                        selectedLongitude != null &&
                        selectedAddress != null) {
                      Navigator.of(context).pop({
                        'latitude': selectedLatitude!,
                        'longitude': selectedLongitude!,
                        'address': selectedAddress!,
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Color(0xFFF96222)),
                    height: 50,
                    child: Center(
                      child: _isFetchingAddress
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Save Location'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: AppBar(
                centerTitle: true,
                title: widget.isFromFestival
                    ? Text("Add Festival's Location",
                        style: TextStyle(
                          fontFamily: "Ubuntu",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ))
                    : Text("Add Stall's Location",
                        style: TextStyle(
                          fontFamily: "Ubuntu",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                leading: IconButton(
                  icon: SvgPicture.asset(AppConstants.backIcon),
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
