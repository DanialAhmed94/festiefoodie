import 'dart:io';

import 'package:festiefoodie/constants/appConstants.dart';
import 'package:festiefoodie/providers/eventProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../annim/transiton.dart';
import '../../../apis/stallManagment/addStall_api.dart';
import '../../../models/festivalModel.dart';
import '../../../models/menuItemModel.dart';
import '../../../providers/festivalProvider.dart';
import '../../../utilities/scaffoldBackground.dart';
import '../mapViews/LocationMap.dart';
import '../../../utilities/dilalogBoxes.dart'; // Contains showErrorDialog()
import '../../../utilities/imagePickerUtility.dart';
import '../../../utilities/currencyUtility.dart';

class AddStallView extends StatefulWidget {
  const AddStallView({super.key});

  @override
  State<AddStallView> createState() => _AddStallViewState();
}

class _AddStallViewState extends State<AddStallView> {
  String? _selectedFestivalId;
  String? _selectedEventId;

  XFile? _selectedImage;
  bool _isImageSelected = true;
  bool _isCompressingStallImage = false;
  TextEditingController _stallNameController = TextEditingController();
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _openingTimeController = TextEditingController();
  TextEditingController _closingTimeController = TextEditingController();

  List<MenuItem> menuItems = [];

  bool _isSubmitting = false; // Flag for API call status

  @override
  void initState() {
    super.initState();
    // Initialize with one empty menu item
    addMenuItem();
  }

  @override
  void dispose() {
    // Dispose all menu item controllers
    for (var item in menuItems) {
      item.dishNameController.dispose();
      item.priceController.dispose();
    }
    _stallNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  void addMenuItem() {
    setState(() {
      menuItems.add(MenuItem(
        dishNameController: TextEditingController(),
        priceController: TextEditingController(),
        selectedImage: null,
        isImageSelected: false,
        isCompressing: false,
        selectedCurrency: 'GBP',
        currencySymbol: '£',
      ));
    });
  }

  void removeMenuItem(int index) {
    setState(() {
      // Dispose controllers before removing
      menuItems[index].dishNameController.dispose();
      menuItems[index].priceController.dispose();
      menuItems.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePickerUtility.showImageSourceModal(
      context,
      title: "Select Stall Image",
    );

    if (image != null) {
      setState(() {
        _isCompressingStallImage = true;
      });
      
      // Simulate compression time for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _selectedImage = image;
        _isImageSelected = true;
        _isCompressingStallImage = false;
      });
    }
  }

  Future<void> _pickMenuItemImage(int index) async {
    final XFile? image = await ImagePickerUtility.showImageSourceModal(
      context,
      title: "Select Dish Image",
    );

    if (image != null) {
      setState(() {
        menuItems[index].isCompressing = true;
      });
      
      // Simulate compression time for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        menuItems[index].selectedImage = image;
        menuItems[index].isImageSelected = true;
        menuItems[index].isCompressing = false;
      });
    }
  }

  /// Validate fields and call the API
  Future<void> _submitStall() async {
    // Validate required fields (selected event is optional)
    if (_selectedFestivalId == null) {
      showErrorDialog(context, "Please select a festival", []);
      return;
    }
    if (_stallNameController.text.trim().isEmpty) {
      showErrorDialog(context, "Please enter a stall name", []);
      return;
    }
    if (_latitudeController.text.trim().isEmpty) {
      showErrorDialog(context, "Please enter latitude", []);
      return;
    }
    if (_longitudeController.text.trim().isEmpty) {
      showErrorDialog(context, "Please enter longitude", []);
      return;
    }
    if (_startDateController.text.trim().isEmpty) {
      showErrorDialog(context, "Please select a start date", []);
      return;
    }
    if (_endDateController.text.trim().isEmpty) {
      showErrorDialog(context, "Please select an end date", []);
      return;
    }
    if (_openingTimeController.text.trim().isEmpty) {
      showErrorDialog(context, "Please select opening time", []);
      return;
    }
    if (_closingTimeController.text.trim().isEmpty) {
      showErrorDialog(context, "Please select closing time", []);
      return;
    }
    // Ensure at least one valid menu item is added.
    bool hasValidMenuItem = false;
    for (var item in menuItems) {
      if (item.dishNameController.text.trim().isNotEmpty &&
           item.priceController.text.trim().isNotEmpty &&
           item.isImageSelected) {
        hasValidMenuItem = true;
        break;
      }
    }
    if (!hasValidMenuItem) {
       showErrorDialog(context, "Please add at least one complete menu item with dish name, price, and image", []);
      return;
    }
    if (_selectedImage == null) {
      setState(() {
        _isImageSelected = false;
      });
      showErrorDialog(context, "Please select an image", []);
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    try {
      await addStallApi(
        context,
        festivalId: _selectedFestivalId!,
        eventId: _selectedEventId ?? "",
        stallName: _stallNameController.text.trim(),
        latitude: _latitudeController.text.trim(),
        longitude: _longitudeController.text.trim(),
        fromDate: _startDateController.text.trim(),
        toDate: _endDateController.text.trim(),
        openingTime: _openingTimeController.text.trim(),
        closingTime: _closingTimeController.text.trim(),
        image: _selectedImage,
        menuItems: menuItems,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: const Text(
                "Add Food Stall",
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
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFF8F8F8),
                ),
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Select Festival",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 1) Use Consumer to watch isFetching & festivals
                      Consumer<FestivalProvider>(
                        builder: (context, festivalProvider, child) {
                          return DropdownButtonFormField<String>(
                            key: Key(festivalProvider.isFetching.toString()),
                            value: _selectedFestivalId,
                            onTap: () async {
                              if (festivalProvider.festivals.isEmpty &&
                                  !festivalProvider.isFetching) {
                                await festivalProvider.fetchFestivals(context);
                              }
                            },
                            hint: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.6,
                              ),
                              child: const Text(
                                "Choose a festival",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: SvgPicture.asset(
                                AppConstants.festivalPrefix,
                                color: const Color(0xFFF96222),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.only(
                                left: 12,
                                right: 40, // Extra space for dropdown arrow
                                top: 16,
                                bottom: 16,
                            ),
                            ),
                            isExpanded: true,
                            items: festivalProvider.isFetching
                                ? [
                              DropdownMenuItem<String>(
                                value: null,
                                enabled: false,
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text("Loading festivals..."),
                                  ],
                                ),
                              ),
                            ]
                                : festivalProvider.festivals.isNotEmpty
                                ? festivalProvider.festivals.map((festival) {
                              return DropdownMenuItem<String>(
                                value: festival.id.toString(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                    MediaQuery.of(context).size.width * 0.6,
                                  ),
                                child: Text(
                                  festival.nameOrganizer ??
                                        festival.description,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            }).toList()
                                : [
                              DropdownMenuItem<String>(
                                value: null,
                                enabled: false,
                                child: const Text("No festivals found"),
                              ),
                            ],
                            onChanged: (newValue) {
                              setState(() {
                                _selectedFestivalId = newValue;
                                _selectedEventId = null;
                              });
                              if (newValue != null) {
                                Provider.of<EventProvider>(context, listen: false)
                                    .fetchEvents(context, newValue);
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Select Event",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Consumer<EventProvider>(
                        builder: (context, eventProvider, child) {
                          // If no festival is selected, show disabled dropdown
                          if (_selectedFestivalId == null) {
                            return _buildDisabledDropdown("Select festival first");
                          }

                          // If still fetching, show "Loading events..."
                          if (eventProvider.isFetching) {
                            return _buildDisabledDropdown("Loading events...");
                          }

                          // If done fetching but the list is empty
                          if (eventProvider.events.isEmpty) {
                            return _buildDisabledDropdown("No events found");
                          }

                          // Otherwise, show the real dropdown
                          return DropdownButtonFormField<String>(
                            value: _selectedEventId,
                            hint: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.6,
                              ),
                              child: const Text(
                                "Choose an event",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: SvgPicture.asset(
                                AppConstants.festivalPrefix,
                                color: const Color(0xFFF96222),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.only(
                                left: 12,
                                right: 40, // Extra space for dropdown arrow
                                top: 16,
                                bottom: 16,
                            ),
                            ),
                            isExpanded: true,
                            items: eventProvider.events.map((event) {
                              return DropdownMenuItem<String>(
                                value: event.id.toString(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                    MediaQuery.of(context).size.width * 0.6,
                                  ),
                                  child: Text(
                                    event.eventTitle ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedEventId = newValue;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Stall Name",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _stallNameController,
                        decoration: InputDecoration(
                          hintText: "Enter stall name",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(AppConstants.stallNamePrefix,
                                color: const Color(0xFFF96222)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Upload Image",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4.0,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                             child: _isCompressingStallImage
                                 ? Column(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       const CircularProgressIndicator(
                                         color: Color(0xFFF96222),
                                         strokeWidth: 3,
                                       ),
                                       const SizedBox(height: 12),
                                       Text(
                                         "Compressing image...",
                                         style: TextStyle(
                                           color: const Color(0xFFF96222),
                                           fontSize: 14,
                                           fontWeight: FontWeight.w500,
                                         ),
                                       ),
                                     ],
                                   )
                                 : _selectedImage == null
                                ? SvgPicture.asset(AppConstants.addImageIcon,
                                color: const Color(0xFFF96222))
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Spacer(),
                          const Text(
                            "Open Map",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                FadePageRouteBuilder(
                                    widget: GoogleMapView(
                                      isFromFestival: false,
                                    )),
                              );
                              if (result != null) {
                                setState(() {
                                  _latitudeController.text = result['latitude'];
                                  _longitudeController.text = result['longitude'];
                                });
                              }
                            },
                            child: Image.asset(AppConstants.mapPreview),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Stall Location",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _latitudeController,
                        decoration: InputDecoration(
                          hintText: "Latitude",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _longitudeController,
                        decoration: InputDecoration(
                          hintText: "Longitude",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: buildDateField(
                              context,
                              "From",
                              _startDateController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: buildDateField(
                              context,
                              "To",
                              _endDateController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      buildTimeField(
                          context, "Opening Time", _openingTimeController),
                      const SizedBox(height: 10),
                      buildTimeField(
                          context, "Closing Time", _closingTimeController),
                      const SizedBox(height: 10),
                      const Text(
                        "Add Menu Items",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          // Dynamically generated menu items
                          ...menuItems.asMap().entries.map((entry) {
                            int index = entry.key;
                            MenuItem item = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    // Header with item number and remove button
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF96222).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            "Item ${index + 1}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFF96222),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                          onPressed: () => removeMenuItem(index),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Dish Name Field
                                    const Text(
                                      "Dish Name",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: item.dishNameController,
                                      decoration: InputDecoration(
                                        hintText: "Enter dish name",
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Price and Currency Row
                                    Row(
                                      children: [
                                  Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Price",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                      controller: item.priceController,
                                                keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                                  hintText: "0.00",
                                        filled: true,
                                                  fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Currency",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    value: item.selectedCurrency,
                                                    isExpanded: true,
                                                    icon: Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF96222).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Icon(
                                                        Icons.keyboard_arrow_down,
                                                        color: Color(0xFFF96222),
                                                        size: 18,
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    selectedItemBuilder: (BuildContext context) {
                                                      return CurrencyUtility.currencies.map((currency) {
                                                        return Container(
                                                          alignment: Alignment.centerLeft,
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Container(
                                                                padding: const EdgeInsets.all(4),
                                                                decoration: BoxDecoration(
                                                                  color: const Color(0xFFF96222).withOpacity(0.15),
                                                                  borderRadius: BorderRadius.circular(4),
                                                                ),
                                                                child: Text(
                                                                  currency.symbol,
                                                                  style: const TextStyle(
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: Color(0xFFF96222),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                currency.code,
                                                                style: const TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors.grey,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList();
                                                    },
                                                    items: CurrencyUtility.currencies.map((currency) {
                                                      return DropdownMenuItem<String>(
                                                        value: currency.code,
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.all(6),
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xFFF96222).withOpacity(0.1),
                                                                borderRadius: BorderRadius.circular(6),
                                                              ),
                                                              child: Text(
                                                                currency.symbol,
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Color(0xFFF96222),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                currency.code,
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors.grey,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (newValue) {
                                                      if (newValue != null) {
                                                        setState(() {
                                                          item.selectedCurrency = newValue;
                                                          item.currencySymbol = CurrencyUtility.getSymbolByCode(newValue);
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Image Selection
                                    const Text(
                                      "Dish Image",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _pickMenuItemImage(index),
                                            child: Container(
                                              height: 120,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: item.isImageSelected 
                                                    ? Colors.green.shade300 
                                                    : Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                              ),
                                                                                             child: Center(
                                                 child: item.isCompressing
                                                     ? Column(
                                                         mainAxisAlignment: MainAxisAlignment.center,
                                                         children: [
                                                           const CircularProgressIndicator(
                                                             color: Color(0xFFF96222),
                                                             strokeWidth: 2,
                                                           ),
                                                           const SizedBox(height: 8),
                                                           Text(
                                                             "Compressing...",
                                                             style: TextStyle(
                                                               color: const Color(0xFFF96222),
                                                               fontSize: 12,
                                                               fontWeight: FontWeight.w500,
                                                             ),
                                                           ),
                                                         ],
                                                       )
                                                     : item.isImageSelected
                                                         ? ClipRRect(
                                                             borderRadius: BorderRadius.circular(6),
                                                             child: Image.file(
                                                               File(item.selectedImage!.path),
                                                               fit: BoxFit.cover,
                                                               width: double.infinity,
                                                               height: double.infinity,
                                                             ),
                                                           )
                                                         : Column(
                                                             mainAxisAlignment: MainAxisAlignment.center,
                                                             children: [
                                                               Container(
                                                                 padding: const EdgeInsets.all(12),
                                                                 decoration: BoxDecoration(
                                                                   color: const Color(0xFFF96222).withOpacity(0.1),
                                                                   borderRadius: BorderRadius.circular(8),
                                                                 ),
                                                                 child: SvgPicture.asset(
                                                                   AppConstants.addImageIcon,
                                                                   color: const Color(0xFFF96222),
                                                                   height: 24,
                                                                 ),
                                                               ),
                                                               const SizedBox(height: 8),
                                                               const Text(
                                                                 "Add Image",
                                                                 style: TextStyle(
                                                                   fontSize: 12,
                                                                   color: Color(0xFFF96222),
                                                                   fontWeight: FontWeight.w500,
                                                                 ),
                                                               ),
                                                             ],
                                                           ),
                                               ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (!item.isImageSelected)
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.red.withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: Colors.red.shade600,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      "Image required",
                                                      style: TextStyle(
                                                        color: Colors.red.shade600,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          ElevatedButton(
                            onPressed: addMenuItem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF96222),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Add New Menu Item",
                                style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 10),
                          // Submit Button with CircularProgressIndicator when loading
                          GestureDetector(
                            onTap: _isSubmitting ? null : _submitStall,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6900),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: _isSubmitting
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  "Submit",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledDropdown(String hintText) {
    return DropdownButtonFormField<String>(
      items: const [],
      onChanged: null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

       

  Widget buildDateField(
      BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2050),
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = pickedDate.toString().substring(0, 11);
              });
            }
          },
          child: AbsorbPointer(
            child: Container(
              height: 70,
              child: TextFormField(
                controller: controller,
                style: const TextStyle(fontSize: 14.0),
                decoration: InputDecoration(
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 30.0,
                    minHeight: 30.0,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: SvgPicture.asset(AppConstants.calenderIcon,
                        color: const Color(0xFFF96222)),
                  ),
                  suffixIcon: const Icon(Icons.arrow_drop_down_sharp),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTimeField(
      BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              setState(() {
                controller.text = pickedTime.format(context);
              });
            }
          },
          child: buildTextField(controller, "Select Time", Icons.access_time),
        ),
      ],
    );
  }

  Widget buildTextField(
      TextEditingController controller, String hint, IconData icon) {
    return AbsorbPointer(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
