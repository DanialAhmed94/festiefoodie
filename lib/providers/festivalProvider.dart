import 'package:flutter/material.dart';

import '../apis/festivalCollection/getFestivalCollection.dart';
import '../models/festivalModel.dart';



// Import your model

class FestivalProvider extends ChangeNotifier {
  List<FestivalResource> _festivals = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isFetching = false;
  bool _isLoadingMore = false;

  bool get isFetching => _isFetching;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _currentPage < _lastPage;
  List<FestivalResource> get festivals => _festivals;

  Future<void> fetchFestivals(BuildContext context) async {
    debugPrint(
        '📄 FestivalProvider.fetchFestivals: start page=1 (replace list), wasLoaded=${_festivals.length}');
    _isFetching = true;
    notifyListeners();

    final response = await getFestivalCollection(context, page: 1);
    _isFetching = false;
    if (response != null) {
      _currentPage = response.currentPage;
      _lastPage = response.lastPage;
      _festivals = response.data;
      debugPrint(
          '📄 FestivalProvider.fetchFestivals: done items=${response.data.length} '
          'currentPage=$_currentPage lastPage=$_lastPage totalInList=${_festivals.length} '
          'hasMore=$hasMore message=${response.message}');
    } else {
      debugPrint('📄 FestivalProvider.fetchFestivals: done response=null (error dialog may have shown)');
    }
    notifyListeners();
  }

  Future<void> loadMore(BuildContext context) async {
    if (_isLoadingMore) {
      debugPrint('📄 FestivalProvider.loadMore: skip (already loading more)');
      return;
    }
    if (!hasMore) {
      debugPrint(
          '📄 FestivalProvider.loadMore: skip (no more pages) currentPage=$_currentPage lastPage=$_lastPage');
      return;
    }

    final nextPage = _currentPage + 1;
    debugPrint(
        '📄 FestivalProvider.loadMore: start requesting page=$nextPage '
        '(currentPage=$_currentPage lastPage=$_lastPage listSize=${_festivals.length})');
    _isLoadingMore = true;
    notifyListeners();
    try {
      final response = await getFestivalCollection(context, page: nextPage);
      if (response != null) {
        final before = _festivals.length;
        _currentPage = response.currentPage;
        _lastPage = response.lastPage;
        _festivals = [..._festivals, ...response.data];
        debugPrint(
            '📄 FestivalProvider.loadMore: done page=${response.currentPage} '
            'batchSize=${response.data.length} listSize $before → ${_festivals.length} '
            'lastPage=$_lastPage hasMore=$hasMore');
      } else {
        debugPrint(
            '📄 FestivalProvider.loadMore: page=$nextPage response=null (error dialog may have shown)');
      }
    } finally {
      _isLoadingMore = false;
      notifyListeners();
      debugPrint(
          '📄 FestivalProvider.loadMore: finished isLoadingMore=false hasMore=$hasMore');
    }
  }
}
