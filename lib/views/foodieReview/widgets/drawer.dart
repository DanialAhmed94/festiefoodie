import 'package:festiefoodie/constants/appConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container( decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppConstants.drawerBackground), // Change this to your image path
          fit: BoxFit.cover, // Control how the image scales
        ),
      ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Color(0xFFF96222)
              ,
              centerTitle: true,
              title: Text(
                "Hello FestieFoodie",
                style: TextStyle(color:Colors.white,fontFamily: 'Poppins-Bold'),
              ),
              automaticallyImplyLeading: false,
            ),

            // Wrap each ListTile with a GestureDetector
            GestureDetector(

              child: ListTile(
                title: Text(
                  "Home",
                  style: TextStyle(fontFamily: 'Poppins-Medium'),
                ),
                leading: Icon(Icons.home_outlined),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(

              child: ListTile(
                title: Text(
                  "Stall Ratings",
                  style: TextStyle(fontFamily: 'Poppins-Medium'),
                ),
                leading: Icon(Icons.dashboard_customize_outlined),
              ),
            ),

            SizedBox(
              height: 10,
            ),
            GestureDetector(

              child: ListTile(
                title: Text(
                  "Feedback",
                  style: TextStyle(fontFamily: 'Poppins-Medium'),
                ),
                leading: Icon(Icons.feedback_outlined),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(

              child: ListTile(
                title: Text(
                  "Add Stall",
                  style: TextStyle(fontFamily: 'Poppins-Medium'),
                ),
                leading: Image.asset(
                  AppConstants.foodielogo,
                  height: 50,
                  width: 50,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}


