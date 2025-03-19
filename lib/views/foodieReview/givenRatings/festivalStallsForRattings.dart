import 'package:festiefoodie/annim/transiton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/appConstants.dart';
import '../../../utilities/reviewsScaffoldBackground.dart';
import 'stallMenuForRatings.dart';

class FestivalStallsForRatings extends StatelessWidget {
  const FestivalStallsForRatings({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Dummy data for stalls
    final List<Map<String, String>> stalls = [
      {
        "title": "Bite & Delight",
        "from": "2025 : 25 : 02",
        "to": "2025 : 25 : 04",
        "image": AppConstants.dummyStallImage, // Replace with actual path
      },
      {
        "title": "Tasty Treats",
        "from": "2025 : 26 : 10",
        "to": "2025 : 26 : 12",
        "image": AppConstants.dummyStallImage, // Replace with actual path
      },
      {
        "title": "Gourmet Feast",
        "from": "2025 : 27 : 08",
        "to": "2025 : 27 : 10",
        "image": AppConstants.dummyStallImage, // Replace with actual path
      },
      {
        "title": "Bite & Delight",
        "from": "2025 : 25 : 02",
        "to": "2025 : 25 : 04",
        "image": AppConstants.dummyStallImage, // Replace with actual path
      },
      {
        "title": "Tasty Treats",
        "from": "2025 : 26 : 10",
        "to": "2025 : 26 : 12",
        "image": AppConstants.dummyStallImage, // Replace with actual path
      },
      {
        "title": "Gourmet Feast",
        "from": "2025 : 27 : 08",
        "to": "2025 : 27 : 10",
        "image": AppConstants.dummyStallImage, // Replace with actual path
      }
    ];

    return ReviewsScaffold(
      customAppbar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        title: Text(
          "Stalls",
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: ListView.builder(
          itemCount: stalls.length,
          itemBuilder: (context, index) {
            final stall = stalls[index];

            return Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stall Info Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stall["title"]!,
                          style: TextStyle(
                            fontFamily: "inter-bold",
                            fontSize: screenWidth * 0.05, // Responsive font
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          "From: ${stall["from"]}",
                          style: TextStyle(
                            fontFamily: "inter-regular",
                            fontSize: screenWidth * 0.04,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "To: ${stall["to"]}",
                          style: TextStyle(
                            fontFamily: "inter-regular",
                            fontSize: screenWidth * 0.04,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        // Open Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                              horizontal: screenWidth * 0.06,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                FadePageRouteBuilder(widget: StallMenuForRatings()));
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "OPEN",
                                style: TextStyle(
                                  fontFamily: "inter-semibold",
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stall Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      stall["image"]!,
                      width: screenWidth * 0.25,
                      height: screenHeight * 0.12,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
