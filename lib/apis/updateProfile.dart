import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/appConstants.dart';
import '../utilities/dilalogBoxes.dart';
import '../annim/transiton.dart';
import '../utilities/sharedPrefs.dart';
import '../views/foodieStall/foofieStallHome.dart';

Future<void> updateUserProfile(
    BuildContext context,
    String username,
    String oldPassword,
    String newPassword,
    ) async {
  final url = Uri.parse("${AppConstants.baseUrl}/update-password");
  final bearerToken = await getToken(); // Fetch the bearer token

  var body = {
    "user_name": username,
    "old_password": oldPassword,
    "new_password": newPassword,
  };

  try {
    final response = await http
        .post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',

      },
      body: jsonEncode(body),
    )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            responseData['message'] ?? 'Profile updated',
            style: TextStyle(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black87, // Light black
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.orange,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      ;

      // Navigate to profile screen again or elsewhere
      Navigator.pushAndRemoveUntil(
        context,
        FadePageRouteBuilder(widget: FoodieStallHome()), // Replace with your target screen
            (route) => false,
      );
    } else if (response.statusCode == 401) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showErrorDialog(context, responseData['message'], []);
    } else {
      showErrorDialog(
        context,
        "Failed to update profile. Status: ${response.statusCode}",
        [],
      );
      debugPrint("Server error: ${response.body}");
    }
  } on TimeoutException {
    showErrorDialog(
      context,
      "Request timed out. Please try again later.",
      [],
    );
  } on http.ClientException catch (e) {
    if (e.toString().contains('SocketException')) {
      showErrorDialog(
        context,
        "Network error: please check your internet connection.",
        [],
      );
    } else {
      showErrorDialog(context, "Client error: ${e.message}", []);
    }
  } catch (error) {
    showErrorDialog(
      context,
      "Unexpected error: $error",
      [],
    );
  }
}
