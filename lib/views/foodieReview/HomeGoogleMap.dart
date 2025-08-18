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
  bool _showLoadingOverlay = true;
  
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<FestivalResource> _filteredFestivals = [];
  OverlayEntry? _searchOverlay;

  @override
  void initState() {
    super.initState();
    _setupMap();
    _fetchCustomMarker();

    // Show loading overlay for exactly 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showLoadingOverlay = false;
        });
      }
    });
    
    // Listen to search controller changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchOverlay?.remove();
    super.dispose();
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
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    
    if (query.isEmpty) {
      setState(() {
        _filteredFestivals = [];
      });
      _hideSearchOverlay();
      return;
    }

    // Get the current festival provider
    final festivalProvider = Provider.of<FestivalProvider>(context, listen: false);
    
    // Filter festivals based on search query
    final filtered = festivalProvider.festivals.where((festival) {
      final nameOrganizer = (festival.nameOrganizer ?? '').toLowerCase();
      final description = (festival.description ?? '').toLowerCase();
      final descriptionOrganizer = (festival.descriptionOrganizer ?? '').toLowerCase();
      
      return nameOrganizer.contains(query) || 
             description.contains(query) || 
             descriptionOrganizer.contains(query);
    }).toList();

    setState(() {
      _filteredFestivals = filtered;
    });
    
    _showSearchOverlay();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _filteredFestivals = [];
    });
    _hideSearchOverlay();
  }

  void _showSearchOverlay() {
    _hideSearchOverlay(); // Remove existing overlay first
    
    if (_filteredFestivals.isEmpty) return;
    
    _searchOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 140, // Below search bar
        left: 16,
        right: 16,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _filteredFestivals.length,
              itemBuilder: (context, index) {
                final festival = _filteredFestivals[index];
                final title = festival.nameOrganizer ?? festival.description;
                
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF96222).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.festival,
                      color: const Color(0xFFF96222),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    festival.descriptionOrganizer ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _navigateToFestival(festival),
                );
              },
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_searchOverlay!);
  }

  void _hideSearchOverlay() {
    _searchOverlay?.remove();
    _searchOverlay = null;
  }

  void _navigateToFestival(FestivalResource festival) {
    try {
      final latitude = double.parse(festival.latitude);
      final longitude = double.parse(festival.longitude);
      final festivalLatLng = LatLng(latitude, longitude);
      
      // Navigate to festival with same zoom level as nearest festival (13)
      _controller.animateCamera(
        CameraUpdate.newLatLngZoom(festivalLatLng, 13),
      );
      
      // Clear search
      _clearSearch();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Navigated to ${festival.nameOrganizer ?? festival.description}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF96222), // Brand orange color
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to festival: $e');
    }
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
        // Loading overlay to prevent blue screen flash
        if (_showLoadingOverlay)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF96222).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.map,
                        size: 60,
                        color: const Color(0xFFF96222),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "FestieFoodie is global, hold tight while we load the map.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF96222)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Search Bar
        Positioned(
          top: MediaQuery.of(context).size.height * 0.11,
          left: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: "Search festivals...",
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search,
                    color: const Color(0xFFF96222),
                    size: 24,
                  ),
                ),
                suffixIcon: _isSearching
                    ? Container(
                        margin: const EdgeInsets.all(12),
                        child: GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey[600],
                              size: 18,
                            ),
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFF96222),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.18,
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
