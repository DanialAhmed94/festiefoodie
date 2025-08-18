import 'package:festiefoodie/annim/transiton.dart';
import 'package:festiefoodie/constants/appConstants.dart';
import 'package:festiefoodie/views/foodieStall/addStallView/stallDetailView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../models/allStallsCollectionModel.dart';
import '../../../providers/stallProvider.dart';
import '../../../utilities/scaffoldBackground.dart';

class ViewAllStallsView extends StatefulWidget {
  final String festivalId;

  const ViewAllStallsView({Key? key, required this.festivalId})
      : super(key: key);

  @override
  State<ViewAllStallsView> createState() => _ViewAllStallsViewState();
}

class _ViewAllStallsViewState extends State<ViewAllStallsView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<Stall> _filteredStalls = [];

  @override
  void initState() {
    super.initState();
    // Fetch stalls by festival on every visit.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StallProvider>(context, listen: false).fetchStallsByFestival(
          context, widget.festivalId,
          isfromReviewSection: false);
    });
    
    // Listen to search controller changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    
    if (query.isEmpty) {
      setState(() {
        _filteredStalls = [];
      });
      return;
    }

    // Get the current stall provider
    final stallProvider = Provider.of<StallProvider>(context, listen: false);
    
    // Filter stalls based on search query
    final filtered = stallProvider.stallsByFestival.where((stall) {
      final stallName = (stall.stallName ?? '').toLowerCase();
      final festivalName = (stall.festivalName ?? '').toLowerCase();
      
      return stallName.contains(query) || 
             festivalName.contains(query);
    }).toList();

    setState(() {
      _filteredStalls = filtered;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _filteredStalls = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Consumer<StallProvider>(
        builder: (context, stallProvider, child) {
          return Column(
            children: [
              // AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                title: const Text(
                  "All Stalls",
                  style: TextStyle(
                    fontFamily: "inter-semibold",
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: SvgPicture.asset(AppConstants.backIcon, height: 50),
                ),
              ),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      hintText: "Search stalls...",
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

              // Search Results Header
              if (_isSearching) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: const Color(0xFFF96222),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Search Results (${_filteredStalls.length})",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Content
              Expanded(
                child: _buildContent(stallProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(StallProvider stallProvider) {
    if (stallProvider.isFetching && stallProvider.stallsByFestival.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF96222)),
        ),
      );
    } else if (stallProvider.errorMessage != null && stallProvider.stallsByFestival.isEmpty) {
      return Center(
        child: Text(
          stallProvider.errorMessage!,
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_isSearching && _filteredStalls.isEmpty) {
      return _buildNoResultsWidget();
    } else if ((_isSearching ? _filteredStalls : stallProvider.stallsByFestival).isEmpty) {
      return _buildNoStallsWidget();
    } else {
      return _buildStallsList(_isSearching ? _filteredStalls : stallProvider.stallsByFestival);
    }
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 60,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No stalls found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try searching with different keywords",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStallsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store,
              size: 60,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No stalls available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for new stalls",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStallsList(List<Stall> stalls) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stalls.length,
      itemBuilder: (context, index) {
        final stall = stalls[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildStallCard(
              context,
              MediaQuery.of(context).size.width * 0.95,
              stall.stallName,
              stall),
        );
      },
    );
  }

  Widget _buildStallCard(
      BuildContext context, double width, String title, Stall stall) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              child: Container(
                width: width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 90),
                    // Reserved space for left border.
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: "inter-semibold",
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          // Clear search and unfocus keyboard
                          _clearSearch();
                          // Navigate to stall details
                          Navigator.push(
                              context,
                              FadePageRouteBuilder(
                                  widget: StallDetailView(
                                closingTime: stall.closingTime,
                                festivalName: stall.festivalName,
                                endDate: stall.toDate,
                                startDate: stall.fromDate,
                                longitude: stall.longitude,
                                latitude: stall.latitude,imageUrl: stall.image,openingTime: stall.openingTime,stallName: stall.stallName,
                              )));
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: const Text(
                          //       "This feature is in development phase.",
                          //       style: TextStyle(
                          //         fontFamily: "inter-medium",
                          //         fontSize: 14,
                          //         color: Colors.white,
                          //       ),
                          //     ),
                          //     backgroundColor: Colors.black87,
                          //     behavior: SnackBarBehavior.floating,
                          //     action: SnackBarAction(
                          //       label: "OK",
                          //       textColor: Colors.orange,
                          //       onPressed: () {},
                          //     ),
                          //   ),
                          // );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text(
                          "View Detail",
                          style: TextStyle(
                            fontFamily: "inter-medium",
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Container(
                  width: 90,
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    AppConstants.stallCardleftborder,
                    height: constraints.maxHeight,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
