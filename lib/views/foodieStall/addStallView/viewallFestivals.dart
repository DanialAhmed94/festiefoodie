import 'dart:async';

import 'package:festiefoodie/views/foodieStall/addStallView/StallsbyFestival.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../annim/transiton.dart';
import '../../../apis/festivalCollection/getFestivalCollection.dart';
import '../../../constants/appConstants.dart';
import '../../../models/festivalModel.dart';
import '../../../providers/festivalProvider.dart';
import '../../../utilities/connectivityServices.dart';
import '../../../utilities/festivalLocalSearch.dart';
import '../../../utilities/festivalSearchErrorMessage.dart';
import '../../../utilities/scaffoldBackground.dart';

class ViewAllFestivals extends StatefulWidget {
  const ViewAllFestivals({super.key});

  @override
  State<ViewAllFestivals> createState() => _ViewAllFestivalsState();
}

class _ViewAllFestivalsState extends State<ViewAllFestivals> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;
  bool _isSearching = false;
  bool _isSearchingApi = false;
  String? _searchErrorApi;
  List<FestivalResource> _searchResultFestivals = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollNearEnd);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FestivalProvider>(context, listen: false).fetchFestivals(context);
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollNearEnd);
    _scrollController.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScrollNearEnd() {
    if (!mounted) return;
    if (_searchController.text.trim().isNotEmpty) return;
    final p = Provider.of<FestivalProvider>(context, listen: false);
    if (!p.hasMore || p.isLoadingMore || p.isFetching) return;
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final threshold = 280.0;
    final nearEnd = pos.pixels >= pos.maxScrollExtent - threshold;
    if (nearEnd) {
      debugPrint(
          '📄 ViewAllFestivals scroll: trigger loadMore '
          'pixels=${pos.pixels.toStringAsFixed(0)} max=${pos.maxScrollExtent.toStringAsFixed(0)} '
          'hasMore=${p.hasMore} list=${p.festivals.length}');
      p.loadMore(context);
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
        _isSearchingApi = false;
      });
      return;
    }

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

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _searchResultFestivals = [];
      _searchErrorApi = null;
      _isSearchingApi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Consumer<FestivalProvider>(
        builder: (context, festivalProvider, child) {
          return Column(
            children: [
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              if (_isSearching) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: const Color(0xFFF96222),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isSearchingApi
                              ? 'Searching…'
                              : 'Search Results (${_searchResultFestivals.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: _buildFestivalBody(festivalProvider),
              ),
              if (!_isSearching && festivalProvider.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFFF96222),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFestivalBody(FestivalProvider festivalProvider) {
    final query = _searchController.text.trim();

    if (!_isSearching &&
        festivalProvider.isFetching &&
        festivalProvider.festivals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF96222)),
        ),
      );
    }

    if (_isSearching && _isSearchingApi && query.isNotEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF96222),
        ),
      );
    }

    if (_isSearching &&
        !_isSearchingApi &&
        query.isNotEmpty &&
        _searchResultFestivals.isEmpty) {
      return _buildNoResultsWidget();
    }

    final list =
        _isSearching ? _searchResultFestivals : festivalProvider.festivals;
    if (list.isEmpty) {
      return _buildNoFestivalsWidget();
    }

    final showLoadMoreFooter =
        !_isSearching && festivalProvider.isLoadingMore;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      itemCount: list.length + (showLoadMoreFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (showLoadMoreFooter && index == list.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFF96222),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading more festivals…',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          );
        }

        final festival = list[index];
        final title = festival.nameOrganizer ?? festival.description;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              _clearSearch();
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
          if (_searchErrorApi != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _searchErrorApi!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
