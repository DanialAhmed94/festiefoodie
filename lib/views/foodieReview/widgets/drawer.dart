import 'package:festiefoodie/annim/transiton.dart';
import 'package:festiefoodie/constants/appConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utilities/sharedPrefs.dart';
import '../../foodieStall/authViews/loginView.dart';
import '../../foodieStall/foofieStallHome.dart';
import '../foodieReviewHome.dart';
import '../seeRatings/seeAllFestivals.dart';
import '../seeRatings/stallsByFestival.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);
  final String feedbackEmail = 'astraldesignapp@gmail.com';

  void _sendFeedback(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: feedbackEmail,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Feedback',
        'body': 'FestieFoodie App Feedback:',
      }),
    );

    try {
      bool launched = await launch(emailLaunchUri.toString());

      if (!launched) {
        // If launching the default email client fails, try opening other installed email applications
        await _openOtherEmailApps();
      }
    } catch (error) {
      // If an error occurs during either attempt, show an error message
      _showErrorDialog(
          context, 'An error occurred while trying to send feedback.');
    }
  }

  Future<void> _openOtherEmailApps() async {
    // List of known email application package names on Android
    final List<String> emailApps = [
      'com.google.android.gm', // Gmail
      'com.microsoft.office.outlook', // Outlook
      // Add more package names for other email apps if needed
    ];

    // Iterate through the list of email apps and try to open them
    for (final String packageName in emailApps) {
      final String url = 'package:$packageName';

      if (await canLaunch(url)) {
        await launch(url);
        return;
      }
    }
    // If no known email apps are found, show an error message
    throw 'No email application is available.';
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.drawerBackground),
            // Change this to your image path
            fit: BoxFit.cover, // Control how the image scales
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Color(0xFFF96222),
              centerTitle: true,
              title: Text(
                "Hello FestieFoodie",
                style:
                    TextStyle(color: Colors.white, fontFamily: 'Poppins-Bold'),
              ),
              automaticallyImplyLeading: false,
            ),

            // Wrap each ListTile with a GestureDetector
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    FadePageRouteBuilder(widget: FoodieReviewHomeMap()));
              },
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
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, FadePageRouteBuilder(widget: SeeAllFestivals()));
                },
                child: ListTile(
                  title: Text(
                    "Stall Ratings",
                    style: TextStyle(fontFamily: 'Poppins-Medium'),
                  ),
                  leading: Icon(Icons.dashboard_customize_outlined),
                ),
              ),
            ),

            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: (){
                _sendFeedback(context);
              },
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
              onTap: () async {
                final isLoggedIn = await getIsLogedIn();

                if (isLoggedIn == true) {
                  // Navigate directly to stall home
                  Navigator.push(
                    context,
                    FadePageRouteBuilder(widget: FoodieStallHome()),
                  );
                } else {
                  // Navigate to login screen
                  Navigator.push(
                    context,
                    FadePageRouteBuilder(widget: LoginView()),
                  );
                }
              },

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
