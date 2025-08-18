import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/appConstants.dart';
import '../../../providers/menuProvider.dart';
import '../../../utilities/reviewsScaffoldBackground.dart';
import 'review.dart';
import '../../../annim/transiton.dart';

class StallMenu extends StatefulWidget {
  final String stallId;
  const StallMenu({super.key, required this.stallId});

  @override
  State<StallMenu> createState() => _StallMenuState();
}

class _StallMenuState extends State<StallMenu> {
  Future<void>? _menuFuture;
  
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<dynamic> _filteredMenuItems = [];

  Future<void> _fetchMenu() async {
    try {
      await Provider.of<MenuProvider>(context, listen: false)
          .fetchMenuByStall(context, widget.stallId, isfromReviewSection: true);
    } catch (error) {
      print("Failed to fetch menu: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    _menuFuture = _fetchMenu();
    
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
        _filteredMenuItems = [];
      });
      return;
    }

    // Get the current menu provider
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    
    // Filter menu items based on search query
    final filtered = menuProvider.menuItemsByStall.where((menuItem) {
      final dishName = (menuItem.dishName ?? '').toLowerCase();
      final dishPrice = (menuItem.dishPrice ?? '').toLowerCase();
      
      return dishName.contains(query) || 
             dishPrice.contains(query);
    }).toList();

    setState(() {
      _filteredMenuItems = filtered;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _filteredMenuItems = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final menuProvider = Provider.of<MenuProvider>(context);

    return ReviewsScaffold(
      customAppbar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        title: Text(
          "Menu",
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
      child: FutureBuilder<void>(
        future: _menuFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
                strokeWidth: 2,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load menu: ${snapshot.error}",
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

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
                      hintText: "Search menu items...",
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
                        "Search Results (${_filteredMenuItems.length})",
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
                child: _buildContent(snapshot, menuProvider, screenWidth, screenHeight),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(AsyncSnapshot<void> snapshot, MenuProvider menuProvider, double screenWidth, double screenHeight) {
    if (_isSearching && _filteredMenuItems.isEmpty) {
      return _buildNoResultsWidget();
    }
    
    final menuItems = _isSearching ? _filteredMenuItems : menuProvider.menuItemsByStall;
    
    if (menuItems.isEmpty) {
      return _buildNoMenuItemsWidget();
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final menuItem = menuItems[index];

          return Container(
            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.04,
            ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // ✅ Makes sure text doesn't overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuItem.dishName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: "inter-bold",
                          fontSize: screenWidth * 0.05,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        "Price : ${menuItem.dishPrice}",
                        style: TextStyle(
                          fontFamily: "inter-regular",
                          fontSize: screenWidth * 0.04,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8), // Optional spacing
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.05,
                    ),
                  ),
                  onPressed: () {
                    // Clear search and unfocus keyboard
                    _clearSearch();
                    // Navigate to review
                    Navigator.push(
                      context,
                      FadePageRouteBuilder(widget: Review(menuId: menuItem.id.toString())),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "OPEN",
                        style: TextStyle(
                          fontFamily: "inter-semibold",
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
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
            "No menu items found",
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

  Widget _buildNoMenuItemsWidget() {
    return const Center(
      child: Text(
        "There is nothing to show",
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }
}


