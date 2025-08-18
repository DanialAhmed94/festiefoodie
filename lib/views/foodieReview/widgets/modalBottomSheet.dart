import 'package:cached_network_image/cached_network_image.dart';
import 'package:festiefoodie/annim/transiton.dart';
import 'package:flutter/material.dart';
import 'package:festiefoodie/constants/appConstants.dart';

import '../../../models/festivalModel.dart';
import '../addingFoodReviewViews/festivalStalls.dart';
import '../seeRatings/stallsByFestival.dart';

showMarkerInfo(BuildContext context, FestivalResource festival) {
  DateTime startingDate = DateTime.parse(festival.startingDate);

  String year = startingDate.year.toString();
  String month = startingDate.month.toString().padLeft(2, '0');
  String day = startingDate.day.toString().padLeft(2, '0');

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
                          festival.nameOrganizer ?? festival.description,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Text(
                        //   "Pak life Pak life Pak lifePak life Pak lifePak life",
                        //   style: TextStyle(fontSize: 14, color: Colors.white),
                        // ),
                      ],
                    ),
                  ),
                ),
                // Positioned(
                //   right: 0,
                //   top: 10,
                //   child: Column(
                //     children: [
                //       Text(
                //         "TIME",
                //         style: TextStyle(fontSize: 12, color: Colors.black54),
                //       ),
                //       Text(
                //         festival.time != null ? festival.time! : "-- : --",
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.orange,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
                      _buildDateBox(day[0]),
                      _buildDateBox(day[1]),
                      SizedBox(width: 5),
                      Text(":",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(width: 5),
                      _buildDateBox(month[0]),
                      _buildDateBox(month[1]),
                      SizedBox(width: 5),
                      Text(":",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(width: 5),
                      _buildDateBox(year[0]),
                      _buildDateBox(year[1]),
                      _buildDateBox(year[2]),
                      _buildDateBox(year[3]),
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
                          Navigator.push(
                              context,
                              FadePageRouteBuilder(
                                  widget: FestivalStalls(
                                festivalId: festival.id.toString(),
                              )));
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
                          Navigator.push(
                              context,
                              FadePageRouteBuilder(
                                  widget: StallsByFestival(festivalId: festival.id.toString(),)));
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
                    child: CachedNetworkImage(
                      imageUrl: AppConstants.festivalImageUrl + festival.image,
                      height: 150,
                      fit: BoxFit.cover,
                      // Placeholder (shown while the image is loading)
                      placeholder: (context, url) => SizedBox(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.orange),
                        ),
                      ),
                      // Error widget (shown if the image failed to load)
                      errorWidget: (context, url, error) => SizedBox(
                        height: 150,
                        child: Center(
                          child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
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
  );
}

// Function to show Floating Snackbar
void showFloatingSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF96222), // Brand orange color
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
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
