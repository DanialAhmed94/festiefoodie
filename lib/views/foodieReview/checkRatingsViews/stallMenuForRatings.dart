import 'package:festiefoodie/annim/transiton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/appConstants.dart';
import '../../../utilities/reviewsScaffoldBackground.dart';
import 'ratings.dart';

class StallMenuForRatings extends StatelessWidget {
  const StallMenuForRatings({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Dummy menu items
    final List<Map<String, String>> menuItems = [
      {
        "name": "Sunday Roast",
        "price": "20 (£)",
      },
      {
        "name": "Grilled Chicken",
        "price": "15 (£)",
      },
      {
        "name": "Veggie Delight",
        "price": "12 (£)",
      },
      {
        "name": "Sunday Roast",
        "price": "20 (£)",
      },
      {
        "name": "Grilled Chicken",
        "price": "15 (£)",
      },
      {
        "name": "Veggie Delight",
        "price": "12 (£)",
      },{
        "name": "Sunday Roast",
        "price": "20 (£)",
      },
      {
        "name": "Grilled Chicken",
        "price": "15 (£)",
      },
      {
        "name": "Veggie Delight",
        "price": "12 (£)",
      },
    ];

    return ReviewsScaffold(
      customAppbar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        title: Text(
          "Menu",
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
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final menuItem = menuItems[index];

            return Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
                horizontal: screenWidth * 0.04,
              ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Food Name & Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuItem["name"]!,
                        style: TextStyle(
                          fontFamily: "inter-bold",
                          fontSize: screenWidth * 0.05, // Responsive font
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        "Price : ${menuItem["price"]}",
                        style: TextStyle(
                          fontFamily: "inter-regular",
                          fontSize: screenWidth * 0.04,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // Open Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                        horizontal: screenWidth * 0.05,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, FadePageRouteBuilder(widget: Ratings()));                    },
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
            );
          },
        ),
      ),
    );
  }
}
