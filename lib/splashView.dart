import 'package:festiefoodie/appSelectionView.dart';
import 'package:flutter/material.dart';

import 'constants/appConstants.dart';

class Splashview extends StatefulWidget {
  const Splashview({super.key});

  @override
  State<Splashview> createState() => _SplashviewState();
}

class _SplashviewState extends State<Splashview> {
  @override
  void initState() {
    super.initState();

    // Navigate to the next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Appselectionview()), // Replace with your actual screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.splashBackground), // Ensure it's declared in pubspec.yaml
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
