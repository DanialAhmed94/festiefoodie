import 'package:flutter/material.dart';

import '../apis/menuManagment/getMenuByStalls_api.dart';
import '../models/menuItemModel.dart';
import '../models/menuModel.dart';

class MenuProvider extends ChangeNotifier {
  // Menu Items for specific festival
  List<MenuItemApi> _menuItemsByStall = [];



  bool _isFetching = false;
  String? _errorMessage;

  // Getters
  List<MenuItemApi> get menuItemsByStall => _menuItemsByStall;
  bool get isFetching => _isFetching;
  String? get errorMessage => _errorMessage;

  // Fetch Menu Items for a specific festival
  Future<void> fetchMenuByStall(BuildContext context, String stallId,{required bool isfromReviewSection}) async {
    _menuItemsByStall = [];
    _errorMessage = null;



    final response = await getMenuByStall(context, stallId,isfromReviewSection:isfromReviewSection);
    _isFetching = false;

    if (response != null) {
      _menuItemsByStall = response.data; // Direct List<MenuItem>

      _errorMessage = null;
    } else {
      _errorMessage = "Failed to fetch menu items for this festival.";
    }
    notifyListeners();
  }
}
