import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MenuItem {
  final TextEditingController dishNameController;
  final TextEditingController priceController;
  XFile? selectedImage;
  bool isImageSelected;
  bool isCompressing; // Add compression state property
  String selectedCurrency; // Add currency property
  String currencySymbol; // Add currency symbol property

  MenuItem({
    required this.dishNameController,
    required this.priceController,
    this.selectedImage,
    this.isImageSelected = false,
    this.isCompressing = false, // Default compression state
    this.selectedCurrency = 'GBP', // Default currency
    this.currencySymbol = '£', // Default symbol
  });
}