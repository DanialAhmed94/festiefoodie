import 'package:festiefoodie/annim/transiton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/appConstants.dart';
import '../../../utilities/reviewsScaffoldBackground.dart';

class Ratings extends StatelessWidget {
  const Ratings({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Dummy Ratings Data
    final List<Map<String, dynamic>> ratingsData = [
      {
        "dishName": "Bath Literature Festival Paklife",
        "date": "2025-02-05",
        "reviewerName": "Sufyan Mateen",
        "givenScore": 4.5,
        "totalScore": 5.0,
      },
      {
        "dishName": "Spicy Chicken Biryani",
        "date": "2025-01-20",
        "reviewerName": "Ali Raza",
        "givenScore": 3.8,
        "totalScore": 5.0,
      },
      {
        "dishName": "Classic Margherita Pizza",
        "date": "2024-12-15",
        "reviewerName": "Zara Khan",
        "givenScore": 4.2,
        "totalScore": 5.0,
      },
      {
        "dishName": "Grilled Steak with Herbs",
        "date": "2024-11-10",
        "reviewerName": "John Doe",
        "givenScore": 4.7,
        "totalScore": 5.0,
      },
      {
        "dishName": "Chocolate Lava Cake",
        "date": "2024-10-05",
        "reviewerName": "Emily Watson",
        "givenScore": 4.9,
        "totalScore": 5.0,
      },
    ];

    return ReviewsScaffold(
      customAppbar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Ratings",
            style: TextStyle(
              fontFamily: "inter-semibold",
              fontSize: screenWidth * 0.06, // Adjusted for better scaling
              color: Colors.black,
            ),
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
          itemCount: ratingsData.length,
          itemBuilder: (context, index) {
            final rating = ratingsData[index];

            return Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.015,
                horizontal: screenWidth * 0.04,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dish Name
                  buildRichText("Dish Name: ", rating["dishName"], screenWidth),
                  SizedBox(height: screenHeight * 0.005),

                  // Date
                  buildRichText("Date: ", rating["date"], screenWidth),
                  SizedBox(height: screenHeight * 0.005),

                  // Reviewer Name
                  buildRichText(
                      "Reviewer Name: ", rating["reviewerName"], screenWidth),
                  SizedBox(height: screenHeight * 0.01),

                  // Score & Curved Design
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildRichText(
                        "Score: ",
                        "${rating["givenScore"]} / ${rating["totalScore"]}",
                        screenWidth,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(12),
                        ),
                        child: Container(
                          width: screenWidth * 0.15,
                          height: screenHeight * 0.05,
                          color: Colors.orange,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${rating["givenScore"]} / ${rating["totalScore"]}",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Function to Build Consistent Rich Text
  Widget buildRichText(String label, String value, double screenWidth) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.04,
              color: Colors.orange,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
