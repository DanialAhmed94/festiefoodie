import 'package:festiefoodie/annim/transiton.dart';
import 'package:festiefoodie/constants/appConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utilities/scaffoldBackground.dart';



class ViewAllStallsView extends StatelessWidget {
  const ViewAllStallsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: const Text(
                "All Stalls",
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
            SizedBox(height: 10),
            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Flavors on Wheels"),
            SizedBox(height: 10),
            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Grill & Thrill"),
            SizedBox(height: 10),
            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Nom Nom Nook"),
            SizedBox(height: 10),
            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Flavors on Wheels"),
            SizedBox(height: 10),
            SizedBox(height: 10),
            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Flavors on Wheels"),
            SizedBox(height: 10),
            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Grill & Thrill"),
            SizedBox(height: 10),
            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Nom Nom Nook"),
            SizedBox(height: 10),
            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Flavors on Wheels"),
            SizedBox(height: 10),

            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Flavors on Wheels"),
            SizedBox(height: 10),
            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Grill & Thrill"),
            SizedBox(height: 10),
            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Nom Nom Nook"),
            SizedBox(height: 10),
            _buildStallCard(context, MediaQuery.of(context).size.width * 0.95,
                "Flavors on Wheels"),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStallCard(BuildContext context, double width, String title) {
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    SizedBox(width: 90), // Space for SVG
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: "inter-semibold",
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Space between text & button
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "This feature is in development phase.",
                                style: TextStyle(
                                  fontFamily: "inter-medium",
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.black87,
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: "OK",
                                textColor: Colors.orange,
                                onPressed: () {
                                  // Dismiss the snackbar
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(
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
                borderRadius: BorderRadius.only(
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
