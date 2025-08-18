import 'package:festiefoodie/annim/transiton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/appConstants.dart';
import '../../../providers/stallProvider.dart';
import '../../../utilities/reviewsScaffoldBackground.dart';
import 'stallMenu.dart';
import 'package:cached_network_image/cached_network_image.dart';
class FestivalStalls extends StatefulWidget {
  const FestivalStalls({required this.festivalId});
  final String festivalId;

  @override
  State<FestivalStalls> createState() => _FestivalStallsState();
}

class _FestivalStallsState extends State<FestivalStalls> {
  late Future<void> _stallFuture;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<dynamic> _filteredStalls = [];

  @override
  void initState() {
    super.initState();
    _stallFuture = Provider.of<StallProvider>(context, listen: false)
        .fetchStallsByFestival(context, widget.festivalId,isfromReviewSection: true);
    
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
      final fromDate = (stall.fromDate ?? '').toLowerCase();
      final toDate = (stall.toDate ?? '').toLowerCase();
      
      return stallName.contains(query) || 
             fromDate.contains(query) ||
             toDate.contains(query);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ReviewsScaffold(
      customAppbar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        title: Text(
          "Stalls",
          style: TextStyle(
            fontFamily: "inter-semibold",
            fontSize: screenWidth * 0.08,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(AppConstants.backIcon),
        ),
        leadingWidth: 40,
      ),
      child: FutureBuilder(
        future: _stallFuture,
        builder: (context, snapshot) {
          final stalls = Provider.of<StallProvider>(context).stallsByFestival;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return Column(
            children: [
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
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Content
              Expanded(
                child: isLoading
                    ? Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
                        ),
                      )
                    : _isSearching && _filteredStalls.isEmpty
                        ? _buildNoResultsWidget()
                        : (_isSearching ? _filteredStalls : stalls).isEmpty
                            ? _buildNoStallsWidget()
                            : _buildStallsList(_isSearching ? _filteredStalls : stalls, screenWidth, screenHeight),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No stalls found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try searching with different keywords",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStallsWidget() {
            return const Center(
              child: Text(
                "There is nothing to show",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "inter-semibold",
                  color: Colors.black54,
                ),
              ),
            );
          }

  Widget _buildStallsList(List<dynamic> stalls, double screenWidth, double screenHeight) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: ListView.builder(
              itemCount: stalls.length,
              itemBuilder: (context, index) {
                final stall = stalls[index];

                return Container(
                  margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stall.stallName,
                              style: TextStyle(
                                fontFamily: "inter-bold",
                                fontSize: screenWidth * 0.05,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              "From: ${stall.fromDate}",
                              style: TextStyle(
                                fontFamily: "inter-regular",
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "To: ${stall.toDate}",
                              style: TextStyle(
                                fontFamily: "inter-regular",
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                  horizontal: screenWidth * 0.06,
                                ),
                              ),
                              onPressed: () {
                          // Clear search and unfocus keyboard
                          _clearSearch();
                          // Navigate to stall menu
                                Navigator.push(
                                  context,
                                  FadePageRouteBuilder(widget: StallMenu(stallId: stall.id.toString(),)),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "OPEN",
                                    style: TextStyle(
                                      fontFamily: "inter-semibold",
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  const Icon(Icons.arrow_forward,
                                      color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: stall.image,
                          width: screenWidth * 0.25,
                          height: screenHeight * 0.12,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: screenWidth * 0.25,
                            height: screenHeight * 0.12,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              color: Colors.orange,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                        ),
                      )
                    ],
            ),
          );
        },
      ),
    );
  }
}


