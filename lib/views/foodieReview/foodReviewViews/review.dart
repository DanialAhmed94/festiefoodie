import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'dart:io';

import '../../../constants/appConstants.dart';
import '../../../utilities/reviewsScaffoldBackground.dart';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  File? _image1;
  File? _image2;
  Map<String, int> scores = {};

  void initializeScores() {
    List<String> categories = [
      'Cleanliness',
      'Tate & Flavour',
      'Presentation & Plating',
      'Quality & Freshness Of Ingredients',
      'Authenticity & Creativity',
      'Cooking Techniques & Temperature',
      'Freshness',
      'Value For Money',
      'Dining Experience',
      'Hygiene',

    ];

    scores = Map.fromIterable(
      categories,
      key: (category) => category,
      value: (category) => 0,
    );
  }

  Widget scoreSlider(String category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle_rounded,color: Color(0xFFFFDCC0),size: 12,),

              Padding(
                padding: const EdgeInsets.only(left: 11),
                child: Text(
                  "Score",
                  style: TextStyle(fontFamily: "Inter-Bold", fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8), // Space between "Score" and the slider

          SfSlider(
            min: 0.0,
            max: 10.0,
            value: scores[category] ?? 0.0,
            interval: 1,
            // Defines the step intervals
            stepSize: 1,
            // Ensures discrete steps
            showLabels: true,
            // Shows numerical labels
            enableTooltip: true,
            // Shows tooltip when dragging
            showDividers: true,
            // Shows dividers between intervals

            // **Custom Colors**
            activeColor: const Color(0xFFF96222),
            // Active track color
            inactiveColor: Color(0xFFFFDCC0),
            // Inactive track color

            // **Custom Thumb (Slider Head)**
            thumbIcon: Container(
              decoration: BoxDecoration(
                color: Colors.orange, // Thumb color
                shape: BoxShape.circle,
                //  border: Border.all(color: Colors.black, width: 2), // Border around thumb
              ),
            ),

            // Callback when slider value changes
            onChanged: (dynamic value) {
              setState(() {
                scores[category] = value.toInt();
              });
            },
          ),
        ],
      ),
    );
  }

  List<Widget> buildFormFields() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    List<String> categories = [
      'Cleanliness',
      'Taste & Flavour',
      'Presentation & Plating',
      'Quality & Freshness Of Ingredients',
      'Authenticity & Creativity',
      'Cooking Techniques & Temperature',
      'Freshness',
      'Value For Money',
      'Dining Experience',
      'Hygiene',
    ];

    return categories.map((category) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.01,
          horizontal: screenWidth * 0.04,
        ),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle_rounded,
                            color: Color(0xFFFFDCC0),
                            size: screenWidth * 0.03),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            category,
                            style: TextStyle(
                              fontFamily: 'inter-bold',
                              fontSize: screenWidth * 0.05, // Dynamic size
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // Slider Widget
                    scoreSlider(category),
                  ],
                ),

                // Floating Score Box inside the Card
                Positioned(
                  top: screenHeight * 0.01,
                  right: screenWidth * 0.02,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFDCC0),
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: screenWidth * 0.02,
                          offset: Offset(screenWidth * 0.005, screenWidth * 0.005),
                        ),
                      ],
                    ),
                    child: Text(
                      "${scores[category] ?? 0}", // Display current score
                      style: TextStyle(
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _pickImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        if (index == 1) {
          _image1 = File(pickedFile.path);
        } else {
          _image2 = File(pickedFile.path);
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeScores();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return ReviewsScaffold(
      customAppbar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        title: Text(
          "Review",
          style: TextStyle(
            fontFamily: "inter-semibold",
            fontSize: screenWidth * 0.08, // Responsive font size
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(AppConstants.backIcon),
        ),
        leadingWidth: 40,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            userDetail(context),
            uploadImageSection(context),
            ...buildFormFields(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: () {
                  final snackBar = SnackBar(
                    content: Text(
                      "This feature is in development.",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    backgroundColor: Colors.black87, // Floating effect
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: "OK",
                      textColor: Color(0xFFFF6900), // Orangish color
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Closes the snackbar
                      },
                    ),
                    duration: Duration(seconds: 3), // Auto dismiss after 3 sec
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
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
            ),
          ],
        ),
      ),
    );
  }

  /// User Detail Widget
  Widget userDetail(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        height: screenHeight * 0.18,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9), // Light background
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textField("Name"),
            SizedBox(height: screenHeight * 0.015),
            textField(currentDate, readOnly: true),
          ],
        ),
      ),
    );
  }

  /// Reusable TextField
  Widget textField(String hint, {bool readOnly = false}) {
    return TextField(
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFFDCC0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  /// Upload Image Section
  Widget uploadImageSection(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9), // Light background
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(screenWidth * 0.02),
        height: screenHeight * 0.15,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Upload Image Label
            Text(
              "Upload Image",
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.orange, // Matching PNG text color
              ),
            ),

            SizedBox(width: screenWidth * 0.05),
            // Space between text and images

            // Image Containers
            Row(
              children: [
                buildImageContainer(1, _image1),
                SizedBox(width: screenWidth * 0.04), // Space between images
                buildImageContainer(2, _image2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Image Container Widget
  Widget buildImageContainer(int index, File? imageFile) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        width: screenWidth * 0.25, // Adjusted for a neat size
        height: screenHeight * 0.12,
        decoration: BoxDecoration(
          color: Colors.grey[300], // Light grey background
          borderRadius: BorderRadius.circular(12), // Curved container
        ),
        child: imageFile == null
            ? Icon(Icons.camera_alt,
                size: 30, color: Colors.black54) // Camera icon
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(imageFile, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
