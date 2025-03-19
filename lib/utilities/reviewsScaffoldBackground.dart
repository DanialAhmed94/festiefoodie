import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/appConstants.dart';

class ReviewsScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget customAppbar; // Use PreferredSizeWidget for AppBar

  const ReviewsScaffold({super.key, required this.child, required this.customAppbar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppbar, // Place the AppBar here
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              AppConstants.reviewScaffoldBackground,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.02,
              left: MediaQuery.of(context).size.height * 0.01,
              right: MediaQuery.of(context).size.height * 0.01,
              bottom: MediaQuery.of(context).size.height * 0.01,
              child: child),
        ],
      ),
    );
  }
}
