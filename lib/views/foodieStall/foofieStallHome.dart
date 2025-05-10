import 'package:festiefoodie/annim/transiton.dart';
import 'package:festiefoodie/constants/appConstants.dart';
import 'package:festiefoodie/views/foodieStall/addStallView/viewallFestivals.dart';
import 'package:festiefoodie/views/foodieStall/authViews/loginView.dart';
import 'package:festiefoodie/views/foodieStall/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/allStallsCollectionModel.dart';
import '../../providers/stallProvider.dart';
import '../../utilities/scaffoldBackground.dart';
import '../../utilities/sharedPrefs.dart';
import '../feed/createPost.dart';
import '../feed/socialpstview.dart';
import 'addStallView/addStallView.dart';
import 'addStallView/stallDetailView.dart';

class FoodieStallHome extends StatefulWidget {
  const FoodieStallHome({super.key});

  @override
  State<FoodieStallHome> createState() => _FoodieStallHomeState();
}

class _FoodieStallHomeState extends State<FoodieStallHome> {
  String? userName;

  @override
  void initState() {
    super.initState();
    // Fetch the user name asynchronously.
    getUserName().then((fetchedName) {
      setState(() {
        userName = fetchedName; // e.g. "John Doe"
      });
    });
    // Fetch stalls after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StallProvider>(context, listen: false)
          .fetchStallsCollection(context, forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                userName ?? " ",
                style: const TextStyle(
                  fontFamily: "inter-semibold",
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              leading: IconButton(
                onPressed: () => Navigator.push(
                    context,
                    FadePageRouteBuilder(widget: UserProfile())
                ),
                icon: Image.asset(AppConstants.userIcon),
              ),
              leadingWidth: 40,
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) async {
                    if (value == 'logout') {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear(); // Clear all saved login/user data

                      // Optionally navigate to login screen
                      // Replace with your actual login screen route
                      Navigator.of(context).pushAndRemoveUntil(
                        FadePageRouteBuilder( widget: LoginView()),
                            (route) => false,
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            GestureDetector(
                onTap: (){Navigator.push(context, FadePageRouteBuilder(widget: SocialMediaHomeView()));},
                child: SvgPicture.asset(AppConstants.crapChat)),
            const SizedBox(height: 10),
            GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    FadePageRouteBuilder(widget: AddStallView())
                ),
                child: Image.asset(AppConstants.addStallCard)
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Stall",
                  style: TextStyle(
                      fontFamily: "inter-medium",
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(AppConstants.stallIcon),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        FadePageRouteBuilder(widget: ViewAllFestivals())
                    ),
                    child: const Text(
                      "View All",
                      style: TextStyle(
                          fontFamily: "inter-medium",
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Build the list of stalls using data from the provider.
            Consumer<StallProvider>(
              builder: (context, stallProvider, child) {
                if (stallProvider.isFetching && stallProvider.stallsCollection.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (stallProvider.errorMessage != null && stallProvider.stallsCollection.isEmpty) {
                  return Center(child: Text(stallProvider.errorMessage!));
                }
                if (stallProvider.stallsCollection.isEmpty) {
                  return const Center(child: Text("No stalls available."));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stallProvider.stallsCollection.length,
                  itemBuilder: (context, index) {
                    final stall = stallProvider.stallsCollection[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildStallCard(
                        context,
                        MediaQuery.of(context).size.width * 0.95,
                        stall.stallName,stall // Display the stall name dynamically
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStallCard(BuildContext context, double width, String title, Stall stall) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              child: Container(
                width: width,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 90), // Space for SVG
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: "inter-semibold",
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Space between text & button
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              FadePageRouteBuilder(
                                  widget: StallDetailView(
                                    closingTime: stall.closingTime,
                                    festivalName: stall.festivalName,
                                    endDate: stall.toDate,
                                    startDate: stall.fromDate,
                                    longitude: stall.longitude,
                                    latitude: stall.latitude,imageUrl: stall.image,openingTime: stall.openingTime,stallName: stall.stallName,
                                  )));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text(
                          "View Detail",
                          style: TextStyle(
                            fontFamily: "inter-medium",
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Container(
                  width: 90,
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    AppConstants.stallCardleftborder,
                    height: constraints.maxHeight,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// import 'package:festiefoodie/annim/transiton.dart';
// import 'package:festiefoodie/constants/appConstants.dart';
// import 'package:festiefoodie/views/foodieStall/addStallView/viewallFestivals.dart';
// import 'package:festiefoodie/views/foodieStall/userProfile.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../utilities/scaffoldBackground.dart';
// import '../../utilities/sharedPrefs.dart';
// import 'addStallView/addStallView.dart';
//
// class FoodieStallHome extends StatefulWidget {
//   const FoodieStallHome({super.key});
//
//   @override
//   State<FoodieStallHome> createState() => _FoodieStallHomeState();
// }
//
// class _FoodieStallHomeState extends State<FoodieStallHome> {
//   String? userName;
//
//   @override
//   @override
//   void initState() {
//     super.initState();
//     // 1) Fetch the userName asynchronously
//     getUserName().then((fetchedName) {
//       setState(() {
//         userName = fetchedName; // e.g. "John Doe"
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BackgroundScaffold(
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             AppBar(
//               backgroundColor: Colors.transparent,
//               title: Text(
//                 userName??" ",
//                 style: TextStyle(
//                   fontFamily: "inter-semibold",
//                   fontSize: 32,
//                   color: Colors.white,
//                 ),
//               ),
//               leading: IconButton(
//                 onPressed: () => Navigator.push(
//                     context, FadePageRouteBuilder(widget: UserProfile())),
//                 icon: Image.asset(AppConstants.userIcon),
//               ),
//               leadingWidth: 40,
//             ),
//             SizedBox(height: 15),
//             SvgPicture.asset(AppConstants.crapChat),
//             SizedBox(height: 10),
//             GestureDetector(
//                 onTap: () => Navigator.push(
//                     context, FadePageRouteBuilder(widget: AddStallView())),
//                 child: Image.asset(AppConstants.addStallCard)),
//             SizedBox(height: 10),
//             Row(
//               children: [
//                 Text(
//                   "Stall",
//                   style: TextStyle(
//                       fontFamily: "inter-medium",
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(width: 8),
//                 SvgPicture.asset(AppConstants.stallIcon),
//                 Spacer(),
//                 Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: GestureDetector(
//                     onTap: () => Navigator.push(context,
//                         FadePageRouteBuilder(widget: ViewAllFestivals())),
//                     child: Text(
//                       "View All",
//                       style: TextStyle(
//                           fontFamily: "inter-medium",
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
//                 "Flavors on Wheels"),
//             SizedBox(height: 10),
//             _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
//                 "Grill & Thrill"),
//             SizedBox(height: 10),
//             _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
//                 "Nom Nom Nook"),
//             SizedBox(height: 10),
//             _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
//                 "Flavors on Wheels"),
//             SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStallCard(BuildContext context, double width, String title) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Stack(
//           children: [
//             Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               elevation: 5,
//               child: Container(
//                 width: width,
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   color: Colors.white,
//                 ),
//                 child: Row(
//                   children: [
//                     SizedBox(width: 90), // Space for SVG
//                     Expanded(
//                       child: Text(
//                         title,
//                         style: TextStyle(
//                           fontFamily: "inter-semibold",
//                           fontSize: 18,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10), // Space between text & button
//                     SizedBox(
//                       height: 36,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 "This feature is in development phase.",
//                                 style: TextStyle(
//                                   fontFamily: "inter-medium",
//                                   fontSize: 14,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               backgroundColor: Colors.black87,
//                               behavior: SnackBarBehavior.floating,
//                               action: SnackBarAction(
//                                 label: "OK",
//                                 textColor: Colors.orange,
//                                 onPressed: () {
//                                   // Dismiss the snackbar
//                                 },
//                               ),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: EdgeInsets.symmetric(horizontal: 12),
//                         ),
//                         child: Text(
//                           "View Detail",
//                           style: TextStyle(
//                             fontFamily: "inter-medium",
//                             fontSize: 14,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               left: 0,
//               top: 0,
//               bottom: 0,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(16),
//                   bottomLeft: Radius.circular(16),
//                 ),
//                 child: Container(
//                   width: 90,
//                   color: Colors.transparent,
//                   child: SvgPicture.asset(
//                     AppConstants.stallCardleftborder,
//                     height: constraints.maxHeight,
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
