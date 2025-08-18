import 'package:flutter/material.dart';
import '../apis/stallManagment/listOFAllRegisteredStalls.dart'; // API for overall stalls collection
import '../apis/stallManagment/stallsbyFestival_api.dart';
import '../models/allStallsCollectionModel.dart'; // Contains your StallResponse, Stall, etc.

class StallProvider extends ChangeNotifier {
  // Overall stalls collection
  List<Stall> _stallsCollection = [];
  // Stalls for a specific festival
  List<Stall> _stallsByFestival = [];
  // Cache the festival id for which stalls are loaded
  String? _currentFestivalId;

  bool _isFetching = false;
  String? _errorMessage;

  // Getters for overall stalls collection
  List<Stall> get stallsCollection => _stallsCollection;
  // Getters for stalls by festival
  List<Stall> get stallsByFestival => _stallsByFestival;
  bool get isFetching => _isFetching;
  String? get errorMessage => _errorMessage;

  // Fetch overall stalls collection
  Future<void> fetchStallsCollection(BuildContext context, {bool forceRefresh = false}) async {
    if (!forceRefresh && _stallsCollection.isNotEmpty) {
      // Data is already cached; no need to fetch again.
      return;
    }

    _isFetching = true;
    notifyListeners();

    final response = await getStallCollection(context);
    _isFetching = false;

    if (response != null) {
      _stallsCollection = response.data.stalls; // Assuming your model contains a list of stalls.
      _errorMessage = null;
    } else {
      _errorMessage = "Failed to fetch stalls.";
      // Optionally clear the list on error if needed.
    }
    notifyListeners(); // <--- Important so UI updates after API response
  }
  Future<bool> fetchStallsByFestival(BuildContext context, String festivalId, {required bool isfromReviewSection}) async {
    _isFetching = true;
    _errorMessage = null;
    _stallsByFestival = [];
    notifyListeners();

    final response = await getStallsByFestival(context, festivalId, isfromReviewSection: isfromReviewSection);

    _isFetching = false;

    if (response != null) {
      _stallsByFestival = response.data.stalls;
      _currentFestivalId = festivalId;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _stallsByFestival = [];
      _errorMessage = "Failed to fetch stalls for this festival.";
      notifyListeners();
      return false;
    }
  }

  // Fetch stalls for a specific festival. creating stall working fine
  // Future<void> fetchStallsByFestival(BuildContext context, String festivalId, {required bool isfromReviewSection}) async {
  //   _stallsByFestival = [];
  //   _errorMessage = null;
  //   _isFetching = true;
  //   notifyListeners();  // <-- To show loader
  //
  //   final response = await getStallsByFestival(context, festivalId, isfromReviewSection:isfromReviewSection );
  //   _isFetching = false;
  //
  //   if (response != null) {
  //     _stallsByFestival = response.data.stalls; // Assuming similar parsing as overall collection.
  //     _currentFestivalId = festivalId;
  //     _errorMessage = null;
  //   } else {
  //     _errorMessage = "Failed to fetch stalls for this festival.";
  //   }
  //   _isFetching = false;
  //   notifyListeners();  // <-- To show loader
  //
  // }
}
