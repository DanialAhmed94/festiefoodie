import 'package:festiefoodie/views/foodieStall/addStallView/StallsbyFestival.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../annim/transiton.dart';
import '../../../constants/appConstants.dart';
import '../../../providers/festivalProvider.dart';
import '../../../utilities/scaffoldBackground.dart';

class ViewAllFestivals extends StatefulWidget {
  const ViewAllFestivals({super.key});

  @override
  State<ViewAllFestivals> createState() => _ViewAllFestivalsState();
}

class _ViewAllFestivalsState extends State<ViewAllFestivals> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<dynamic> _filteredFestivals = [];

  @override
  void initState() {
    super.initState();
    // Fetch festivals once the widget is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FestivalProvider>(context, listen: false).fetchFestivals(context);
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
        _filteredFestivals = [];
      });
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
    
    // Debug print to verify filtering is working
    print('Search query: "$query"');
    print('Total festivals: ${festivalProvider.festivals.length}');
    print('Filtered festivals: ${_filteredFestivals.length}');
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _filteredFestivals = [];
    });
    print('Search cleared - showing all festivals');
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Consumer<FestivalProvider>(
        builder: (context, festivalProvider, child) {
          return Column(
              children: [
              // AppBar
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: const Text(
                    "Festivals",
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
                        "Search Results (${_filteredFestivals.length})",
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
                child: festivalProvider.isFetching && festivalProvider.festivals.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF96222)),
                        ),
                      )
                    : _isSearching && _filteredFestivals.isEmpty
                        ? _buildNoResultsWidget()
                        : (_isSearching ? _filteredFestivals : festivalProvider.festivals).isEmpty
                            ? _buildNoFestivalsWidget()
                            : _buildFestivalsList(_isSearching ? _filteredFestivals : festivalProvider.festivals),
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
            "No festivals found",
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

  Widget _buildNoFestivalsWidget() {
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
              Icons.festival,
              size: 60,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No festivals available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for new festivals",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalsList(List<dynamic> festivals) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: festivals.length,
                    itemBuilder: (context, index) {
        final festival = festivals[index];
        final title = festival.nameOrganizer ?? festival.description;
        
                               return Padding(
           padding: const EdgeInsets.only(bottom: 12),
           child: GestureDetector(
             onTap: () {
               // Clear search and unfocus keyboard
               _clearSearch();
               // Navigate to stalls
               Navigator.push(
                 context,
                 FadePageRouteBuilder(
                   widget: ViewAllStallsView(festivalId: festival.id.toString()),
                 ),
               );
             },
             child: _buildFestivalCard(
               context,
               MediaQuery.of(context).size.width * 0.95,
               title,
             ),
           ),
         );
                    },
    );
  }

  Widget _buildFestivalCard(BuildContext context, double width, String title) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth;
        final double leftBorderWidth = cardWidth * 0.2;
        
        return Stack(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: leftBorderWidth),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Festival Name:",
                            style: TextStyle(
                              fontFamily: "inter-bold",
                              fontSize: 16,
                              color: Color(0xFFF96222),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: "inter-semibold",
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      child: IconButton(
                        onPressed: null,
                        icon: SvgPicture.asset(AppConstants.forwardIcon),
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
                  width: leftBorderWidth,
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
