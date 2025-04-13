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
          item.priceController.text.trim().isNotEmpty) {
        hasValidMenuItem = true;
        break;
      }
    }
    if (!hasValidMenuItem) {
      showErrorDialog(context, "Please add at least one menu item", []);
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
                            hint: const Text("Choose a festival"),
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
                            ),
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
                                child: Text(
                                  festival.nameOrganizer ??
                                      festival.description,),
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
                            hint: const Text("Choose an event"),
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
                            ),
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
                            child: _selectedImage == null
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
