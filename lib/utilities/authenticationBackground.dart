import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/appConstants.dart';

class AuthenticationBackgroundScaffold extends StatelessWidget {
  final Widget child;


  const AuthenticationBackgroundScaffold(
      {super.key, required this.child,});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define responsive padding and sizing
    final horizontalPadding = screenWidth * 0.04; // 4% of screen width
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppConstants.authenitactionscaffoldBackground,
              fit: BoxFit.cover, // Makes sure the SVG covers the entire screen
            ),
          ),
          Positioned(
            top: screenHeight * 0.02, // 2% from top
            left: horizontalPadding,
            right: horizontalPadding,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: MediaQuery.of(context).size.height * 0.01,
              right: MediaQuery.of(context).size.height * 0.01,
              bottom: MediaQuery.of(context).size.height * 0.01,
              child: child),
        ],
      ),
    );
  }
}
