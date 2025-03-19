import 'package:festiefoodie/annim/transiton.dart';
import 'package:flutter/material.dart';
import 'package:festiefoodie/constants/appConstants.dart';

import '../foodReviewViews/festivalStalls.dart';
import '../givenRatings/festivalStallsForRattings.dart';

showMarkerInfo(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Festival Name and Time Row
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepOrangeAccent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bath Literature Festival",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Pak life",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 10,
                  child: Column(
                    children: [
                      Text(
                        "TIME",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        "14 : 33",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Date Section
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    "DATE :",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Row(
                    children: [
                      _buildDateBox("2"),
                      _buildDateBox("0"),
                      _buildDateBox("2"),
                      _buildDateBox("5"),
                      SizedBox(width: 5),
                      Text(":",style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16),),
                      SizedBox(width: 5),
                      _buildDateBox("0"),
                      _buildDateBox("2"),
                      SizedBox(width: 5),
                      Text(":",style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,fontSize: 16)),
                      SizedBox(width: 5),
                      _buildDateBox("2"),
                      _buildDateBox("5"),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Buttons and Image
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Food Review Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, FadePageRouteBuilder(widget: FestivalStalls()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Post Food Review",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Ratings Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {

                          Navigator.push(context, FadePageRouteBuilder(widget: FestivalStallsForRatings()));

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Ratings",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10),

                // Image takes remaining space
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      AppConstants.dummyFestivalImage,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// Function to show Floating Snackbar
void showFloatingSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: "OK",
        textColor: Colors.white,
        onPressed: () {},
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black87,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: Duration(seconds: 3),
    ),
  );
}

// Helper Widget for Date Boxes
Widget _buildDateBox(String text) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    margin: EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      color: Colors.orange,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      text,
      style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );
}
