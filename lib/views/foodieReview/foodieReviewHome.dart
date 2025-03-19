import 'package:festiefoodie/constants/appConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../utilities/connectivityServices.dart';
import '../../utilities/getUserAddress.dart';
import 'HomeGoogleMap.dart';
import 'widgets/drawer.dart';

class FoodieReviewHomeMap extends StatefulWidget {
  @override
  State<FoodieReviewHomeMap> createState() => _MainScreenState();
}

class _MainScreenState extends State<FoodieReviewHomeMap> {
  DateTime? currentBackPressTime;
  bool _canPop = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentBackPressTime == null ||
            DateTime.now().difference(currentBackPressTime!) >
                Duration(seconds: 2)) {
          currentBackPressTime = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75,
          title: Text(
            'FestieFoodie',
            style: TextStyle(
              fontFamily: 'Poppins-Bold',
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
               // color: Color(0xFFF76E01),

               AppConstants.drawerIcon,

              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: GestureDetector(

                child: Image.asset(
                  AppConstants.foodielogo,
                  height: 50,
                  width: 50,
                ),
              ),
            ),
          ],
        ),
        drawer: MyDrawer(), // Use your custom drawer widget
        body: FutureBuilder<bool>(
          future: _checkServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.data == false) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Please enable internet and location services.',
                    style: TextStyle(
                      fontFamily: 'Poppins-SemiBold',
                    ),
                  ),
                ),
              );
            } else {
              return Stack(
                children: [
                  GoogleMapWidget(),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Location",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.04, // Dynamic size
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          FutureBuilder<String>(
                            future: getUserAddress(),
                            builder: (context, addressSnapshot) {
                              if (addressSnapshot.connectionState == ConnectionState.waiting) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.width * 0.05,
                                  width: MediaQuery.of(context).size.width * 0.05,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              } else if (addressSnapshot.hasError) {
                                return Text(
                                  'Error getting user address',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust size
                                  ),
                                );
                              } else {
                                return Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, color: Colors.deepOrangeAccent),
                                    SizedBox(width: 4), // Adds space between icon and text
                                    Expanded( // Ensures text wraps instead of overflowing
                                      child: Text(
                                        addressSnapshot.data?.toString() ?? 'Unknown Address',
                                        style: TextStyle(
                                          fontFamily: 'Poppins-SemiBold',
                                          fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
                                          overflow: TextOverflow.ellipsis, // Prevents overflow issues
                                        ),
                                        maxLines: 2, // Allows wrapping if needed
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> _checkServices() async {
    bool isInternetConnected = await checkInternetConnection();
    bool isLocationServiceEnabled = await checkLocationService();

    return isInternetConnected && isLocationServiceEnabled;
  }
}
