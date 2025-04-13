import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Import for SocketException

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../constants/appConstants.dart';
import '../../models/festivalModel.dart';
import '../../utilities/sharedPrefs.dart';


Future<FestivalResponse?> getFestivalCollection(BuildContext context) async {
  final url = Uri.parse("${AppConstants.baseUrl}/getfestival");
  const timeoutDuration = Duration(seconds: 30); // Define a timeout duration

  try {
    final bearerToken = await getToken();
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json', // Set the content type to JSON
      },
    ).timeout(timeoutDuration); // Apply timeout to the request

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return FestivalResponse.fromJson(data);
    } else if (response.statusCode == 403) {
      // Handle client-side errors (e.g., validation failed)
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      showExpiredAccountErrorDialog(
          context, responseData['message'], responseData['errors']);
    } else {
      final data = json.decode(response.body);
      showErrorDialog(context, data['message'], data['errors']);
    }
  } on TimeoutException catch (_) {
    final connectivity = await Connectivity().checkConnectivity();
    final hasConnection = connectivity != ConnectivityResult.none;

    if (hasConnection) {
      final isInternetSlow = !(await _hasGoodConnection());
      if (isInternetSlow) {
        showErrorDialog(context, "Slow internet connection detected.", []);
      } else {
        showErrorDialog(context, "Server is taking too long to respond.", []);
      }
    } else {
      showErrorDialog(context, "No internet connection.", []);
    }
  } on SocketException catch (_) {
    // Handle internet connectivity issues
    showErrorDialog(context,
        "No Internet connection. Please check your network and try again.", []);
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
    // Handle any other exceptions
    showErrorDialog(context,
        "An unexpected error occurred while fetching festivals: $error", []);
    print("Error fetching festivals: $error");
  }
}

Future<bool> _hasGoodConnection() async {
  try {
    final response = await http
        .get(
      Uri.parse('https://www.google.com'),
    )
        .timeout(Duration(seconds: 2));
    return true;
  } catch (_) {
    return false;
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
          //     Navigator.pushAndRemoveUntil(
          //       context,
          //       FadePageRouteBuilder(
          //         widget: BotomPremiumView(),
          //       ),
          //           (Route<dynamic> route) => false,
          //     );
          //   },
          // ),
        ],
      );
    },
  );
}

void showErrorDialog(
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
