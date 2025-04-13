import 'package:flutter/material.dart';

import '../apis/eventCollection/eventCollection_api.dart';
import '../models/eventModel.dart';


class EventProvider extends ChangeNotifier {
  List<EventData> _events = [];
  bool _isFetching = false; // <-- Track loading state
  bool get isFetching => _isFetching;

  List<EventData> get events => _events;

  // Fetch events from the API and notify listeners
  Future<void> fetchEvents(BuildContext context,String festivalId) async {
    _isFetching = true;      // Start loading
    notifyListeners();
    final response = await getEventsCollection(context,festivalId);
    _isFetching = false;     // Done loading

    if (response != null) {
      _events = response.data;
      notifyListeners();
    }
  }


}
