import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../annim/transiton.dart';
import '../../constants/appConstants.dart';
import '../../utilities/dilalogBoxes.dart';
import '../../utilities/sharedPrefs.dart';
import '../../views/foodieStall/foofieStallHome.dart';

Future<void> LogInApi(
    BuildContext context, String email, String password) async {
  final url = Uri.parse("${AppConstants.baseUrl}/authin");

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deviceId= await prefs.getString("fcm_token");

  final Map<String, dynamic> logInData = {
    'email': email,
    'password': password,
    'device_token': deviceId,
    'app_type':"festiefoodie",
  };
  try {
    final response = await http
        .post(
      url,
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: jsonEncode(logInData),
    )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['code'] == 200) {
        final token = responseData['data']['response']['token'];
        debugPrint(" auth token ${token} ");

        final userName = responseData['data']['user']['name'];
        final userEmail = responseData['data']['user']['email'];
        final userId = responseData['data']['user']['id'];
        print("token $token");
        await saveToken(token);
        await saveUserName(userName);
        await saveUserEmail(userEmail);
        await saveUserId(userId);

        await setIsLogedIn(true);

        // Save FCM token in Firestore

        if (userId != null && (deviceId?.isNotEmpty ?? false)) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId.toString())
              .set({"fcmToken": deviceId}, SetOptions(merge: true));
          print("✅ FCM token updated for user: $userId");
        }

        print("api hit ${token}");
        Navigator.pushReplacement(
            context, FadePageRouteBuilder(widget:  FoodieStallHome(),));
        // context, FadePageRouteBuilder(widget: PremiumView()));
      } else {
        // Server-side validation or other errors
        showErrorDialog(
            context, responseData['message'], responseData['errors']);
      }
    } else if (response.statusCode == 400) {
      // Handle client-side errors (e.g., validation failed)
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showErrorDialog(context, responseData['message'], responseData['errors']);
    }else if (response.statusCode == 403) {
      // Handle client-side errors (e.g., validation failed)
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showExpiredAccountErrorDialog(context, responseData['message'], responseData['errors']);
    } else {
      // Handle other HTTP errors
      showErrorDialog(
          context, "Login failed with status code: ${response.statusCode}", []);
    }
  } on TimeoutException catch (_) {
    showErrorDialog(context, "Request timed out. Please try again later.", []);
  } on ClientException catch (e) {
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
  }catch (error) {
    showErrorDialog(context, "Login failed with error: $error", []);
  }
}
void showExpiredAccountErrorDialog(
    BuildContext context, String message, List<dynamic> errors) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (errors.isNotEmpty)
              Column(
                children: errors
                    .map((error) => Text(error.toString(),
                    style: TextStyle(color: Colors.red)))
                    .toList(),
              ),
          ],
        ),
        actions: <Widget>[
          // TextButton(
          //   child: Text('Cancel'),
          //   onPressed: () {
          //     Navigator.of(context).pop();
          //   },
          // ),
          // TextButton(
          //   child: Text('Upgrade'),
          //   onPressed: () {
          //    Navigator.push(context, FadePageRouteBuilder(widget:  BotomPremiumView(),));
          //   },
          // ),
        ],
      );
    },
  );
}