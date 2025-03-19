import 'dart:io';

import 'package:festiefoodie/constants/appConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../annim/transiton.dart';
import '../../../utilities/scaffoldBackground.dart';
import '../mapViews/LocationMap.dart';

class AddStallView extends StatefulWidget {
  const AddStallView({super.key});

  @override
  State<AddStallView> createState() => _AddStallViewState();
}

class _AddStallViewState extends State<AddStallView> {
  XFile? _selectedImage;
  bool _isImageSelected = true;
  String? selectedFestival;
  final List<String> festivals = [
    "Glastonbury Festival",
    "Reading Festival",
    "Isle of Wight Festival",
    "Download Festival"
  ];
  String? selectedEent;
  final List<String> events = [
    "Glastonbury Festival",
    "Reading Festival",
    "Isle of Wight Festival",
    "Download Festival"
  ];
  TextEditingController _stallNameController = TextEditingController();
  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _openingTimeController = TextEditingController();
  TextEditingController _closingTimeController = TextEditingController();

  List<MenuItem> menuItems = [];

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
    super.dispose();
  }

  void addMenuItem() {
    setState(() {
      menuItems.add(MenuItem(
        dishNameController: TextEditingController(),
        priceController: TextEditingController(),
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
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isImageSelected = true;
      });
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
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          prefixIcon: SvgPicture.asset(
                              AppConstants.festivalPrefix,
                              color: Color(0xFFF96222)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: selectedFestival,
                        hint: const Text("Choose a festival"),
                        items: festivals.map((festival) {
                          return DropdownMenuItem(
                            value: festival,
                            child: Text(festival),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFestival = value;
                          });
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
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          prefixIcon: SvgPicture.asset(
                              AppConstants.festivalPrefix,
                              height: 10,
                              width: 10,
                              color: Color(0xFFF96222)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: selectedFestival,
                        hint: const Text(" Choose a event"),
                        items: events.map((event) {
                          return DropdownMenuItem(
                            value: event,
                            child: Text(event),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedEent = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      // Stall Name Input
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
                            // Adjust padding for better alignment
                            child: SvgPicture.asset(
                                AppConstants.stallNamePrefix,
                                // Ensure you have an appropriate icon for stalls
                                color: Color(0xFFF96222)
                                // Use your theme color
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      SizedBox(height: 10),
                      const Text(
                        "Upload Image",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
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
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _selectedImage == null
                                ? SvgPicture.asset(AppConstants.addImageIcon,
                                    color: Color(0xFFF96222))
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
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Spacer(),
                          Text(
                            "Open Map",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                FadePageRouteBuilder(widget: GoogleMapView(isFromFestival: false,)),
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
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: buildDateField(
                              context,
                              "From",
                              _startDateController,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: buildDateField(
                              context,
                              "To",
                              _endDateController,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      buildTimeField(
                          context, "Opening Time", _openingTimeController),
                      SizedBox(height: 10),
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
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: item.dishNameController,
                                      decoration: InputDecoration(
                                        hintText: "Dish Name",
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: item.priceController,
                                      decoration: InputDecoration(
                                        hintText: "Price",
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () => removeMenuItem(index),
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
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "This feature is in development phase.",
                                    style: TextStyle(
                                      fontFamily: "inter-medium",
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.black87,
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: "OK",
                                    textColor: Colors.orange,
                                    onPressed: () {
                                      // Dismiss the snackbar
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Color(0xFFFF6900),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
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

  Widget buildDateField(
      BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
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
                style: TextStyle(fontSize: 14.0),
                decoration: InputDecoration(
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 30.0,
                    minHeight: 30.0,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: SvgPicture.asset(AppConstants.calenderIcon,
                        color: Color(0xFFF96222)),
                  ),
                  suffixIcon: Icon(Icons.arrow_drop_down_sharp),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        SizedBox(height: 10),
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

class MenuItem {
  final TextEditingController dishNameController;
  final TextEditingController priceController;

  MenuItem({
    required this.dishNameController,
    required this.priceController,
  });
}
