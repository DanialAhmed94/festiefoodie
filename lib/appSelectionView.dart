import 'package:festiefoodie/utilities/scaffoldBackground.dart';
import 'package:festiefoodie/utilities/sharedPrefs.dart';
import 'package:festiefoodie/views/feed/socialpstview.dart';
import 'package:festiefoodie/views/foodieStall/foofieStallHome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'annim/transiton.dart';
import 'constants/appConstants.dart';
import 'views/foodieReview/foodieReviewHome.dart';
import 'views/foodieStall/authViews/loginView.dart';

class Appselectionview extends StatelessWidget {
  const Appselectionview({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.04; // 4% padding

    return BackgroundScaffold(
        child: SingleChildScrollView(
      child: Column(
        children: [SizedBox(height: size.height*0.04,),
          Image.asset(
            AppConstants.favFod,
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
                    FadePageRouteBuilder(widget: SocialMediaHomeView()),
                  );
                } else {
                  // Navigate to login screen
                  Navigator.push(
                    context,
                    FadePageRouteBuilder(widget: LoginView()),
                  );
                }
              },
              child: SvgPicture.asset(AppConstants.crapChat)),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              // First App Card
              Expanded(
                child: GestureDetector(
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

                  child: Container(
                    // 25% of screen height
                    margin: EdgeInsets.only(right: padding / 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        AppConstants.app1Card,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              // Second App Card
              Expanded(
                child: GestureDetector(
                  onTap: ()  {

                      Navigator.push(
                        context,
                        FadePageRouteBuilder(widget: FoodieReviewHomeMap()),

                      );
                    },

                  child: Container(
                    // 25% of screen height
                    margin: EdgeInsets.only(left: padding / 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        AppConstants.app2Card,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
