import 'package:flutter/material.dart';

import '../apis/festivalCollection/getFestivalCollection.dart';
import '../models/festivalModel.dart';



// Import your model

class FestivalProvider extends ChangeNotifier {
  List<FestivalResource> _festivals = [];
  int _totalFestivals = 0;
  int _totalAttendees = 0;
  bool _isFetching = false; // <-- Track loading state

  bool get isFetching => _isFetching;
  List<FestivalResource> get festivals => _festivals;



  // Fetch festivals and update the list,
  Future<void> fetchFestivals(BuildContext context) async {

    _isFetching = true;
    notifyListeners(); // <--- Notify to show loader

    final response = await getFestivalCollection(context);
    _isFetching = false;     // Done loading
    if (response != null) {
      _festivals = response.data;


    }
    _isFetching = false;
    notifyListeners(); // <--- Notify to update UI after API
  }

}
