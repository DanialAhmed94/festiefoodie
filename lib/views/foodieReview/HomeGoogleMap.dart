import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../apis/festivalCollection/getFestivalCollection.dart';
import '../../models/festivalModel.dart';
import '../../providers/festivalProvider.dart';
import '../../utilities/connectivityServices.dart';
import '../../utilities/festivalLocalSearch.dart';
import '../../utilities/festivalSearchErrorMessage.dart';
import '../../utilities/getUserLocation.dart';
import '../foodieStall/mapViews/LocationMap.dart';
import 'widgets/modalBottomSheet.dart';
import 'package:provider/provider.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({
    Key? key,
    /// Pushes search + Nearest below overlays drawn on top of this widget
    /// (e.g. the “Your Location” strip in [FoodieReviewHomeMap]).
    this.contentTopInset = 0,
  }) : super(key: key);

  final double contentTopInset;

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
  
  // Search — server API (`/getfestival?page=&search=`), same pattern as festival-toilet map
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  bool _isSearching = false;
  bool _showSearchResults = false;
  bool _isSearchingApi = false;
  String? _searchErrorApi;
  List<FestivalResource> _searchResultFestivals = [];

  @override
  void initState() {
    super.initState();
    // Defer _setupMap to after the first frame so fetchFestivals() never calls notifyListeners() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _setupMap();
    });
    _fetchCustomMarker();

    // Show loading overlay for exactly 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showLoadingOverlay = false;
        });
      }
    });

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
  void _onSearchFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_searchFocusNode.hasFocus) {
          setState(() => _showSearchResults = false);
        }
      });
    } else if (_searchController.text.isNotEmpty) {
      setState(() => _showSearchResults = true);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _searchDebounce?.cancel();

    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResultFestivals = [];
        _searchErrorApi = null;
        _showSearchResults = false;
        _isSearchingApi = false;
      });
      return;
    }

    setState(() => _showSearchResults = true);
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _performSearchApi(query);
    });
  }

  Future<void> _performSearchApi(String query) async {
    if (!mounted) return;

    final festivalProvider =
        Provider.of<FestivalProvider>(context, listen: false);
    final hasLocalFestivals = festivalProvider.festivals.isNotEmpty;
    final online = await checkInternetConnection();

    if (!online && hasLocalFestivals) {
      setState(() {
        _searchResultFestivals =
            filterFestivalsLocally(festivalProvider.festivals, query);
        _isSearchingApi = false;
        _searchErrorApi = null;
      });
      return;
    }

    setState(() {
      _isSearchingApi = true;
      _searchErrorApi = null;
    });
    try {
      final response = await fetchFestivalsWithQuery(page: 1, search: query);
      if (!mounted) return;
      setState(() {
        _searchResultFestivals = response.data;
        _isSearchingApi = false;
        _searchErrorApi = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchResultFestivals = [];
        _isSearchingApi = false;
        _searchErrorApi = messageForFestivalSearchFailure(e);
      });
    }
  }

  void _dismissSearchUi() {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _showSearchResults = false;
      _searchResultFestivals = [];
      _searchErrorApi = null;
      _isSearchingApi = false;
    });
  }

  void _clearSearch() {
    _searchFocusNode.unfocus();
    _dismissSearchUi();
  }

  String _festivalDisplayName(FestivalResource festival) {
    final name = festival.nameOrganizer?.trim();
    if (name != null && name.isNotEmpty && name.toLowerCase() != 'n/a') {
      return name;
    }
    final desc = festival.description.trim();
    if (desc.isNotEmpty && desc.toLowerCase() != 'n/a') {
      return desc;
    }
    return 'Festival';
  }

  void _onSearchSubmitted(String value) {
    if (_searchResultFestivals.isNotEmpty) {
      _navigateToFestival(_searchResultFestivals.first);
    } else {
      _dismissSearchUi();
    }
  }

  void _navigateToFestival(FestivalResource festival) {
    try {
      final latitude = double.parse(festival.latitude);
      final longitude = double.parse(festival.longitude);
      final festivalLatLng = LatLng(latitude, longitude);

      _clearSearch();

      _controller.animateCamera(
        CameraUpdate.newLatLngZoom(festivalLatLng, 13),
      );

      setState(() {
        _markers.removeWhere((m) => m.markerId.value == 'selectedFestival');
        _markers.add(
          Marker(
            markerId: const MarkerId('selectedFestival'),
            position: festivalLatLng,
            infoWindow: InfoWindow(title: _festivalDisplayName(festival)),
            icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
            onTap: () => showMarkerInfo(context, festival),
          ),
        );
      });

      showMarkerInfo(context, festival);
      
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

  Future<void> _onFindNearestFestival() async {
    _dismissSearchUi();
    final nearestFestival = _findNearestFestival();
    if (nearestFestival == null) return;
    final festivalLatLng = LatLng(
      double.parse(nearestFestival.latitude),
      double.parse(nearestFestival.longitude),
    );
    await _controller.animateCamera(
      CameraUpdate.newLatLngZoom(festivalLatLng, 13),
    );
    if (!mounted) return;
    setState(() {
      _markers.add(
        Marker(
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          markerId: const MarkerId('nearestFestival'),
          position: festivalLatLng,
          infoWindow: InfoWindow(
            title: nearestFestival.nameOrganizer ?? nearestFestival.description,
          ),
        ),
      );
    });
  }

  Future<void> _fetchCustomMarker() async {
    try {
      _customMarkerIcon = await getCustomMarker();
    } catch (e) {
      print("Error fetching custom marker icon: $e");
    }
  }

  /// Fixed height so [Column] + [Expanded] [ListView] get bounded constraints.
  Widget _buildSearchResultsPanel(double panelHeight) {
    return SizedBox(
      height: panelHeight,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFF96222).withOpacity(0.2),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _isSearchingApi
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFFF96222),
                        ),
                      ),
                    ),
                  )
                : _searchResultFestivals.isNotEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  size: 16,
                                  color: Color(0xFFF96222),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Search results (${_searchResultFestivals.length})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              itemCount: _searchResultFestivals.length,
                              itemBuilder: (context, index) {
                                final festival = _searchResultFestivals[index];
                                return ListTile(
                                  dense: true,
                                  leading: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF96222)
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.festival,
                                      color: Color(0xFFF96222),
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    _festivalDisplayName(festival),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    festival.descriptionOrganizer ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    _navigateToFestival(festival);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_searchErrorApi != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _searchErrorApi!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              Icon(
                                Icons.search_off,
                                size: 36,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No festivals found',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try different keywords',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchPanelHeight = MediaQuery.of(context).size.height * 0.35;
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
          onTap: (_) => _dismissSearchUi(),
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
                      "Festival Foodie is global, hold tight while we load the map.",
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
        // Search + Nearest on one row; results panel below (no overlap)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8 + widget.contentTopInset,
                16,
                0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 52,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
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
                              textInputAction: TextInputAction.search,
                              onSubmitted: _onSearchSubmitted,
                              onTap: () {
                                if (_searchController.text.isNotEmpty) {
                                  setState(() => _showSearchResults = true);
                                }
                              },
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: "Search festivals...",
                                isDense: true,
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Icon(
                                    Icons.search,
                                    color: const Color(0xFFF96222),
                                    size: 22,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 44,
                                ),
                                suffixIcon: _isSearching
                                    ? IconButton(
                                        visualDensity: VisualDensity.compact,
                                        onPressed: _clearSearch,
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.grey[600],
                                          size: 20,
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
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          shadowColor: Colors.black26,
                          color: const Color(0xFFF96222),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _onFindNearestFestival(),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.near_me,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Nearest',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showSearchResults &&
                      _searchController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildSearchResultsPanel(searchPanelHeight),
                  ],
                ],
              ),
            ),
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
