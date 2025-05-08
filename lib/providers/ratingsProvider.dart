import 'package:flutter/material.dart';
import '../apis/getRatings/getDishRatings.dart';
import '../models/raringsModel.dart'; // Make sure this includes the updated model

class RatingsProvider extends ChangeNotifier {
  List<ReviewData> _reviews = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isFetching = false;
  bool _isFetchingMore = false;
  String? _errorMessage;

  // Getters
  List<ReviewData> get reviews => _reviews;
  bool get isFetching => _isFetching;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMorePages => _currentPage < _lastPage;
  String? get errorMessage => _errorMessage;

  /// Fetch first page of reviews
  Future<void> fetchInitialRatings(BuildContext context, String dishId) async {
    _isFetching = true;
    _errorMessage = null;
    _currentPage = 1;
    _reviews.clear();
    notifyListeners();

    final response = await getDishRatings(context, dishId, page: _currentPage);

    _isFetching = false;

    if (response != null) {
      if (response.reviews != null) {
        _reviews = response.reviews!.data;
        _lastPage = response.reviews!.lastPage;
      } else if (response.flatData != null) {
        _reviews = response.flatData!;
        _lastPage = 1; // only one page if it's flat
      }
    } else {
      _errorMessage = "Failed to fetch reviews.";
    }

    notifyListeners();
  }

  /// Fetch more pages for pagination
  Future<void> fetchMoreRatings(BuildContext context, String dishId) async {
    if (_isFetchingMore || !hasMorePages) return;

    _isFetchingMore = true;
    _errorMessage = null;
    notifyListeners();

    _currentPage++;

    final response = await getDishRatings(context, dishId, page: _currentPage);

    _isFetchingMore = false;

    if (response != null && response.reviews != null) {
      _reviews.addAll(response.reviews!.data);
    } else {
      _errorMessage = "Failed to fetch more reviews.";
      _currentPage--; // revert on failure
    }

    notifyListeners();
  }
}
