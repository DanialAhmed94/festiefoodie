import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/appConstants.dart';
import '../../services/firestore_user_service.dart';
import '../../utilities/dilalogBoxes.dart';
import '../../views/foodieStall/authViews/loginView.dart';

Future<void> signUp(
    BuildContext context,
    String fullName,
    String email,
    String phone,
    Future<List<String>> images,
    String organization,
    String organization_address,
    String password) async {
  final url = Uri.parse("${AppConstants.baseUrl}/authup");

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deviceId= await prefs.getString("fcm_token");

  List<String> uploadedImages = await images;
  final Map<String, dynamic> signUpData = {
    'name': fullName,
    'email': email,
    'phone': phone,
    'password': password,
    'organization_name': organization,
    'organization_address': organization_address,
    'image': uploadedImages.isNotEmpty ? uploadedImages[0] : null,
    'image2': uploadedImages.length > 1 ? uploadedImages[1] : null,
    'image3': uploadedImages.length > 2 ? uploadedImages[2] : null,
    'app_type':"festiefoodie",
    'device_token': deviceId,
  };

  try {
    // Send the POST request with a timeout
    final response = await http
        .post(
      url,
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: jsonEncode(signUpData), // Encode the data to JSON format
    )
        .timeout(const Duration(seconds: 30)); // Set a timeout duration

    // Handle the response
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['code'] == 200) {
        // Signup successful
        print('Signup successful: ${responseData['message']}');
        print('Token: ${responseData['data']['response']['token']}');
        print('User: ${responseData['data']['user']}');

        // Create user in Firestore for chat functionality
        try {
          final userData = responseData['data']['user'];
          final userId = userData['id'].toString();
          final userName = userData['name'];
          final phoneNumber = userData['phone'];

          await FirestoreUserService.createOrUpdateUser(
            userId: userId,
            phoneNumber: phoneNumber,
            userName: userName,
          );

          print('✅ User created in Firestore for chat functionality');
        } catch (e) {
          print('⚠️ Warning: Failed to create user in Firestore: $e');
          // Don't block signup if Firestore fails
        }


        showSuccessDialog(context,"Your account has been created successfully!",null,LoginView());
      } else {
        // Server-side validation or other errors
        showErrorDialog(
            context, responseData['message'], responseData['errors']);
      }
    } else if (response.statusCode == 400) {
      // Handle client-side errors (e.g., validation failed)
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showErrorDialog(context, responseData['message'], responseData['errors']);
    } else {
      // Handle other HTTP errors
      showErrorDialog(context,
          "Signup failed with status code: ${response.statusCode}", []);
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  }on ClientException catch (e) {
    final errorString = e.toString(); // or e.message

    // Check if it contains "SocketException"
    if (errorString.contains('SocketException')) {
      // Handle the wrapped SocketException here
      showErrorDialog(
        context,
        "Network error: failed to reach server. Please check your connection.",
        [],
      );
    } else {
      // Otherwise handle any other client exception
      showErrorDialog(
        context,
        "A client error occurred: ${e.message}",
        [],
      );
    }
  } catch (error) {
    showErrorDialog(context, "Signup failed with error: $error", []);
  }
}




