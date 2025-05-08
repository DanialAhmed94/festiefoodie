import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants/appConstants.dart';
import '../../../providers/menuProvider.dart';
import '../../../utilities/reviewsScaffoldBackground.dart';

import '../../../annim/transiton.dart';
import 'ratings.dart';

class MenuByStall extends StatefulWidget {
  final String stallId;

  const MenuByStall({super.key, required this.stallId});

  @override
  State<MenuByStall> createState() => _StallMenuState();
}

class _StallMenuState extends State<MenuByStall> {
  Future<void>? _menuFuture;

  Future<void> _fetchMenu() async {
    try {
      await Provider.of<MenuProvider>(context, listen: false)
          .fetchMenuByStall(context, widget.stallId, isfromReviewSection: true);
    } catch (error) {
      print("Failed to fetch menu: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    _menuFuture = _fetchMenu();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final menuProvider = Provider.of<MenuProvider>(context);

    return ReviewsScaffold(
      customAppbar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        title: Text(
          "Menu",
          style: TextStyle(
            fontFamily: "inter-semibold",
            fontSize: screenWidth * 0.08,
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
        child: FutureBuilder<void>(
          future: _menuFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                  strokeWidth: 2,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Failed to load menu: ${snapshot.error}",
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }

            if (menuProvider.menuItemsByStall.isEmpty) {
              return const Center(
                child: Text(
                  "There is nothing to show",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              itemCount: menuProvider.menuItemsByStall.length,
              itemBuilder: (context, index) {
                final menuItem = menuProvider.menuItemsByStall[index];

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
                      Expanded( // 👈 This fixes the text overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menuItem.dishName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "inter-bold",
                                fontSize: screenWidth * 0.05,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              "Price : ${menuItem.dishPrice} (£)",
                              style: TextStyle(
                                fontFamily: "inter-regular",
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8), // optional spacing between text and button
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
                          Navigator.push(
                            context,
                            FadePageRouteBuilder(widget: Ratings(dishId: menuItem.id.toString())),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "OPEN",
                              style: TextStyle(
                                fontFamily: "inter-semibold",
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            const Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                ;
              },
            );
          },
        ),
      ),
    );
  }
}

// import 'package:festiefoodie/annim/transiton.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../../constants/appConstants.dart';
// import '../../../utilities/reviewsScaffoldBackground.dart';
// import 'review.dart';
//
// class StallMenu extends StatelessWidget {
//   const StallMenu({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;
//
//     // Dummy menu items
//     final List<Map<String, String>> menuItems = [
//       {
//         "name": "Sunday Roast",
//         "price": "20 (£)",
//       },
//       {
//         "name": "Grilled Chicken",
//         "price": "15 (£)",
//       },
//       {
//         "name": "Veggie Delight",
//         "price": "12 (£)",
//       },
//       {
//         "name": "Sunday Roast",
//         "price": "20 (£)",
//       },
//       {
//         "name": "Grilled Chicken",
//         "price": "15 (£)",
//       },
//       {
//         "name": "Veggie Delight",
//         "price": "12 (£)",
//       },{
//         "name": "Sunday Roast",
//         "price": "20 (£)",
//       },
//       {
//         "name": "Grilled Chicken",
//         "price": "15 (£)",
//       },
//       {
//         "name": "Veggie Delight",
//         "price": "12 (£)",
//       },
//     ];
//
//     return ReviewsScaffold(
//       customAppbar: AppBar(
//         backgroundColor: const Color(0xFFF9F9F9),
//         centerTitle: true,
//         title: Text(
//           "Menu",
//           style: TextStyle(
//             fontFamily: "inter-semibold",
//             fontSize: screenWidth * 0.08, // Responsive font size
//             color: Colors.black,
//           ),
//         ),
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: SvgPicture.asset(AppConstants.backIcon),
//         ),
//         leadingWidth: 40,
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//         child: ListView.builder(
//           itemCount: menuItems.length,
//           itemBuilder: (context, index) {
//             final menuItem = menuItems[index];
//
//             return Container(
//               margin: EdgeInsets.only(bottom: screenHeight * 0.02),
//               padding: EdgeInsets.symmetric(
//                 vertical: screenHeight * 0.02,
//                 horizontal: screenWidth * 0.04,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     spreadRadius: 2,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Food Name & Price
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         menuItem["name"]!,
//                         style: TextStyle(
//                           fontFamily: "inter-bold",
//                           fontSize: screenWidth * 0.05, // Responsive font
//                           color: Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.005),
//                       Text(
//                         "Price : ${menuItem["price"]}",
//                         style: TextStyle(
//                           fontFamily: "inter-regular",
//                           fontSize: screenWidth * 0.04,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   // Open Button
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       padding: EdgeInsets.symmetric(
//                         vertical: screenHeight * 0.015,
//                         horizontal: screenWidth * 0.05,
//                       ),
//                     ),
//                     onPressed: () {
// Navigator.push(context, FadePageRouteBuilder(widget: Review()));                    },
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           "OPEN",
//                           style: TextStyle(
//                             fontFamily: "inter-semibold",
//                             fontSize: screenWidth * 0.04,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(width: screenWidth * 0.02),
//                         Icon(Icons.arrow_forward, color: Colors.white),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
